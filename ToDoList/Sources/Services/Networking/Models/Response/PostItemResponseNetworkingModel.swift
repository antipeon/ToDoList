//
//  PostItemResponseNetworkingModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 18.08.2022.
//

import Foundation

struct PostItemResponseNetworkingModel: Decodable {
    let element: ToDoItemNetworkingModel
    let revision: Int32
    let status: String
}
