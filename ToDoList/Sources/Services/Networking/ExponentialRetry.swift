//
//  ExponentialRetry.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 20.08.2022.
//

import Foundation
import CocoaLumberjack

final class ExponentialRetry<Data> {

    // MARK: - Private vars
    private let networkService: NetworkService
    private var work: (Data, @escaping (Result<Data, Error>) -> Void) -> Void
    private var completion: (Data) -> Void
    private let dataProvider: () -> Data

    private var isMaxDelayReached = false
    private var delay: TimeInterval
    private let delayAccessSynchronizer = DispatchSemaphore(value: 1)

    private let minDelay: TimeInterval = 2
    private let maxDelay: TimeInterval = 120
    private let factor = 1.5
    private let jitter: Double = 0.05

    private var item: DispatchWorkItem?
    private let itemAccessSynchronizer = DispatchSemaphore(value: 1)

    private let retryQueue = DispatchQueue(label: "retry", attributes: .concurrent)

    // MARK: - init
    init(
        networkService: NetworkService,
        work: @escaping (Data, @escaping (Result<Data, Error>) -> Void) -> Void,
        onWorkSuccess completion: @escaping (Data) -> Void,
        dataProvider: @escaping () -> Data
    ) {
        self.networkService = networkService
        self.work = work
        self.delay = minDelay
        self.completion = completion
        self.dataProvider = dataProvider
    }

    // MARK: - API
    func run() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }

            self.itemAccessSynchronizer.wait()
            if let item = self.item {
                item.cancel()
            }
            self.itemAccessSynchronizer.signal()

            let workItem = DispatchWorkItem(qos: .background, flags: .barrier) { [weak self] in
                guard let self = self else {
                    return
                }

                self.itemAccessSynchronizer.wait()
                if let curItem = self.item, curItem.isCancelled {
                    self.itemAccessSynchronizer.signal()
                    return
                }
                self.itemAccessSynchronizer.signal()

                self.runWork()
            }

            self.itemAccessSynchronizer.wait()
            self.item = workItem
            self.itemAccessSynchronizer.signal()

            self.delayAccessSynchronizer.wait()
            let nextDelay = self.delayWithJitter(self.delay)
            DDLogVerbose("scheduling next retry in \(nextDelay) seconds...")
            self.retryQueue.asyncAfter(deadline: .now() + nextDelay, execute: workItem)
            self.delayAccessSynchronizer.signal()
        }

    }

    // MARK: - Private funcs
    private func incrementDelay() {
        if delay * factor > maxDelay {
            isMaxDelayReached = true
        }

        delay = isMaxDelayReached ? delay : delay * factor
    }

    private func delayWithJitter(_ delay: TimeInterval) -> TimeInterval {
        let lowerBound = 1 - jitter
        let higherBound = 1 + jitter
        let coeff = Double.random(in: lowerBound...higherBound)
        return delay * coeff
    }

    private func runWork() {
        self.work(self.dataProvider()) { result in
            assert(Thread.isMainThread)
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else {
                    return
                }

                switch result {
                case .success(let data):
                    DDLogVerbose("retry successful")

                    self.delayAccessSynchronizer.wait()
                    self.delay = self.minDelay
                    self.delayAccessSynchronizer.signal()

                    DispatchQueue.main.async {
                        self.completion(data)
                    }

                case .failure:
                    DDLogVerbose("retry failed")

                    self.delayAccessSynchronizer.wait()
                    self.incrementDelay()
                    self.delayAccessSynchronizer.signal()

                    self.run()
                }
            }
        }
    }
}
