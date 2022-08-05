//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit

protocol ToDoListModule: ToDoItemModule {
    var doneItemsCount: Int { get }
    var notDoneItems: [ToDoItem] { get }
    
    
    func addEmptyItem()
    //    func showAddItem()
}

class ToDoListViewController: UIViewController, ToDoListModule, ModelObserver, UITableViewDelegate, UITableViewDataSource {
    
    struct Constants {
        static let reuseId: String = "Cell"
    }
    
    private let filename = "toDoItems"
    
    private var rootView: ToDoListView {
        guard let view = view as? ToDoListView else {
            fatalError("view \(String(describing: view)) not initialised")
        }
        return view
    }
    
    private lazy var fileCache: FileCache = {
        let fileCache = FileCache()
        try? fileCache.load(from: filename)
        fileCache.delegate = self
        return fileCache
    }()
    
    private lazy var toDoListView = ToDoListView(module: self)

    @objc func toggleShowOnlyDone() {
        showOnlyNotDone.toggle()
//        print("someting")
//        guard let header = rootView.dequeueReusableHeaderFooterView(withIdentifier: Header.Constants.reuseIdentifier) as? Header else {
//            fatalError("str")
//        }
//        header.doneItemsCountLabel.text = "Выполнен"
    }
    
    override func loadView() {
        super.loadView()
        view = toDoListView
        view.backgroundColor = AppConstants.Colors.backPrimary
    }
    
    lazy var addNewItemButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .large)
        let buttonImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addEmptyItem), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAddNewItemButton()
        
        rootView.register(Header.self, forHeaderFooterViewReuseIdentifier: Header.Constants.reuseIdentifier)
    }
    
    private func setUpAddNewItemButton() {
        view.addSubview(addNewItemButton)
        addNewItemButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addNewItemButton.widthAnchor.constraint(equalToConstant: 44),
            addNewItemButton.heightAnchor.constraint(equalToConstant: 44),
            addNewItemButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addNewItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //    private func setUp() {
    ////        view.backgroundColor = .white
    //        view.addSubview(tableView)
    //        tableView.backgroundColor = .white
    //
    //        tableView.register(Cell.self, forCellReuseIdentifier: Constants.reuseId)
    //        tableView.delegate = self
    //        tableView.dataSource = self
    ////        tableView.rowHeight = UITableView.automaticDimension
    ////        tableView.estimatedRowHeight =  600
    //
    //        tableView.reloadData()
    //    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //        tableView.frame = view.bounds
    //
    //    }
    
    
    
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
    
    // MARK: - ToDoListModule
    var doneItemsCount: Int {
        fileCache.toDoItems
            .filter {
                $0.done
            }
            .count
    }
    
    var notDoneItems: [ToDoItem] {
        fileCache.toDoItems
            .filter {
                !$0.done
            }
            .orderedByDate()
    }
    
    private var showOnlyNotDone = true {
        didSet {
            rootView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
        }
    }
    
    private var displayedItems: [ToDoItem] {
        (showOnlyNotDone ? notDoneItems : fileCache.toDoItems.orderedByDate())
    }
    
    @objc func addEmptyItem() {
        presentToDoItemView(with: nil)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
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
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        "fuck"
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Header.Constants.reuseIdentifier)
        guard let header = view as? Header else {
            return view
        }
        
        header.doneItemsCountLabel.text = "Выполнено – \(doneItemsCount)"
        header.showDoneItemsButton.setTitle(showOnlyNotDone ? "Показать" : "Скрыть", for: .normal)
        header.showDoneItemsButton.addTarget(self, action: #selector(toggleShowOnlyDone), for: .touchUpInside)
        return header
    }
    
    
    private var swipedRow: IndexPath?
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseId, for: indexPath)
        
        guard let cell = cell as? Cell else {
//            guard let _ = cell as? LastCell else {
//                return cell
//            }
//
//            return LastCell()
            return cell
        }
        
        if tableView.isLastRowAt(indexPath) {
            return LastCell()
        }
        
        let item = displayedItems[indexPath.row]
        
        setUpCell(cell, with: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView.isLastRowAt(indexPath) {
            return nil
        }
        let config = UISwipeActionsConfiguration(actions: [doneAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.isLastRowAt(indexPath) {
            return
        }
        
        if editingStyle == .delete {
            fileCache.remove(displayedItems[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - SwipeActions
    lazy var deleteAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: nil) {
            [weak self] (action, view, completionHandler) in
            self?.deleteSwipedItem()
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .red
        return action
    }()
    
    lazy var infoAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: nil) {
            [weak self] (action, view, completionHandler) in
            self?.infoSwiped()
            completionHandler(true)
        }
        action.image = UIImage(systemName: "info.circle.fill")
        action.backgroundColor = AppConstants.Colors.lightGray
        return action
    }()
    
    lazy var doneAction: UIContextualAction = {
        let action = UIContextualAction(style: .normal, title: "done") {
            [weak self] (action, view, completionHandler) in
            self?.moveSwipedItemToDone(in: view)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "checkmark.circle.fill")
//        action.backgroundColor = AppConstants.Colors.lightGreen
        action.backgroundColor = .systemGreen
        return action
    }()
    
    func deleteSwipedItem() {
        print("deleted")
        guard let swipedRow = swipedRow else {
            return
        }
        let item = displayedItems[swipedRow.row]
        deleteItem(item)
    }
    
    func infoSwiped() {
        print("do nothing")
    }
    
    func moveSwipedItemToDone(in view: UIView) {
        print("done")
        guard let swipedRow = swipedRow else {
            return
        }
        
//        cell.setDone(with: true)
        let item = displayedItems[swipedRow.row]
        let newItem = ToDoItem(id: item.id, text: item.text, priority: item.priority, createdAt: item.createdAt, deadline: item.deadline, done: true, modifiedAt: item.modifiedAt)
        addItem(newItem)
        
//        rootView.reloadData()
    }
    
    // MARK: - ModelObserver
    func didAddItem() {
//                updateViews()
    }
    func didRemoveItem() {
//                updateViews()
    }
    func didSave() {
        updateViews()
    }
    func didLoad() {
        updateViews()
    }
    
    // MARK: - Private funcs
    private func updateViews() {
        //        view.setNeedsDisplay()
        //        view.setNeedsLayout()
        //        view.layoutIfNeeded()
        rootView.reloadData()
    }
    
    private func setUpCell(_ cell: Cell, with item: ToDoItem) {
        cell.setDone(with: item.done)
        cell.setToDoText(with: item)
        cell.setDeadline(with: item.deadline)
        cell.setPriority(with: item.priority)
    }
    
    private func presentToDoItemView(with item: ToDoItem?) {
        let toDoItem = ToDoItemViewController(module: self, item: item)
        let navController = UINavigationController(rootViewController: toDoItem)
        
        toDoItem.modalPresentationStyle = .automatic
        navigationController?.present(navController, animated: true)
        
//        let toDoItem = ToDoItemViewController(fileCache: fileCache)
//        let navController = UINavigationController(rootViewController: toDoItem)
//        toDoItem.modalPresentationStyle = .automatic
//        navigationController?.present(navController, animated: true)
    }
}

extension Array where Element == ToDoItem {
    func orderedByDate() -> [ToDoItem] {
        self.sorted(by: {
            $0.createdAt < $1.createdAt
        })
    }
}


extension UITableView {
    func isLastRowAt(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.numberOfRows(inSection: 0) - 1
    }
}
