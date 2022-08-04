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

protocol ToDoItemModule: DismissableModule, UITextViewDelegate {
    func addItem(_ item: ToDoItem?)
    func deleteItem(_ item: ToDoItem?)
}

class ToDoItemViewController: UIViewController, ToDoItemModule {
    
    // MARK: - Views
    private lazy var toDoItemView = ToDoItemView(module: self, item: item)
    
    private lazy var item: ToDoItem? = fileCache.toDoItems.last
    
    // MARK: - Properties
    private let fileCache: FileCache
    
    private var rootView: ToDoItemView {
        guard let view = view as? ToDoItemView else {
            fatalError("view not set")
        }
        return view
    }
    
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
    
    
    
    // MARK: - UINavigationController
    override var navigationItem: UINavigationItem {
        titleItem
    }
    
    private lazy var saveButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }()
    
    private lazy var titleItem: UINavigationItem = {
        let item = UINavigationItem(title: "Дело")
        item.rightBarButtonItem = saveButton
        item.leftBarButtonItem = cancelButton
        return item
    }()
    
    // MARK: - TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  textView.textColor == ToDoItemView.Constants.Colors.labelTertiary {
            textView.text = nil
            textView.textColor = ToDoItemView.Constants.Colors.labelPrimary
        } else {
            // idk why this === deselection
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            rootView.setUpTextViewPlaceholder(textView)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        rootView.updateViewsDisplay()
        rootView.setNeedsDisplay()
    }
    
    @objc private func save() {
        rootView.save()
    }
    
    @objc private func cancel() {
        rootView.cancel()
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
