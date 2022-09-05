//
//  NetworkServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol NetworkService {
    func getAllToDoItems(completion: @escaping (Result<[ToDoItemModel], Error>) -> Void)

    func editToDoItem(_ item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void)

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItemModel, Error>) -> Void)

    func updateToDoItems(withItems items: [ToDoItemModel], completion: @escaping (Result<[ToDoItemModel], Error>) -> Void)

    func addToDoItem(item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void)
}

enum NetworkServiceError: Error {
    case failEditItem
    case failDeleteItem
    case failGetAll
    case failUpdateItem
    case failAddItem
}
