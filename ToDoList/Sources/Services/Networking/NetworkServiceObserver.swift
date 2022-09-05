//
//  NetworkServiceObserver.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 21.08.2022.
//

import Foundation

protocol NetworkServiceObserverDelegate: AnyObject {
    func didNetworkWorkStart()
    func didNetworkWorkFinish()
}

protocol NetworkServiceObserver: AnyObject {
    func didRequestStart()
    func didRequestFinish()
    var delegate: NetworkServiceObserverDelegate? { get set }
}
