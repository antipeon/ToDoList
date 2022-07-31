//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import XCTest
@testable import ToDoList

class ToDoListTests: XCTestCase {
    
    let firstItem = ToDoItem(text: "buy milk", priority: .low, createdAt: .now, done: false)
    
    let secondItem = ToDoItem(id: "customId", text: "do homework", priority: .normal, createdAt: .now.incrementedBy(days: 1), deadline: .now.incrementedBy(days: 7), done: false, modifiedAt: .now.incrementedBy(days: 1))

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    
    // MARK: - ToDoItem tests
    func testParseToJsonThenInitFromJson_ObjectsAreEqual1() {
        let jsonForItem = firstItem.json
        let item = ToDoItem.parse(json: jsonForItem)
        XCTAssertTrue(ToDoItem.haveSameProperties(firstItem, item))
    }
    
    func testParseToJsonThenInitFromJson_ObjectsAreEqual2() {
        let jsonForItem = secondItem.json
        let item = ToDoItem.parse(json: jsonForItem)
        XCTAssertTrue(ToDoItem.haveSameProperties(secondItem, item))
    }
    
    // MARK: - FileCache tests
    func testAddItem() {
        let fileCache = FileCache()
        XCTAssertTrue(fileCache.add(firstItem))
        XCTAssertFalse(fileCache.add(firstItem))
        guard let toDoItemsFirst = fileCache.toDoItems.first else {
            XCTFail()
            return
        }
        XCTAssertTrue(ToDoItem.haveSameProperties(toDoItemsFirst, firstItem))
    }
    
    func testRemoveItem() {
        let fileCache = FileCache()
        XCTAssertNil(fileCache.remove(firstItem))
        fileCache.add(firstItem)
        XCTAssertNil(fileCache.remove(secondItem))
        XCTAssertTrue(ToDoItem.haveSameProperties(fileCache.remove(firstItem), firstItem))
    }
    
    func testSaveToFileThenLoadFromFile_ObjectsAreEqual() throws {
        let fileCache = FileCache()
        fileCache.add(firstItem)
        fileCache.add(secondItem)
        
        let fileName = "file"
        try fileCache.save(to: fileName)
        
        XCTAssertEqual(fileCache.toDoItems.count, 2)
        
        let fileCache1 = FileCache()
        try fileCache1.load(from: fileName)
        
        XCTAssertTrue(FileCache.haveItemsWithSameProperties(fileCache, fileCache1))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension Date {
    func incrementedBy(days: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: days), to: .now)!
    }
}

extension ToDoItem {
    static func haveSameProperties(_ lhs: ToDoItem?, _ rhs: ToDoItem?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else {
            if lhs == nil && rhs == nil {
                return true
            }
            if lhs == nil && rhs != nil {
                return false
            }
            if lhs != nil && rhs == nil {
                return false
            }
            fatalError("can't reach here")
        }
        
        return lhs.id == rhs.id && lhs.text == rhs.text &&
        lhs.priority == rhs.priority && lhs.createdAt == rhs.createdAt &&
        lhs.deadline == rhs.deadline && lhs.done == rhs.done && lhs.modifiedAt == rhs.modifiedAt
    }
}

extension FileCache {
    static func haveItemsWithSameProperties(_ lhs: FileCache, _ rhs: FileCache) -> Bool {
        guard lhs.toDoItems.count == rhs.toDoItems.count else {
            return false
        }
        for i in 0..<lhs.toDoItems.count {
            if !ToDoItem.haveSameProperties(lhs.toDoItems[i], rhs.toDoItems[i]) {
                return false
            }
        }
        return true
    }
}
