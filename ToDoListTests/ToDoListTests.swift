//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import XCTest
@testable import ToDoList

class ToDoListTests: XCTestCase {

    let firstItem = ToDoItemModel(text: "buy milk", priority: .low, createdAt: .now, done: false)

    let secondItem = ToDoItemModel(
        id: "customId",
        text: "do homework",
        priority: .normal,
        createdAt: .now.incrementedBy(days: 1),
        deadline: .now.incrementedBy(days: 7),
        done: false,
        modifiedAt: .now.incrementedBy(days: 1)
    )

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
    }

    // MARK: - ToDoItem tests
    func testParseToJsonThenInitFromJson_ObjectsAreEqual1() {
        let jsonForItem = firstItem.json
        let item = ToDoItemModel.parse(json: jsonForItem)
        XCTAssertTrue(ToDoItemModel.haveSameProperties(firstItem, item))
    }

    func testParseToJsonThenInitFromJson_ObjectsAreEqual2() {
        let jsonForItem = secondItem.json
        let item = ToDoItemModel.parse(json: jsonForItem)
        XCTAssertTrue(ToDoItemModel.haveSameProperties(secondItem, item))
    }

    // MARK: - FileCache tests
    func testAddItem() {
        let fileCache = FileCache()
        XCTAssertTrue(fileCache.add(firstItem))
        XCTAssertFalse(fileCache.add(firstItem))
        guard let toDoItemsFirst = fileCache.toDoItems.first else {
            XCTFail("no items in cache")
            return
        }
        XCTAssertTrue(ToDoItemModel.haveSameProperties(toDoItemsFirst, firstItem))
    }

    func testRemoveItem() {
        let fileCache = FileCache()
        XCTAssertNil(fileCache.remove(firstItem))
        fileCache.add(firstItem)
        XCTAssertNil(fileCache.remove(secondItem))
        XCTAssertTrue(ToDoItemModel.haveSameProperties(fileCache.remove(firstItem), firstItem))
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

extension ToDoItemModel {
    static func haveSameProperties(_ lhs: ToDoItemModel?, _ rhs: ToDoItemModel?) -> Bool {
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
        for index in 0..<lhs.toDoItems.count {
            if !ToDoItem.haveSameProperties(lhs.toDoItems[index], rhs.toDoItems[index]) {
                return false
            }
        }
        return true
    }
}
