//
//  ToDoItemViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit
import CoreData

protocol DismissableModule: UIViewController {
    func dismiss()
}

extension DismissableModule {
    func dismiss() {
        dismiss(animated: true)
    }
}

protocol ToDoItemModule: DismissableModule {
    func addItem(_ item: ToDoItemModel?, isNew: Bool)
    func deleteItem(_ item: ToDoItemModel?)
}

protocol ToDoItemViewControllerDelegate: AnyObject {
    func didFinish(controller: ToDoItemViewController, didSave: Bool)
}

final class ToDoItemViewController: UIViewController, ToDoItemModule, UITextViewDelegate {

    // MARK: - Views
    private lazy var toDoItemView = ToDoItemView(module: self, item: item, isNewItem: isNewItem)

    // MARK: - Properties
    private let module: ToDoItemModule
    private let item: ToDoItem?
    private(set) var context: NSManagedObjectContext!
    private let isNewItem: Bool

    private var rootView: ToDoItemView {
        guard let view = view as? ToDoItemView else {
            fatalError("view not set")
        }
        return view
    }

    var delegate: ToDoItemViewControllerDelegate?

    // MARK: - init
    init(module: ToDoItemModule, item: ToDoItem?, context: NSManagedObjectContext, isNewItem: Bool) {
        self.module = module
        self.item = item
        self.context = context
        self.isNewItem = isNewItem
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
            textView.selectedTextRange = textView.textRange(
                from: textView.beginningOfDocument,
                to: textView.endOfDocument
            )
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
    func addItem(_ item: ToDoItemModel?, isNew: Bool) {
        module.addItem(item, isNew: isNew)
    }

    func deleteItem(_ item: ToDoItemModel?) {
        module.deleteItem(item)
    }

    // MARK: - Keyboard
    private func setUpObserversForKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardValue.cgRectValue.height
        NSLayoutConstraint.deactivate(rootView.viewBottomAnchor)
        rootView.viewBottomAnchor = rootView.vStackView.bottomAnchor.constraint(
            equalTo: rootView.safeAreaLayoutGuide.bottomAnchor,
            constant: -keyboardHeight
        )
        NSLayoutConstraint.activate(rootView.viewBottomAnchor)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        NSLayoutConstraint.deactivate(rootView.viewBottomAnchor)
        rootView.viewBottomAnchor = rootView.vStackView.bottomAnchor.constraint(
            equalTo: rootView.safeAreaLayoutGuide.bottomAnchor,
            constant: -ToDoItemView.Constants.defaultOffset
        )
        NSLayoutConstraint.activate(rootView.viewBottomAnchor)
    }
}

extension UIViewController {
    func setUpToHideKeyboardOnTapView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
