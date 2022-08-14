//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

final class MockNetworkService: NetworkService {
    
    // MARK: API
    func getAllToDoItems() async throws -> [ToDoItem] {
        try await Task.sleep(seconds: timeout())
        async let items = fetchItems()
        guard let items = await items else {
            throw NetworkServiceError.failGetAll
        }
        return items
    }

    func editToDoItem(_ item: ToDoItem) async throws -> ToDoItem {
        
        try await Task.sleep(seconds: timeout())
        async let item = editItem()
        guard let item = await item else {
            throw NetworkServiceError.failEditItem
        }
        return item
    }

    func deleteToDoItem(at id: String) async throws -> ToDoItem {
        
        try await Task.sleep(seconds: timeout())
        async let item = deleteItem()
        guard let item = await item else {
            throw NetworkServiceError.failDeleteItem
        }
        return item
        
    }

    func updateToDoItems(withItems: [ToDoItem]) async throws -> [ToDoItem] {
        try await Task.sleep(seconds: timeout())
        async let items = fetchItems()
        guard let items = await items else {
            throw NetworkServiceError.failUpdateItem
        }
        return items
    }

    func addToDoItem(item: ToDoItem) async throws -> ToDoItem {
        try await Task.sleep(seconds: timeout())
        async let item = addItem()
        guard let item = await item else {
            throw NetworkServiceError.failAddItem
        }
        return item
    }

    // MARK: - Stubs
    private func performServerRequest() -> Data {
        Data()
    }

    private func parseToJson(data: Data) -> Any {
        return 0
    }

    private func jsonToItems(json: Any) -> [ToDoItem]? {
        Constants.MockData.items
    }

    private func jsonToItem(json: Any) -> ToDoItem? {
        Constants.MockData.items.first
    }
    
    // MARK: - Private funcs
    private func fetchItems() -> [ToDoItem]? {
        stubGettingItems()
    }
    
    private func deleteItem() -> ToDoItem? {
        stubGettingItem()
    }
    
    private func addItem() -> ToDoItem? {
        stubGettingItem()
    }
    
    private func editItem() -> ToDoItem? {
        stubGettingItem()
    }
    
    private func updateItems() -> [ToDoItem]? {
        stubGettingItems()
    }
    
    private func stubGettingItem() -> ToDoItem? {
        let data = self.performServerRequest()
        let json =  self.parseToJson(data: data)
        return jsonToItem(json: json)
    }
    
    private func stubGettingItems() -> [ToDoItem]? {
        let data = performServerRequest()
        let json = parseToJson(data: data)
        return jsonToItems(json: json)
    }

    // MARK: - Helpers
    private func timeout() -> Double {
        Double.random(in: Constants.timeoutLowerBound..<Constants.timeoutHigherBound)
    }

    private enum Constants {
        static let filename = "queries"
        static let timeoutLowerBound: Double = 1
        static let timeoutHigherBound: Double = 3

        enum MockData {
            static let items = [
                ToDoItem(text: "homework", priority: .high, createdAt: .now, modifiedAt: .now),
                ToDoItem(text: "chill", priority: .low, createdAt: .now)
            ]
        }
    }
}


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
