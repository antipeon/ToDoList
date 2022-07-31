//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit

protocol ToDoListModule: UIViewController {
    func showAddItem()
}

class ToDoListViewController: UIViewController, ToDoListModule {
    
    private let fileCache = FileCache()
    private lazy var toDoListView = ToDoListView(module: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        view.backgroundColor = .white
    }
    
    override func loadView() {
        view = toDoListView
    }
    
    func showAddItem() {
        let toDoItem = ToDoItemViewController(fileCache: fileCache)
        self.navigationController?.navigationBar.barTintColor = .cyan
        toDoItem.modalPresentationStyle = .automatic
        navigationController?.present(toDoItem, animated: true)
        
    }
}
