//
//  GetAllResponseNetworkingModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 17.08.2022.
//

import Foundation

struct GetListResponseNetworkingModel: Decodable {
    let list: [ToDoItemNetworkingModel]
    let revision: Int32
    let status: String
}
