//
//  ToDoListModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import Foundation
import CocoaLumberjack

protocol ToDoListModelDelegate: AnyObject {
    func didAddItem()
    func didDeleteItem()
    func didSave()
    func didLoad()
    func didLoadFail()
    func didSaveFail()
    func didAddItemFail()
    func didDeleteItemFail()
    func didSynchronize()
}

final class ToDoListModel {

    // MARK: - Private vars
    private static let fileName = "toDoItems"
    private var fileCacheService: FileCacheService
    private var networkService: NetworkService

    private lazy var retry: ExponentialRetry<[ToDoItem]> = {
        ExponentialRetry(
            networkService: networkService,
            work: networkService.updateToDoItems,
            onWorkSuccess: { [weak self] newItems in
                guard let self = self else {
                    return
                }
                DDLogVerbose(Constants.SynchronizationMessages.successful)
                self.replaceItemsWithNewItems(newItems)
                self.delegate?.didSynchronize()
            },
            dataProvider: {
                self.items
            }
        )
    }()

    // MARK: - init
    init() {
        fileCacheService = MockFileCacheService()
        networkService = DefaultNetworkingService()
    }

    // MARK: - API
    var items: [ToDoItem] {
        fileCacheService.toDoItems.orderedByDate()
    }

    var delegate: ToDoListModelDelegate?

    func load() {
        assert(Thread.current.isMainThread)

        fileCacheService.load(from: ToDoListModel.fileName) { [weak self] result in
            assert(Thread.current.isMainThread)
            self?.processLoadResult(result)
        }
    }

    func addItem(_ item: ToDoItem?) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.AddMessages.fail): \(String(describing: item))")
            delegate?.didAddItemFail()
            return
        }

        // local work
        let deleteResult = fileCacheService.delete(id: item.id)
        let addResult = fileCacheService.add(item)
        processAddResult(addResult, for: item)

        saveItemsToCache()

        // server work
        switch deleteResult {
        case .success:
            requestToEditItem(item)
        case .failure:
            requestToAddItem(item)
        }
    }

    func deleteItem(_ item: ToDoItem?) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.DeleteMessages.fail): \(String(describing: item))")
            delegate?.didDeleteItemFail()
            return
        }

        // local work
        let result = fileCacheService.delete(id: item.id)
        processDeleteResult(result, for: item)

        saveItemsToCache()

        // server work
        requestToDeleteItem(item)
    }

    // MARK: - Private funcs
    private func saveItemsToCache() {
        DDLogVerbose(Constants.SaveMessages.performing)

        fileCacheService.save(to: ToDoListModel.fileName) { [weak self] result in
            assert(Thread.current.isMainThread)
            self?.processSaveResult(result)
        }
    }

    private func requestToAddItem(_ item: ToDoItem) {
        networkService.addToDoItem(item: item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logAddItemOnServer(result)
            self.synchronizeIfNeeded(result)
        }
    }

    private func requestToEditItem(_ item: ToDoItem) {
        networkService.editToDoItem(item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logEditItemOnServer(result)
            self.synchronizeIfNeeded(result)
        }
    }

    private func requestToDeleteItem(_ item: ToDoItem) {
        self.networkService.deleteToDoItem(at: item.id) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logDeleteItemOnServer(result)
            self.synchronizeIfNeeded(result)
        }
    }

    private func processSaveResult(_ result: Result<Void, Error>) {
        switch result {
        case .failure(let error):
            DDLogError("\(Constants.SaveMessages.unsuccessful) - error: \(error.localizedDescription)")
            delegate?.didSaveFail()
        case .success:
            DDLogInfo(Constants.SaveMessages.successful)
            delegate?.didSave()
        }
    }

    private func processLoadResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.LoadMessages.successful)

            synchronizeWithServer()
            delegate?.didLoad()

        case .failure(let error as FileCacheServiceErrors.LoadError):

            switch error {
            case .failLoadNoSuchFile:
                DDLogVerbose(Constants.LoadMessages.noCache)

                synchronizeWithServerIfNoFileInCache()
                delegate?.didLoad()

                self.delegate?.didLoad()

            case .failLoad:
                DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
                delegate?.didLoadFail()
            }

        case .failure(let error):
            DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
            delegate?.didLoadFail()
        }
    }

    private func synchronizeWithServer() {
        DDLogVerbose("synchronizing list with server...")
        networkService.updateToDoItems(withItems: items) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                DDLogVerbose(Constants.SynchronizationMessages.successful)
            case .failure(let error):
                DDLogVerbose("\(Constants.SynchronizationMessages.fail) with error: \(error.localizedDescription)")
            }

            self.synchronizeIfNeeded(result)
        }
    }

    private func synchronizeWithServerIfNoFileInCache() {
        DDLogVerbose("fetching list from server...")
        networkService.getAllToDoItems { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                DDLogVerbose("successfuly fetched list from server")
            case .failure(let error):
                DDLogVerbose("failed to fetch list from server with error: \(error.localizedDescription)")
            }

            self.synchronizeIfNeeded(result)
        }
    }

    private func synchronizeIfNeeded<T>(_ result: Result<T, Error>) {
        switch result {
        case .failure:
            retry.run()
        case .success:
            break
        }
    }

    private func processDeleteResult(_ result: Result<ToDoItem, Error>, for item: ToDoItem) {
        switch result {
        case .failure(let error):
            DDLogError("\(Constants.DeleteMessages.fail): with id: \(item.id), with error \(error.localizedDescription)")
            delegate?.didDeleteItemFail()
        case .success(let item):
            DDLogInfo("\(Constants.DeleteMessages.sucessful): \(item)")
            delegate?.didDeleteItem()
        }
    }

    private func processAddResult(_ result: Result<Void, Error>, for item: ToDoItem) {
        switch result {
        case .failure(let error):
            DDLogError("\(Constants.AddMessages.fail): \(String(describing: item)) with error \(error.localizedDescription)")
            delegate?.didAddItemFail()
        case .success:
            DDLogInfo("\(Constants.AddMessages.sucessful): \(item)")
            delegate?.didAddItem()
        }
    }

    private func replaceItemsWithNewItems(_ items: [ToDoItem]) {
        fileCacheService.replaceItemsWithNewItems(items)
        delegate?.didSynchronize()
        saveItemsToCache()
    }

    private func logEditItemOnServer(_ result: Result<ToDoItem, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.ServerEditMessages.sucessful)
        case .failure:
            DDLogVerbose(Constants.ServerEditMessages.fail)
        }
    }

    private func logAddItemOnServer(_ result: Result<ToDoItem, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.ServerAddMessages.sucessful)
        case .failure:
            DDLogVerbose(Constants.ServerAddMessages.fail)
        }
    }

    private func logDeleteItemOnServer(_ result: Result<ToDoItem, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.ServerDeleteMessages.sucessful)
        case .failure:
            DDLogVerbose(Constants.ServerDeleteMessages.fail)
        }
    }

    // MARK: - Constants
    private enum Constants {
        enum SaveMessages {
            static let successful = "save successful"
            static let unsuccessful = "save unsuccessful"
            static let performing = "performing save..."
        }
        enum AddMessages {
            static let sucessful = "successfuly added item"
            static let fail = "failed to add item"
        }
        enum DeleteMessages {
            static let sucessful = "successfuly deleted item"
            static let fail = "failed to delete item"
        }
        enum LoadMessages {
            static let successful = "load successful"
            static let fail = "load failed with error"
            static let noCache = "load - no cache found"
        }
        enum SynchronizationMessages {
            static let successful = "synchronization successful"
            static let fail = "synchronization unsuccessful"
        }
        enum ServerAddMessages {
            static let sucessful = "successfuly added item on server"
            static let fail = "failed to add item on sever"
        }
        enum ServerDeleteMessages {
            static let sucessful = "successfuly deleted item on server"
            static let fail = "failed to delete item on server"
        }
        enum ServerEditMessages {
            static let sucessful = "successfuly edited item on server"
            static let fail = "failed to edit item on server"
        }
    }
}

// MARK: - Extensions
extension FileCacheService {
    func replaceItemsWithNewItems(_ items: [ToDoItem]) {
        for item in self.toDoItems {
            delete(id: item.id)
        }

        for item in items {
            add(item)
        }
    }
}
