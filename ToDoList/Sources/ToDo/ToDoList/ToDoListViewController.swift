//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit
import CocoaLumberjack

protocol ToDoListModule: ToDoItemModule {
    var doneItemsCount: Int { get }
    var notDoneItems: [ToDoItem] { get }
}

final class ToDoListViewController: UIViewController, ToDoListModule,
                                        ToDoListModelDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: - init
    init(model: ToDoListModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

        model.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private vars
    private var rootView: ToDoListView {
        guard let view = view as? ToDoListView else {
            fatalError("view \(String(describing: view)) not initialised")
        }
        return view
    }
    private lazy var toDoListView = ToDoListView(module: self)

    private let model: ToDoListModel

    private var showOnlyNotDone = true {
        didSet {
            // indexpath to insert
            let indexes = model.items
                .indices
                .filter {
                    model.items[$0].done
                }
                .map {
                    IndexPath(row: $0, section: 0)
                }

            if showOnlyNotDone {
                rootView.deleteRows(at: indexes, with: .fade)
            } else {
                rootView.insertRows(at: indexes, with: .fade)
            }
        }
    }

    private var displayedItems: [ToDoItem] {
        (showOnlyNotDone ? notDoneItems : model.items)
    }

    private var swipedRow: IndexPath?

    // MARK: Views
    private lazy var addNewItemButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .large)
        let buttonImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addEmptyItem), for: .touchUpInside)
        return button
    }()

    // MARK: - UIViewController
    override func loadView() {
        super.loadView()
        view = toDoListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAddNewItemButton()

        rootView.register(Header.self, forHeaderFooterViewReuseIdentifier: Header.Constants.reuseIdentifier)
        rootView.register(LastCell.self, forCellReuseIdentifier: LastCell.Constants.reuseIdentifier)
    }

    // MARK: - ToDoListModule
    var doneItemsCount: Int {
        model.items
            .filter {
                $0.done
            }
            .count
    }

    var notDoneItems: [ToDoItem] {
        model.items
            .filter {
                !$0.done
            }
    }

    func addItem(_ item: ToDoItem?) throws {
        DDLogVerbose("trying to add item...")

        // TODO: fix this shit
        try model.addItem(item)
        DDLogInfo("item added: \(String(describing: item))")
    }

    func deleteItem(_ item: ToDoItem?) throws {
        DDLogVerbose("trying to delete item...")
        // TODO: fix this shit
        try model.deleteItem(item)
        DDLogInfo("item deleted: \(String(describing: item)) deleted")
    }

    func didDeleteItem() {
        updateViews()
    }

    func didAddItem() {
        updateViews()
    }

    // MARK: Actions
    @objc private func toggleItemsShowOption(_ button: UIButton) {
        showOnlyNotDone.toggle()
        button.setTitle(showOnlyNotDone ? "Показать" : "Скрыть", for: .normal)
    }

    @objc private func addEmptyItem() {
        presentToDoItemView(with: nil)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView.isLastRowAt(indexPath) {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.isLastRowAt(indexPath) {
            return
        }

        let item = displayedItems[indexPath.row]
        presentToDoItemView(with: item)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Header.Constants.reuseIdentifier)
        guard let header = view as? Header else {
            return view
        }

        header.doneItemsCountLabel.text = "Выполнено – \(doneItemsCount)"
        header.showDoneItemsButton.setTitle(showOnlyNotDone ? "Показать" : "Скрыть", for: .normal)
        header.showDoneItemsButton.addTarget(self, action: #selector(toggleItemsShowOption), for: .touchUpInside)
        return header
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        swipedRow = indexPath
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        swipedRow = nil
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Constants.reuseId, for: indexPath)

        guard let cell = cell as? Cell else {
            return cell
        }

        if tableView.isLastRowAt(indexPath) {
            let lastCell = tableView.dequeueReusableCell(
                withIdentifier: LastCell.Constants.reuseIdentifier,
                for: indexPath
            )
            guard let lastCell = lastCell as? LastCell else {
                return lastCell
            }
            return lastCell
        }

        let item = displayedItems[indexPath.row]

        cell.setUpCell(with: item)

        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView.isLastRowAt(indexPath) {
            return nil
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    // remove default trailing action = delete
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView.isLastRowAt(indexPath) {
            return nil
        }
        let item = displayedItems[indexPath.row]
        if item.done {
            return nil
        }
        let config = UISwipeActionsConfiguration(actions: [doneAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    // MARK: - SwipeActions
    lazy var deleteAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.deleteSwipedItem()
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .red
        return action
    }()

    lazy var infoAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.infoSwiped()
            completionHandler(true)
        }
        action.image = UIImage(systemName: "info.circle.fill")
        action.backgroundColor = AppConstants.Colors.lightGray
        return action
    }()

    lazy var doneAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: "done") { [weak self] (_, view, completionHandler) in
            self?.moveSwipedItemToDone(in: view)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "checkmark.circle.fill")
        action.backgroundColor = .systemGreen
        return action
    }()

    private func deleteSwipedItem() {
        guard let swipedRow = swipedRow else {
            return
        }
        let item = displayedItems[swipedRow.row]
        // TODO: handle error
        try? deleteItem(item)
    }

    private func infoSwiped() {
        DDLogError("\(#function) not implemented")
    }

    private func moveSwipedItemToDone(in view: UIView) {
        guard let swipedRow = swipedRow else {
            return
        }

        let item = displayedItems[swipedRow.row]
        let newItem = item.toDone()
        // TODO: handle error
        try? addItem(newItem)
    }

    // MARK: - Private funcs
    private func updateViews() {
        rootView.reloadData()
    }

    private func presentToDoItemView(with item: ToDoItem?) {
        let toDoItem = ToDoItemViewController(module: self, item: item)
        let navController = UINavigationController(rootViewController: toDoItem)

        toDoItem.modalPresentationStyle = .automatic
        navigationController?.present(navController, animated: true)
    }

    private func setUpAddNewItemButton() {
        view.addSubview(addNewItemButton)
        addNewItemButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addNewItemButton.widthAnchor.constraint(equalToConstant: Constants.newItemButtonSize),
            addNewItemButton.heightAnchor.constraint(equalToConstant: Constants.newItemButtonSize),
            addNewItemButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addNewItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private enum Constants {
        static let newItemButtonSize: CGFloat = 44
    }
}

extension Array where Element == ToDoItem {
    func orderedByDate() -> [ToDoItem] {
        self.sorted(by: {
            $0.createdAt > $1.createdAt
        })
    }
}

extension UITableView {
    func isLastRowAt(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.numberOfRows(inSection: 0) - 1
    }
}

extension ToDoItem {
    func toDone() -> ToDoItem {
        ToDoItem(
            id: id,
            text: text,
            priority: priority,
            createdAt: createdAt,
            deadline: deadline,
            done: true,
            modifiedAt: modifiedAt
        )
    }
}
