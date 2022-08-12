//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

final class MockNetworkService: NetworkService {
    let model: ToDoListModel

    init() throws {
        try model = ToDoListModel()
    }

    func getAllToDoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            completion(.success(self.model.items))
        }
    }

    func editToDoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            do {
                try self.model.addItem(item)
                completion(.success(item))
            } catch {
                completion(.failure(NetworkServiceError.failEditItem))
            }
        }
    }

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            do {
                let item = ToDoItem(withId: id)
                try self.model.deleteItem(item)
                completion(.success(item))
            } catch {
                completion(.failure(NetworkServiceError.failDeleteItem))
            }
        }
    }
}
