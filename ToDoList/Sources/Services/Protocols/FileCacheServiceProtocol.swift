//
//  FileCacheServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol FileCacheService {
    /// up-to-date toDoItems
    var toDoItems: [ToDoItemModel] { get }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void)

    func load(from file: String, completion: @escaping (Result<Void, Error>) -> Void)

    @discardableResult
    func add(_ newItem: ToDoItemModel) -> Result<Void, Error>

    @discardableResult
    func delete(id: String) -> Result<ToDoItemModel, Error>
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
