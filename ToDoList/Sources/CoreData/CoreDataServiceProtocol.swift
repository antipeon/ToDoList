//
//  CoreDataServiceProtocol.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.08.2022.
//

import Foundation

protocol CoreDataService {
    func save(completion: @escaping (Result<Void, Error>) -> Void)

    func load(completion: @escaping (Result<Void, Error>) -> Void)
//
//    @discardableResult
//    func add(_ newItem: ToDoItem) -> Result<Void, Error>
//
//    @discardableResult
//    func delete(id: String) -> Result<ToDoItem, Error>
}

enum CoreDataServiceErrors {
    enum SaveError: Error {
        case failSave
    }
    enum LoadError: Error {
        case failLoad
    }
    enum AddError: Error {
        case failAdd
    }
    enum DeleteError: Error {
        case failDelete
    }
}
