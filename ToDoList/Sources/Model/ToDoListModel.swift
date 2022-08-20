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

    private var isDirty = true

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

        DDLogVerbose(Constants.SaveMessages.performing)

        saveItemsToCache()

        // server work
        if isDirty {
            synchronizeWithServer()
            return
        }

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
        if isDirty {
            synchronizeWithServer()
            return
        }

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

            self.markDirtyIfFailure(result: result)
        }
    }

    private func requestToEditItem(_ item: ToDoItem) {
        networkService.editToDoItem(item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.markDirtyIfFailure(result: result)
        }
    }

    private func requestToDeleteItem(_ item: ToDoItem) {
        networkService.deleteToDoItem(at: item.id) { [weak self] result in
            guard let self = self else {
                return
            }

            self.markDirtyIfFailure(result: result)
        }
    }

    private func synchronizeWithServer() {
        networkService.updateToDoItems(withItems: items) { [weak self] result in
            guard let self = self else {
                return
            }

            self.synchronizeCallback(result: result)
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

            self.delegate?.didLoad()

        case .failure(let error as FileCacheServiceErrors.LoadError):

            switch error {
            case .failLoadNoSuchFile:
                DDLogVerbose(Constants.LoadMessages.noCache)

                synchronizeWithServerIfNoFileInCache()

            case .failLoad:
                DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
                delegate?.didLoadFail()
            }

        case .failure(let error):
            DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
            delegate?.didLoadFail()
        }
    }

    private func markDirtyIfFailure<T>(result: Result<T, Error>) {
        switch result {
        case .success:
            return
        case .failure:
            isDirty = true
        }
    }

    private func synchronizeWithServerIfNoFileInCache() {
        networkService.getAllToDoItems { [weak self] result in
            guard let self = self else {
                return
            }

            self.synchronizeCallback(result: result)
        }
    }

    private func synchronizeCallback(result: Result<[ToDoItem], Error>) {
        switch result {
        case .failure:
            self.isDirty = true
            DDLogVerbose(Constants.SynchronizationMessages.fail)
        case .success(let itemsFromServer):
            DDLogVerbose(Constants.SynchronizationMessages.successful)
            replaceItemsWithNewItemsWith(itemsFromServer)
            self.isDirty = false
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

    private func replaceItemsWithNewItemsWith(_ items: [ToDoItem]) {
        fileCacheService.replaceItemsWithNewItems(items)
        delegate?.didSynchronize()
        saveItemsToCache()
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
