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

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.current.isMainThread)
        fileCache.load(from: ToDoListModel.fileName) { result in
            assert(Thread.current.isMainThread)
            completion(result)
        }
    }

    func addItem(_ item: ToDoItem?) {
        defer {
            delegate?.didAddItem()
        }

        assert(Thread.current.isMainThread)

        guard let item = item else {
            return
        }
        fileCache.delete(id: item.id)
        fileCache.add(item)

        DDLogVerbose(Constants.SaveMessages.performing)

        fileCache.save(to: ToDoListModel.fileName) { result in
            assert(Thread.current.isMainThread)
            switch result {
            case .success:
                DDLogInfo(Constants.SaveMessages.successful)
                return
            case .failure(let error):
                DDLogError(Constants.SaveMessages.unsuccessful)
                fatalError(error.localizedDescription)
            }
        }
    }

    func deleteItem(_ item: ToDoItem?) {
        defer {
            delegate?.didDeleteItem()
        }
        assert(Thread.current.isMainThread)

        guard let item = item else {
            return
        }
        fileCache.delete(id: item.id)

        DDLogVerbose(Constants.SaveMessages.performing)

        fileCache.save(to: ToDoListModel.fileName) { result in
            assert(Thread.current.isMainThread)

            switch result {
            case .failure(let error):
                DDLogError(Constants.SaveMessages.unsuccessful)
                fatalError(error.localizedDescription)
            case .success:
                DDLogInfo(Constants.SaveMessages.successful)
                return
            }
        }
    }

    private enum Constants {
        enum SaveMessages {
            static let successful = "save successful"
            static let unsuccessful = "save unsuccessful"
            static let performing = "performing save..."
        }

    }
}
