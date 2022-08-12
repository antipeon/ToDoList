//
//  MockFileCacheService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 11.08.2022.
//

import Foundation
import CocoaLumberjack

final class MockFileCacheService: FileCacheService {
    let fileCache = FileCache()

    var toDoItems: [ToDoItem] {
        fileCache.toDoItems
    }

    /// synchronizes all the log writes
    private let logQueue = DispatchQueue(label: "logQ")

    /// maps filename to processSaveLoadQueue
    /// processSaveLoadQueue is concurrent with barrier on Save
    private var filenameToProcessSaveLoadQueue = [String: DispatchQueue]()

    /// maps filename to hardWorkInFileCacheQueue
    /// hardWorkInFileCacheQueue is concurrent with barrier on Save
    private var filenameToFileCacheWorkQueue = [String: DispatchQueue]()

    /// synchronizes filenameToHardWorkInFileCacheQueue dictionary
    /// synchronizes filenameToProcessSaveLoadQueue dictionary
    private let synchronizeDictionaryQueue = DispatchQueue(label: "syncDictionaryQ")

    /// item for last Save; synchronized with processSaveLoadQueue
    var currentSaveItem: DispatchWorkItem?

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.current.isMainThread)
        synchronizeDictionaryQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.initDictionariesForFileIfNeeded(filename: file)

            guard let processSaveLoadQ = self.filenameToProcessSaveLoadQueue[file] else {
                return
            }

            guard let fileCacheWorkQueue = self.filenameToFileCacheWorkQueue[file] else {
                return
            }

            processSaveLoadQ.async(flags: .barrier) { [weak self] in
                assert(!Thread.current.isMainThread)
                // cancel if previous save in queue
                if let currentSaveItem = self?.currentSaveItem {
        //            DDLogVerbose("canceled save operation: \(currentSaveItem)")
                    self?.logQueue.async {
                        let address = Unmanaged.passUnretained(currentSaveItem).toOpaque()
                        DDLogVerbose("canceled save operation: \(currentSaveItem) with address: \(address)")
                    }
                    currentSaveItem.cancel()
                }
                self?.currentSaveItem = DispatchWorkItem(flags: .barrier) {
                    assert(!Thread.current.isMainThread)

                    do {
                        try self?.fileCache.save(to: file)
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

                guard let currentSaveItem = self?.currentSaveItem else {
                    return
                }

                let address = Unmanaged.passUnretained(currentSaveItem).toOpaque()
                guard let logQueue = self?.logQueue else {
                    return
                }

                self?.currentSaveItem?.notify(queue: logQueue) { [currentSaveItem, address] in
                    DDLogVerbose("finished save operation: \(currentSaveItem) with address: \(address) - has \(currentSaveItem.isCancelled ? "" : "not") been canceled")
                }

                fileCacheWorkQueue.asyncAfter(deadline: .now() + Constants.saveDuration, execute: currentSaveItem)
            }
        }
    }

    private func initDictionariesForFileIfNeeded(filename: String) {
        if self.filenameToFileCacheWorkQueue[filename] == nil {
            self.filenameToFileCacheWorkQueue[filename] = DispatchQueue(
                label: "hardWorkInFileCacheQ for \(filename)",
                attributes: .concurrent
            )
        }

        if self.filenameToProcessSaveLoadQueue[filename] == nil {
            self.filenameToProcessSaveLoadQueue[filename] = DispatchQueue(
                label: "processSaveLoadQ for \(filename)",
                attributes: .concurrent
            )
        }
    }

    func load(from file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.current.isMainThread)

        synchronizeDictionaryQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.initDictionariesForFileIfNeeded(filename: file)

            guard let processSaveLoadQ = self.filenameToProcessSaveLoadQueue[file] else {
                return
            }

            guard let fileCacheWorkQueue = self.filenameToFileCacheWorkQueue[file] else {
                return
            }

            processSaveLoadQ.async { [weak self] in
                guard let self = self else {
                    return
                }

                fileCacheWorkQueue.asyncAfter(deadline: .now() + Constants.loadDuration) {
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
        static let loadDuration = TimeInterval(1)
        static let saveDuration = TimeInterval(15)
    }
}

extension ToDoItem {
    init(withId id: String) {
        self.init(id: id, text: "", priority: .normal, createdAt: .now)
    }
}
