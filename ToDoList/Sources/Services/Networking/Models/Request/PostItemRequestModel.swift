//
//  PostItemRequestModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 18.08.2022.
//

import Foundation

struct PostItemRequestModel: Encodable {
    private let element: ToDoItemNetworkModel

    init(from item: ToDoItemModel) {
        element = ToDoItemNetworkModel(from: item)
    }
}
