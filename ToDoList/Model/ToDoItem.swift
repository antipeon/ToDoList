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
        self.deadline = deadline
        self.done = done
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    enum Priority: String {
        case high
        case normal
        case low
    }
}

extension ToDoItem: Equatable {
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        if lhs.id == rhs.id, lhs.text == rhs.text, lhs.priority == rhs.priority,
           Date.dateEqual(lhs.deadline, rhs.deadline), lhs.done == rhs.done,
           Date.dateEqual(lhs.createdAt, rhs.createdAt), Date.dateEqual(lhs.modifiedAt, rhs.modifiedAt) {
            return true
        }
        return false
    }
}

extension ToDoItem {
    init?(from dictionary: NSDictionary) {
        // check if only allowed keys
        let allowedKeys = ["id", "text", "done", "createdAt", "priority", "deadline", "modifiedAt"]
        let notAllowedKeys = dictionary.allKeys
            .map {
                $0 as? String
            }
            .compactMap { $0 }
            .filter {
                !allowedKeys.contains($0)
            }
        guard notAllowedKeys.isEmpty else {
            return nil
        }
        
        // these keys have to be there
        guard let id = dictionary.value(forKey: "id") as? String,
              let text = dictionary.value(forKey: "text") as? String,
              let doneStr = dictionary.value(forKey: "done") as? String,
              let done = Bool(doneStr),
              let createdAt = (dictionary.value(forKey: "createdAt") as? String)?.date else {
            return nil
        }
        
        // set priority
        var priority = Priority.normal
        if let priorityInDictionaryStr = dictionary.value(forKey: "priority") as? String {
            guard let priorityInDictionary = Priority(rawValue: priorityInDictionaryStr) else {
                return nil
            }
            if priorityInDictionary == .normal {
                return nil
            }
            priority = priorityInDictionary
        }
        
        // set optional properties
        let deadline = (dictionary.value(forKey: "deadline") as? String)?.date
        let modifiedAt = (dictionary.value(forKey: "modifiedAt") as? String)?.date
        
        self.init(id: id, text: text, priority: priority, createdAt: createdAt, deadline: deadline, done: done, modifiedAt: modifiedAt)
    }
    
    /// Parses json to toDoItem
    /// - Parameter json: NSDictionary [String: Any]
    /// - Returns: ToDoItem if can convert
    static func parse(json: Any) -> ToDoItem? {

        guard let dictionary = json as? NSDictionary else {
            return nil
        }
        
        return ToDoItem(from: dictionary)
    }
    
    /// Produces json from self
    /// - Returns: json as NSDictionary [String: Any]
    var json: Any {
        var dictionary = [
            "id" : id,
            "text" : text,
            "done" : done.description,
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
        
        let nsDictionary = NSDictionary(dictionary: dictionary)
        return nsDictionary
    }
}

extension Date {
    var timeStamp: String {
        (round(self.timeIntervalSince1970 * 10) / 10.0).description
    }
    
    // implement equal with precision: https://developer.apple.com/documentation/foundation/timeinterval
    static func dateEqual(_ lhs: Date?, _ rhs: Date?) -> Bool {
        if lhs == nil && rhs == nil {
            return true
        }
        if lhs == nil && rhs != nil {
            return false
        }
        if lhs != nil && rhs == nil {
            return false
        }
        return lhs?.timeStamp == rhs?.timeStamp
    }
}

extension String {
    var date: Date? {
        guard let interval = Double(self) else {
            return nil
        }
        return Date(timeIntervalSince1970: interval)
    }
}
