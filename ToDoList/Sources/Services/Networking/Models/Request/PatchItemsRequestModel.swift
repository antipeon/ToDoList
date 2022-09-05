//
//  PatchItemsRequestModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 19.08.2022.
//

import Foundation

struct PatchItemsRequestModel: Encodable {
    private let list: [ToDoItemNetworkModel]

    init(with items: [ToDoItemModel]) {
        list = items.map {
            ToDoItemNetworkModel(from: $0)
        }
    }
}
