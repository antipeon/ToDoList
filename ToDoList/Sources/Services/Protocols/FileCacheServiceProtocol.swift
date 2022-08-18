//
//  FileCacheServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol FileCacheService {
    /// up-to-date toDoItems
    var toDoItems: [ToDoItem] { get }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void)

    func load(from file: String, completion: @escaping (Result<Void, Error>) -> Void)

    @discardableResult
    func add(_ newItem: ToDoItem) -> Result<Void, Error>

    @discardableResult
    func delete(id: String) -> Result<ToDoItem, Error>
}

enum FileCacheServiceErrors {
    enum SaveError: Error {
        case failSave
    }
    enum LoadError: Error {
        case failLoad
        case failLoadNoSuchFile
    }
    enum AddError: Error {
        case failAdd
    }
    enum DeleteError: Error {
        case failDelete
    }
}
