//
//  GetListResponseModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 17.08.2022.
//

import Foundation

struct GetListResponseModel: Decodable {
    let list: [ToDoItemNetworkModel]
    let revision: Int32
    let status: String
}
