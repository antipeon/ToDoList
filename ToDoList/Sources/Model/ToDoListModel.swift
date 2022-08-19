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
}

final class ToDoListModel {
    // MARK: - Private vars
    private static let fileName = "toDoItems"
    private var fileCacheService: FileCacheService
    private var networkService: NetworkService

    private var isDirty = true

    var items: [ToDoItem] {
        fileCacheService.toDoItems.orderedByDate()
    }

    var delegate: ToDoListModelDelegate?

    init() {
        fileCacheService = MockFileCacheService()
        networkService = DefaultNetworkingService()
    }

    // MARK: - API
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

        synchronizeDataIfNeeded { [weak self] in
            guard let self = self else {
                return
            }

            let deleteResult = self.fileCacheService.delete(id: item.id)
            switch deleteResult {
            case .success(let item):
                self.networkService.deleteToDoItem(at: item.id) { [weak self] result in
                    guard let self = self else {
                        return
                    }

                    self.markDirtyIfFailure(result: result)

                    self.processAdd(item: item)
                }
            case .failure:
                self.processAdd(item: item)
            }
        }
    }

    func deleteItem(_ item: ToDoItem?) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.DeleteMessages.fail): \(String(describing: item))")
            delegate?.didDeleteItemFail()
            return
        }

        synchronizeDataIfNeeded { [weak self] in
            guard let self = self else {
                return
            }

            self.networkService.deleteToDoItem(at: item.id) { [weak self] result in
                guard let self = self else {
                    return
                }

                self.markDirtyIfFailure(result: result)
            }

            let result = self.fileCacheService.delete(id: item.id)
            self.processDeleteResult(result, for: item)

            self.saveItems()
        }
    }

    // MARK: - Private funcs
    private func saveItems() {
        DDLogVerbose(Constants.SaveMessages.performing)

        fileCacheService.save(to: ToDoListModel.fileName) { [weak self] result in
            assert(Thread.current.isMainThread)
            self?.processSaveResult(result)
        }
    }

    private func processAdd(item: ToDoItem) {
        self.networkService.addToDoItem(item: item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.markDirtyIfFailure(result: result)

            let addResult = self.fileCacheService.add(item)
            self.processAddResult(addResult, for: item)

            DDLogVerbose(Constants.SaveMessages.performing)

            self.saveItems()
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

            synchronizeData {}

        case .failure(let error as FileCacheServiceErrors.LoadError):

            switch error {
            case .failLoadNoSuchFile:
                DDLogVerbose(Constants.LoadMessages.noCache)

                synchronizeDataAfterLoadIfNoFile()

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

    private func synchronizeData(completion: @escaping () -> Void) {
        networkService.updateToDoItems(withItems: items) { [weak self] result in
            guard let self = self else {
                return
            }

            self.synchronizeCallback(result: result)
            completion()
        }
    }

    private func synchronizeDataIfNeeded(completion: @escaping () -> Void) {
        if isDirty {
            synchronizeData(completion: completion)
            return
        }
        completion()
    }

    private func synchronizeDataAfterLoadIfNoFile() {
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
        case .success(let itemsFromServer):
            replaceItemsWithNewItemsWith(itemsFromServer)
            self.isDirty = false
        }

        self.delegate?.didLoad()
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
        saveItems()
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
