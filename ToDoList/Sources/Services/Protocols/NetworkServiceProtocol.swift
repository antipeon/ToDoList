//
//  NetworkServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol NetworkService {
    func getAllToDoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void)

    func editToDoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void)

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void)

    func updateToDoItems(withItems: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void)

    func addToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void)
}

enum NetworkServiceError: Error {
    case failEditItem
    case failDeleteItem
    case failGetAll
    case failUpdateItem
    case failAddItem
}
