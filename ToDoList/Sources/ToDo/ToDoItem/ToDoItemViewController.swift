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
    func addItem(_ item: ToDoItem?) throws
    func deleteItem(_ item: ToDoItem?) throws
}



class ToDoItemViewController: UIViewController, ToDoItemModule, UITextViewDelegate {
    
    // MARK: - Views
    private lazy var toDoItemView = ToDoItemView(module: self, item: item)
    
    // MARK: - Properties
    private let module: ToDoItemModule
    private let item: ToDoItem?
    
    private var rootView: ToDoItemView {
        guard let view = view as? ToDoItemView else {
            fatalError("view not set")
        }
        return view
    }
    
    // MARK: - Init
    init(module: ToDoItemModule, item: ToDoItem?) {
        self.module = module
        self.item = item
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
        setUpToHideKeyboardOnTapView()
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
        if  textView.textColor == AppConstants.Colors.labelTertiary {
            textView.text = nil
            textView.textColor = AppConstants.Colors.labelPrimary
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
    
    @objc private func save() throws {
        try rootView.save()
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
    func addItem(_ item: ToDoItem?) throws {
        try module.addItem(item)
    }
    
    func deleteItem(_ item: ToDoItem?) throws {
        try module.deleteItem(item)
    }
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
