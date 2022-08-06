//
//  ToDoListModel.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import Foundation

protocol ToDoListModelDelegate {
    func didAddItem()
    func didDeleteItem()
}

class ToDoListModel {
    // MARK: - Private vars
    private static let fileName = "toDoItems"
    private var fileCache: FileCache
    
    // MARK: - API
    var items: [ToDoItem] {
        fileCache.toDoItems
    }
    
    var delegate: ToDoListModelDelegate?
    
    init() throws {
        fileCache = FileCache()
        try fileCache.load(from: ToDoListModel.fileName)
    }
    
    func addItem(_ item: ToDoItem?) throws {
        defer {
            delegate?.didAddItem()
        }
        guard let item = item else {
            return
        }
        fileCache.remove(item)
        fileCache.add(item)
        try fileCache.save(to: ToDoListModel.fileName)
    }
    
    func deleteItem(_ item: ToDoItem?) throws {
        defer {
            delegate?.didDeleteItem()
        }
        guard let item = item else {
            return
        }
        fileCache.remove(item)
        try fileCache.save(to: ToDoListModel.fileName)
    }
}
