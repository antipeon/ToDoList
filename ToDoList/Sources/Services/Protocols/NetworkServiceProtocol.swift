//
//  NetworkServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol NetworkService {
    func getAllToDoItems() async throws -> [ToDoItem]

    func editToDoItem(_ item: ToDoItem) async throws -> ToDoItem

    func deleteToDoItem(at id: String) async throws -> ToDoItem

    func updateToDoItems(withItems: [ToDoItem]) async throws -> [ToDoItem]

    func addToDoItem(item: ToDoItem) async throws -> ToDoItem
}

enum NetworkServiceError: Error {
    case failEditItem
    case failDeleteItem
    case failGetAll
    case failUpdateItem
    case failAddItem
}
