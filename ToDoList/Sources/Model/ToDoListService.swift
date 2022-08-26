//
//  ToDoListService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import Foundation
import CocoaLumberjack
import CoreData

protocol ToDoListServiceDelegate: AnyObject {
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

final class ToDoListService {

    // MARK: - Private vars
    private var networkService: NetworkService

    private lazy var retry: ExponentialRetry<[ToDoItemModel]> = {
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

    private let coreDataStack = CoreDataStack.shared

    // MARK: - init
    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - API
    var delegate: ToDoListServiceDelegate?

    func load() {
        assert(Thread.current.isMainThread)

        coreDataStack.container.performBackgroundTask { [self] context in
            let fetchRequest = ToDoItem.fetchRequest()

            do {
                let items = try context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    if items.isEmpty {
                        self.processLoadResult(.failure(FileCacheServiceErrors.LoadError.failLoadNoSuchFile))
                    } else {
                        self.processLoadResult(.success(()))
                    }
                }
            } catch {
                fatalError("function \(#function) failed with error: \(error.localizedDescription)")
            }
        }
    }

    func addItem(_ item: ToDoItemModel?, isNew: Bool) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.AddMessages.fail): \(String(describing: item))")
            delegate?.didAddItemFail()
            return
        }

        if isNew {
            requestToAddItem(item)
        } else {
            requestToEditItem(item)
        }
    }

    func deleteItem(_ item: ToDoItemModel?) {
        assert(Thread.current.isMainThread)

        guard let item = item else {
            DDLogError("\(Constants.DeleteMessages.fail): \(String(describing: item))")
            delegate?.didDeleteItemFail()
            return
        }

        requestToDeleteItem(item)
    }

    // MARK: - Private funcs
    private var items: [ToDoItemModel] {
        let fetchRequest = ToDoItem.fetchRequest()

        do {
            return try CoreDataStack.shared.mainContext.fetch(fetchRequest)
                .compactMap { item in
                    item.toImmutable
                }

        } catch let error as NSError {
            fatalError("coreDataStack unavailable: \(error.description)")
        }
    }

    private func requestToAddItem(_ item: ToDoItemModel) {
        networkService.addToDoItem(item: item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logAddItemOnServer(result)
            self.synchronizeIfNeeded(result)
        }
    }

    private func requestToEditItem(_ item: ToDoItemModel) {
        networkService.editToDoItem(item) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logEditItemOnServer(result)
            self.synchronizeIfNeeded(result)
        }
    }

    private func requestToDeleteItem(_ item: ToDoItemModel) {
        self.networkService.deleteToDoItem(at: item.id) { [weak self] result in
            guard let self = self else {
                return
            }

            self.logDeleteItemOnServer(result)
            self.synchronizeIfNeeded(result)
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
            assert(Thread.isMainThread)
            guard let self = self else {
                return
            }

            switch result {
            case .success(let items):
                DDLogVerbose("successfuly fetched list from server")
                self.replaceItemsWithNewItems(items)
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

    private func replaceItemsWithNewItems(_ items: [ToDoItemModel]) {
        coreDataStack.container.performBackgroundTask { [self] context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            do {
                let fetchRequest = ToDoItem.fetchRequest()
                let items = try context.fetch(fetchRequest)

                // delete all
                for item in items {
                    context.delete(item)
                }

            } catch let errror as NSError {
                fatalError("error in \(#function): \(errror.description)")
            }

            // add new
            for itemModel in items {
                guard let entity =
                    NSEntityDescription.entity(forEntityName: "ToDoItem",
                                               in: context) else {
                    fatalError("couldn't create entity")
                }

                let item = ToDoItem(entity: entity, insertInto: context)
                item.setPropertiesFrom(model: itemModel)
            }

            do {
                try context.save()
            } catch let error as NSError {
                fatalError("error in \(#function): \(error.description)")
            }

            DispatchQueue.main.async {
                self.delegate?.didSynchronize()
            }
        }
    }

    private func logEditItemOnServer(_ result: Result<ToDoItemModel, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.ServerEditMessages.sucessful)
        case .failure:
            DDLogVerbose(Constants.ServerEditMessages.fail)
        }
    }

    private func logAddItemOnServer(_ result: Result<ToDoItemModel, Error>) {
        switch result {
        case .success:
            DDLogVerbose(Constants.ServerAddMessages.sucessful)
        case .failure:
            DDLogVerbose(Constants.ServerAddMessages.fail)
        }
    }

    private func logDeleteItemOnServer(_ result: Result<ToDoItemModel, Error>) {
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

extension ToDoItem {
    func setPropertiesFrom(model: ToDoItemModel) {
        self.id = model.id
        self.text = model.text
        self.done = model.done
        self.priority = model.priority
        self.deadline = model.deadline
        self.createdAt = model.createdAt
        self.modifiiedAt = model.modifiedAt
    }
}
