//
//  PatchItemsRequestNetworkingModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 19.08.2022.
//

import Foundation

struct PatchItemsRequestNetworkingModel: Encodable {
    private let list: [ToDoItemNetworkingModel]

    init(with items: [ToDoItem]) {
        list = items.map {
            ToDoItemNetworkingModel(from: $0)
        }
    }
}
