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
    
    // MARK: - init
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
        setUpObserversForKeyboard()
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
    
    // MARK: - Landscape/Portrait Mode
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        prepareViewsAccordingToOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareViewsAccordingToOrientation()
    }
    
    private func prepareViewsAccordingToOrientation() {
        if traitCollection.verticalSizeClass == .compact {
            // landscape
            rootView.lowerSectionVstackView.isHidden = true
            rootView.deleteButton.isHidden = true
        } else {
            // normal
            rootView.lowerSectionVstackView.isHidden = false
            rootView.deleteButton.isHidden = false
        }
    }
    
    // MARK: - ToDoItemModule
    func addItem(_ item: ToDoItem?) throws {
        try module.addItem(item)
    }
    
    func deleteItem(_ item: ToDoItem?) throws {
        try module.deleteItem(item)
    }
    
    // MARK: - Keyboard
    private func setUpObserversForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            self.view.frame.origin.y = -keyboardSize.height
            NSLayoutConstraint.deactivate(rootView.viewTopAnchor)
            rootView.viewTopAnchor = rootView.vStackView.topAnchor.constraint(equalTo: rootView.layoutMarginsGuide.topAnchor, constant: keyboardSize.height)
            NSLayoutConstraint.activate(rootView.viewTopAnchor)
            rootView.updateConstraints()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        
        NSLayoutConstraint.deactivate(rootView.viewTopAnchor)
        rootView.viewTopAnchor = rootView.vStackView.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate(rootView.viewTopAnchor)
        rootView.updateConstraints()
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
