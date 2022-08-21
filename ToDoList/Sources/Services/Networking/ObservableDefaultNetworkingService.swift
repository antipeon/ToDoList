//
//  ObservableDefaultNetworkingService.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 21.08.2022.
//

import Foundation

class ObservableDefaultNetworkingService: NetworkService {

    // MARK: - Public vars
    weak var observer: NetworkServiceObserver?

    // MARK: - Private vars
    private let networkService: DefaultNetworkService

    // MARK: - init
    init(networkService: DefaultNetworkService) {
        self.networkService = networkService
    }

    // MARK: - API
    func getAllToDoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        doWithNotification(work: getAllToDoItems, completion: completion)
    }

    func editToDoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        doWithNotification(work: networkService.editToDoItem, completion: completion, item)
    }

    func deleteToDoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        doWithNotification(work: networkService.deleteToDoItem, completion: completion, id)
    }

    func updateToDoItems(withItems items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        doWithNotification(work: networkService.updateToDoItems, completion: completion, items)
    }

    func addToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        doWithNotification(work: networkService.addToDoItem, completion: completion, item)
    }

    // MARK: - Private funcs
    private func doWithNotification<Arg, T>(
        work: @escaping (_ arg: Arg, _ completion: @escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<T, Error>) -> Void,
        _ arg: Arg
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }

            self.observer?.didRequestStart()

            work(arg) { result in
                assert(Thread.isMainThread)

                completion(result)

                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.observer?.didRequestFinish()
                }
            }
        }
    }

    private func doWithNotification<T>(
        work: @escaping (_ completion: @escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }

            self.observer?.didRequestStart()

            work { result in
                assert(Thread.isMainThread)

                completion(result)

                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.observer?.didRequestFinish()
                }
            }
        }
    }
}
