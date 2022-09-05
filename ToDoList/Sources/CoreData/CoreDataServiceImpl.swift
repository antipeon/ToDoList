//
//  CoreDataServiceImpl.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.08.2022.
//

import Foundation
import CoreData
import CocoaLumberjack

final class CoreDataServiceImpl: CoreDataService {

    // MARK: - Properties
    private(set) var toDoItems: [ToDoItem] = []

    // MARK: - init
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - API
    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest = ToDoItem.fetchRequest()

        let asyncFetchRequest = NSAsynchronousFetchRequest<ToDoItem>(fetchRequest: fetchRequest) { result in

            let items = result.finalResult
        }

        let context = self.coreDataStack.backgroundContext()
        context.perform {
            do {
                try context.execute(async)
            }
        }

    }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest = ToDoItem.fetchRequest()

        let sortByCreatedAt = NSSortDescriptor(key: #keyPath(ToDoItem.createdAt), ascending: false)

        fetchRequest.sortDescriptors = [sortByCreatedAt]
        fetchRequest.fetchBatchSize = Constants.batchSize

        let asyncFetchRequest = NSAsynchronousFetchRequest<ToDoItem>(fetchRequest: fetchRequest) { [weak self] result in
            guard let self = self else { return }

            if result.operationError != nil {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataServiceErrors.LoadError.failLoad))
                }
                return
            }

            guard let toDoItems = result.finalResult else {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataServiceErrors.LoadError.failLoad))
                }
                return
            }

            self.toDoItems = toDoItems
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        coreDataStack.container.performBackgroundTask { context in
            do {
                try context.execute(asyncFetchRequest)
            } catch let error as NSError {
                DDLogVerbose(error.localizedDescription)
            }
        }

    }

    func add(_ newItem: ToDoItem) -> Result<Void, Error> {
        return .success(())
    }

    func delete(id: String) -> Result<ToDoItem, Error> {
        return .failure(CoreDataServiceErrors.DeleteError.failDelete)
    }

    // MARK: - Private vars
    private var coreDataStack: CoreDataStack

    // MARK: - Constants
    private enum Constants {
        static let batchSize = 20
    }

}
