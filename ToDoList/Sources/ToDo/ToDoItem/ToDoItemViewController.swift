//
//  ToDoItemViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit

protocol DismissableModule: UIViewController {
    func dismiss()
}

extension DismissableModule {
    func dismiss() {
        dismiss(animated: true)
    }
}

protocol ToDoItemModule: DismissableModule {
    func addItem(_ item: ToDoItem?)
    func deleteItem(_ item: ToDoItem?)
}

class ToDoItemViewController: UIViewController, ToDoItemModule {
    
    // MARK: - Views
    private lazy var toDoItemView = ToDoItemView(module: self, item: item)
    
    private lazy var item: ToDoItem? = fileCache.toDoItems.last
    
    // MARK: - Properties
    private let fileCache: FileCache
    
    // MARK: - Init
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        try? fileCache.load(from: filename)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    override func loadView() {
        view = toDoItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpToHideKeyboardOnTapView()
    }
    
    // MARK: - Portrait Mode
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
       AppUtility.lockOrientation(.portrait)
       // Or to rotate and lock
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
       
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       
       // Don't forget to reset when view is being removed
       AppUtility.lockOrientation(.all)
   }
    
    // MARK: - ToDoItemModule
    func addItem(_ item: ToDoItem?) {
        guard let item = item else {
            return
        }
        fileCache.remove(item)
        fileCache.add(item)
        try? fileCache.save(to: filename)
    }
    
    func deleteItem(_ item: ToDoItem?) {
        guard let item = item else {
            return
        }
        fileCache.remove(item)
        try? fileCache.save(to: filename)
    }
    
    private let filename = "toDoItems"
}

extension UIViewController {
    func setUpToHideKeyboardOnTapView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
