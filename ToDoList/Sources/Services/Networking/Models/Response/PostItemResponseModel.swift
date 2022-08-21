//
//  PostItemResponseModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 18.08.2022.
//

import Foundation

struct PostItemResponseModel: Decodable {
    let element: ToDoItemNetworkModel
    let revision: Int32
    let status: String
}
