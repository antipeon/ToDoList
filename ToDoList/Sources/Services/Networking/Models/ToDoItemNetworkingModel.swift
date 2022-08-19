//
//  ToDoItemNetworkingModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 17.08.2022.
//

import Foundation

struct ToDoItemNetworkingModel: Codable {
    typealias Timestamp = Int

    let id: String
    let text: String
    let priority: ToDoItemNetworkingModel.Priority
    let deadline: Timestamp?
    let done: Bool
    let createdAt: Timestamp
    let modifiedAt: Timestamp?
    let lastUpdatedBy: String = ""

    init(from item: ToDoItem) {
        id = item.id
        text = item.text
        priority = .init(from: item.priority)
//        priority = ToDoItemNetworkingModel.Priority.makePriority(from: item.priority)
        createdAt = item.createdAt.timeStamp
        deadline = item.deadline?.timeStamp
        done = item.done
        modifiedAt = item.modifiedAt?.timeStamp
    }

    enum Priority: String, CaseIterable, Codable {
        case low
        case basic
        case important
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case priority = "importance"
        case deadline
        case done
        case createdAt = "created_at"
        case modifiedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

// MARK: - Extensions

extension ToDoItem.Priority: Codable {

}

extension ToDoItem.Priority {
    init(from networkingModelPriority: ToDoItemNetworkingModel.Priority) {
        switch networkingModelPriority {
        case .low:
            self = .low
        case .basic:
            self = .normal
        case .important:
            self = .high
        }
    }
}

extension ToDoItemNetworkingModel.Priority {
    init(from toDoItemPriority: ToDoItem.Priority) {
        switch toDoItemPriority {
        case .low:
            self = .low
        case .normal:
            self = .basic
        case .high:
            self = .important
        }
    }
//
//    static func makePriority(from toDoItemPriority: ToDoItem.Priority) -> ToDoItemNetworkingModel.Priority {
//        switch toDoItemPriority {
//        case .low:
//            return .low
//        case .normal:
//            return .basic
//        case .high:
//            return .important
//        }
//    }
}

extension ToDoItem {
    init(from networkingModel: ToDoItemNetworkingModel) {

        self.init(
            id: networkingModel.id,
            text: networkingModel.text,
            priority: .init(from: networkingModel.priority),
            createdAt: Date(roundedTimeIntervalSince1970: networkingModel.createdAt),
            deadline: Date(roundedTimeIntervalSince1970: networkingModel.deadline),
            done: networkingModel.done,
            modifiedAt: Date(roundedTimeIntervalSince1970: networkingModel.modifiedAt)
        )
    }
}

extension Date {
    init?(roundedTimeIntervalSince1970: Int?) {
        guard let timeInterval = roundedTimeIntervalSince1970 else {
            return nil
        }
        self.init(roundedTimeIntervalSince1970: timeInterval)
    }
}
