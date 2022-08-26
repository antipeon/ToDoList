//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.08.2022.
//

import Foundation
import CoreData

final class CoreDataStack {
    // MARK: - Public vars
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    // MARK: - Private vars
    private(set) lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.containerName)
        container.loadPersistentStores { _, error in
            guard let error = error as NSError? else {
//                self.clearContainer()

                return
            }

            fatalError(error.localizedDescription.description)
        }

        return container
    }()

    private func clearContainer() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ToDoItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        self.mainContext.performAndWait {
            do {
                try container.persistentStoreCoordinator.execute(deleteRequest, with: self.mainContext)

            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
    }

    // MARK: - init
    private init() {}
    static let shared = CoreDataStack()

    fileprivate enum Constants {
        static let containerName = "ToDoList"
    }
}

extension CoreDataStack {
    func saveContext() {
        guard mainContext.hasChanges else { return }

        do {
            try mainContext.save()
        } catch let error as NSError {
            fatalError(error.description)
        }
    }
}
