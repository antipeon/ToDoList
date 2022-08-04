//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import Foundation

struct ToDoItem: Identifiable {
    let id: String
    let text: String
    let priority: Priority
    let createdAt: Date
    let deadline: Date?
    let done: Bool
    let modifiedAt: Date?
    
    init(id: String = UUID().uuidString, text: String, priority: Priority, createdAt: Date,
         deadline: Date? = nil, done: Bool = false, modifiedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.priority = priority
        if let deadline = deadline {
            self.deadline = Date.makeDateWithRoundedTimeIntervalSince1970(from: deadline)
        } else {
            self.deadline = nil
        }
        self.done = done
        self.createdAt = Date.makeDateWithRoundedTimeIntervalSince1970(from: createdAt)
        if let modifiedAt = modifiedAt {
            self.modifiedAt = Date.makeDateWithRoundedTimeIntervalSince1970(from: modifiedAt)
        } else {
            self.modifiedAt = nil
        }
    }
    
    enum Priority: String, CaseIterable {
        case low
        case normal
        case high
    }
}

extension ToDoItem: Equatable {
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ToDoItem {
    init?(from dictionary: [String: Any]) {
        // check if only allowed keys
        let allowedKeys = ["id", "text", "done", "createdAt", "priority", "deadline", "modifiedAt"]
        let notAllowedKeys = dictionary.keys
            .filter {
                !allowedKeys.contains($0)
            }
        guard notAllowedKeys.isEmpty else {
            return nil
        }
        // these keys have to be there
        guard let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let done = dictionary["done"] as? Bool,
              let createdAt = (dictionary["createdAt"] as? Int)?.date else {
            return nil
        }
        
        // set priority
        var priority = Priority.normal
        if let priorityInDictionaryStr = dictionary["priority"] as? String {
            guard let priorityInDictionary = Priority(rawValue: priorityInDictionaryStr) else {
                return nil
            }
            if priorityInDictionary == .normal {
                return nil
            }
            priority = priorityInDictionary
        }
        
        // set optional properties
        let deadline = (dictionary["deadline"] as? Int)?.date
        let modifiedAt = (dictionary["modifiedAt"] as? Int)?.date
        
        self.init(id: id, text: text, priority: priority, createdAt: createdAt, deadline: deadline, done: done, modifiedAt: modifiedAt)
    }
    
    /// Parses json to toDoItem
    /// - Parameter json: [String: Any]
    /// - Returns: ToDoItem if can convert
    static func parse(json: Any) -> ToDoItem? {

        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        
        return ToDoItem(from: dictionary)
    }
    
    /// Produces json from self
    /// - Returns: json as [String: Any]
    var json: Any {
        var dictionary: [String: Any] = [
            "id" : id,
            "text" : text,
            "done" : done,
            "createdAt" : createdAt.timeStamp,
        ]
        
        switch priority {
        case .normal:
            break
        default:
            dictionary["priority"] = priority.rawValue
        }
        
        if let deadline = deadline {
            dictionary["deadline"] = deadline.timeStamp
        }
        
        if let modifiedAt = modifiedAt {
            dictionary["modifiedAt"] = modifiedAt.timeStamp
        }
        return dictionary
    }
}

extension Date {
    var timeStamp: Int {
        Int(self.timeIntervalSince1970)
    }
    
    init(roundedTimeIntervalSince1970: Int) {
        self.init(timeIntervalSince1970: Double(roundedTimeIntervalSince1970))
    }
    
    static func makeDateWithRoundedTimeIntervalSince1970(from date: Date) -> Date {
        return Date(roundedTimeIntervalSince1970: Int(date.timeIntervalSince1970))
    }
}

extension Int {
    var date: Date? {
        return Date(timeIntervalSince1970: Double(self))
    }
}
