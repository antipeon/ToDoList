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
    private var fileCache: FileCacheService

    // MARK: - API
    var items: [ToDoItem] {
        fileCache.toDoItems.orderedByDate()
    }

    var delegate: ToDoListModelDelegate?

    init() {
        fileCache = MockFileCacheService()
    }

    func load() {
        assert(Thread.current.isMainThread)

        fileCache.load(from: ToDoListModel.fileName) { [weak self] result in
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

        fileCache.delete(id: item.id)

        let result = fileCache.add(item)
        processAddResult(result, for: item)

        DDLogVerbose(Constants.SaveMessages.performing)

        fileCache.save(to: ToDoListModel.fileName) { [weak self] result in
            assert(Thread.current.isMainThread)
            self?.processSaveResult(result)
        }
    }

    func deleteItem(_ item: ToDoItem?) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.DeleteMessages.fail): \(String(describing: item))")
            delegate?.didDeleteItemFail()
            return
        }

        let result = fileCache.delete(id: item.id)
        processDeleteResult(result, for: item)

        DDLogVerbose(Constants.SaveMessages.performing)

        fileCache.save(to: ToDoListModel.fileName) { [weak self] result in
            assert(Thread.current.isMainThread)
            self?.processSaveResult(result)
        }
    }

    // MARK: - Private funcs
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
            delegate?.didLoad()
        case .failure(let error as FileCacheServiceErrors.LoadError):

            switch error {
            case .failLoadNoSuchFile:
                DDLogVerbose(Constants.LoadMessages.noCache)
                delegate?.didLoad()
            case .failLoad:
                DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
                delegate?.didLoadFail()
            }

        case .failure(let error):
            DDLogError("\(Constants.LoadMessages.fail): \(error.localizedDescription)")
            delegate?.didLoadFail()
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
