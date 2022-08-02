//
//  FileCache.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import Foundation

class FileCache {
    private(set) var toDoItems = [ToDoItem]()
    
    var delegate: ModelObserver?
    
    /// Adds item to collection if not present
    /// - Parameter item: Item to add
    /// - Returns: true if successfully added; false otherwise
    @discardableResult func add(_ item: ToDoItem) -> Bool {
        defer {
            delegate?.didAddItem()
        }
        
        if toDoItems.index(matching: item) != nil {
            return false
        }
        toDoItems.append(item)
        return true
    }
    
    /// Removes item from collection if present
    /// - Parameter item: Item to remove
    /// - Returns: Removed item; nil otherwise
    @discardableResult func remove(_ item: ToDoItem) -> ToDoItem? {
        defer {
            delegate?.didRemoveItem()
        }
        
        guard let index = toDoItems.index(matching: item) else {
            return nil
        }
        return toDoItems.remove(at: index)
    }
    
    /// Saves collection to file
    /// - Parameter fileName: name of file to save to
    func save(to fileName: String) throws {
        defer {
            delegate?.didSave()
        }
        
        let toDoItemsJsons = toDoItems.map {
            $0.json
        }
        
        guard JSONSerialization.isValidJSONObject(toDoItemsJsons), let jsonData = try? JSONSerialization.data(withJSONObject: toDoItemsJsons, options: .prettyPrinted) else {
            throw FileCacheError.jsonConversion
        }
        
        let fileUrl = fileInDocumentDir(with: fileName)
        try jsonData.write(to: fileUrl)
    }
    
    /// Loads collection from file
    /// - Parameter fileName: name of file to load from
    func load(from fileName: String) throws {
        defer {
            delegate?.didLoad()
        }
        
        let fileUrl = fileInDocumentDir(with: fileName)
        
        let jsonData = try Data(contentsOf: fileUrl)

        let decodedObject = try JSONSerialization.jsonObject(with: jsonData)
        
        guard let dictionaries = decodedObject as? [Any] else {
            throw FileCacheError.jsonDecode
        }
        
        let toDoItems: [ToDoItem] = try dictionaries
            .reduce(into: [], { toDoItems, dictionary in
                guard let item = ToDoItem.parse(json: dictionary) else {
                    throw FileCacheError.jsonDecode
                }
                
                toDoItems.append(item)
            })
        
        self.toDoItems = toDoItems
    }
    
    
    // MARK: - Helpers
    private func fileInDocumentDir(with name: String) -> URL {
        documentDir.appendingPathComponent(name)
    }
    
    private var documentDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    enum FileCacheError: Error {
        case jsonConversion
        case jsonDecode
    }
}

extension FileCache: Equatable {
    static func == (lhs: FileCache, rhs: FileCache) -> Bool {
        lhs.toDoItems == rhs.toDoItems
    }
}

extension FileCache.FileCacheError {
    public var description: String {
        switch self {
        case .jsonConversion:
            return "can't serialize to json"
        case .jsonDecode:
            return "can't decode json"
        }
    }
}

protocol ModelObserver {
    func didAddItem()
    func didRemoveItem()
    func didSave()
    func didLoad()
}
