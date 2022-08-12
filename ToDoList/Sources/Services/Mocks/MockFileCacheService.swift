//
//  MockFileCacheService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation

final class MockFileCacheService: FileCacheService {
    let fileCache = FileCache()

    var toDoItems: [ToDoItem] {
        fileCache.toDoItems
    }

    private let queue = DispatchQueue(label: "concurrentQ", attributes: .concurrent)

    var currentSaveItem: DispatchWorkItem?

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.current.isMainThread)

        // cancel if previous save in queue
        currentSaveItem?.cancel()

        currentSaveItem = DispatchWorkItem(flags: .barrier) {
            assert(!Thread.current.isMainThread)

            do {
                try self.fileCache.save(to: file)
                DispatchQueue.main.async {
                    assert(Thread.current.isMainThread)
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    assert(Thread.current.isMainThread)
                    completion(.failure(FileCacheServiceErrors.SaveError.failSave))
                }
            }
        }

        guard let currentSaveItem = currentSaveItem else {
            return
        }

        queue.asyncAfter(deadline: .now() + Constants.timeout, execute: currentSaveItem)
    }

    func load(from file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.current.isMainThread)

        queue.asyncAfter(deadline: .now() + Constants.timeout) {
            assert(!Thread.current.isMainThread)
            do {
                do {
                    try self.fileCache.load(from: file)
                } catch {
                    let nsError = error as NSError
                    if nsError.domain == NSCocoaErrorDomain, nsError.code == NSFileReadNoSuchFileError {
                        DispatchQueue.main.async {
                            assert(Thread.current.isMainThread)
                            completion(.failure(FileCacheServiceErrors.LoadError.failLoadNoSuchFile))
                        }
                        return
                    } else {
                        throw error
                    }
                }
                DispatchQueue.main.async {
                    assert(Thread.current.isMainThread)
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    assert(Thread.current.isMainThread)
                    completion(.failure(FileCacheServiceErrors.LoadError.failLoad))
                }
            }
        }
    }

    func add(_ newItem: ToDoItem) {
        assert(Thread.current.isMainThread)
        fileCache.add(newItem)
    }

    func delete(id: String) {
        assert(Thread.current.isMainThread)
        let itemWithId = ToDoItem(withId: id)
        fileCache.remove(itemWithId)
    }

    private enum Constants {
        static let timeout = TimeInterval(6)
    }
}

extension ToDoItem {
    init(withId id: String) {
        self.init(id: id, text: "", priority: .normal, createdAt: .now)
    }
}
