//
//  ToDoItem+CoreDataProperties.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.08.2022.
//
//

import Foundation
import CoreData


extension ToDoItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged fileprivate var priorityValue: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var modifiiedAt: Date?
    @NSManaged public var toDoList: ToDoList?
    
}

extension ToDoItem : Identifiable {
    
}

extension ToDoItem {
    var priority: ToDoItemModel.Priority {
        get {
            guard let priorityValue = priorityValue else { return .normal }
            return ToDoItemModel.Priority(rawValue: priorityValue) ?? .normal
        }
        set {
            priorityValue = newValue.rawValue
        }
    }
}

extension ToDoItem {
    var toImmutable: ToDoItemModel? {
        guard let id = self.id, let text = self.text, let createdAt = self.createdAt else {
            return nil
        }
        
        return ToDoItemModel(
            id: id,
            text: text,
            priority: self.priority,
            createdAt: createdAt,
            deadline: self.deadline,
            done: self.done,
            modifiedAt: self.modifiiedAt
        )
    }
}
