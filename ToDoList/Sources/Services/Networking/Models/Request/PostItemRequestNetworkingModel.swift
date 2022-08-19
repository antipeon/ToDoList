//
//  PostItemRequestNetworkingModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 18.08.2022.
//

import Foundation

struct PostItemRequestNetworkingModel: Encodable {
    private let element: ToDoItemNetworkingModel

    init(from item: ToDoItem) {
        element = ToDoItemNetworkingModel(from: item)
    }
}
