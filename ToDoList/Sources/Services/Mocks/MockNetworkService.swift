//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

final class MockNetworkService: NetworkService {
    // MARK: - Private vars
    private let queriesQueue = DispatchQueue(label: "queriesQ", attributes: .concurrent)

    // MARK: API
    func getAllToDoItems(completion: @escaping (Result<[ToDoItemModel], Error>) -> Void) {
        queriesQueue.asyncAfter(deadline: .now() + timeout()) { [weak self] in
            guard let self = self else {
                return
            }

            let data = self.performServerRequest()
            let json =  self.parseToJson(data: data)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                guard let items = self.jsonToItems(json: json) else {
                    completion(.failure(NetworkServiceError.failGetAll))
                    return
                }

                completion(.success(items))
            }
        }
    }

    func editToDoItem(_ item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        queriesQueue.asyncAfter(deadline: .now() + timeout(), flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let data = self.performServerRequest()
            let json =  self.parseToJson(data: data)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                guard let item = self.jsonToItem(json: json) else {
                    completion(.failure(NetworkServiceError.failEditItem))
                    return
                }

                completion(.success(item))
            }
        }
    }

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        queriesQueue.asyncAfter(deadline: .now() + timeout(), flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let data = self.performServerRequest()
            let json =  self.parseToJson(data: data)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                guard let item = self.jsonToItem(json: json) else {
                    completion(.failure(NetworkServiceError.failDeleteItem))
                    return
                }

                completion(.success(item))
            }
        }
    }

    func updateToDoItems(withItems items: [ToDoItemModel], completion: @escaping (Result<[ToDoItemModel], Error>) -> Void) {
        queriesQueue.asyncAfter(deadline: .now() + timeout(), flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let data = self.performServerRequest()
            let json =  self.parseToJson(data: data)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                guard let items = self.jsonToItems(json: json) else {
                    completion(.failure(NetworkServiceError.failUpdateItem))
                    return
                }

                completion(.success(items))
            }
        }
    }

    func addToDoItem(item: ToDoItemModel, completion: @escaping (Result<ToDoItemModel, Error>) -> Void) {
        queriesQueue.asyncAfter(deadline: .now() + timeout(), flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let data = self.performServerRequest()
            let json =  self.parseToJson(data: data)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                guard let item = self.jsonToItem(json: json) else {
                    completion(.failure(NetworkServiceError.failAddItem))
                    return
                }

                completion(.success(item))
            }
        }
    }

    // MARK: - Stubs
    private func performServerRequest() -> Data {
        Data()
    }

    private func parseToJson(data: Data) -> Any {
        return 0
    }

    private func jsonToItems(json: Any) -> [ToDoItemModel]? {
        Constants.MockData.items
    }

    private func jsonToItem(json: Any) -> ToDoItemModel? {
        Constants.MockData.items.first
    }

    // MARK: - Helpers
    private func timeout() -> TimeInterval {
        TimeInterval.random(in: Constants.timeoutLowerBound..<Constants.timeoutHigherBound)
    }

    private enum Constants {
        static let filename = "queries"
        static let timeoutLowerBound: TimeInterval = 1
        static let timeoutHigherBound: TimeInterval = 3

        enum MockData {
            static let items = [
                ToDoItemModel(text: "homework", priority: .high, createdAt: .now, modifiedAt: .now),
                ToDoItemModel(text: "chill", priority: .low, createdAt: .now)
            ]
        }
    }
}
