//
//  FileCacheServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

protocol FileCacheService {
    // up-to-date toDoItems
    var toDoItems: [ToDoItem] { get }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void)

    func load(from file: String, completion: @escaping (Result<Void, Error>) -> Void)

    func add(_ newItem: ToDoItem)

    func delete(id: String)
}

enum FileCacheServiceErrors {
    enum SaveError: Error {
        case failSave
    }
    enum LoadError: Error {
        case failLoad
        case failLoadNoSuchFile
    }
}
