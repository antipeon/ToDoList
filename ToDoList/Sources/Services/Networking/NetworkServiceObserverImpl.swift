//
//  NetworkServiceObserverImpl.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 21.08.2022.
//

import Foundation

class NetworkingServiceObserverImpl: NetworkServiceObserver {

    // MARK: - Properties
    private var counter = 0
    private let lock = DispatchSemaphore(value: 1)

    weak var delegate: NetworkServiceObserverDelegate?

    func didRequestStart() {
        lock.wait()
        defer { lock.signal() }
        counter += 1

        guard counter == 1 else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.didNetworkWorkStart()
        }
    }

    func didRequestFinish() {
        lock.wait()
        defer { lock.signal() }
        counter -= 1

        guard counter == 0 else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.didNetworkWorkFinish()
        }
    }
}
