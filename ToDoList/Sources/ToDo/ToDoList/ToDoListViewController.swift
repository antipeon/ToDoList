//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit

protocol ToDoListModule: ToDoItemModule {
    var doneItemsCount: Int { get }
    
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
    
    lazy var doneItemsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнено -- \(doneItemsCount)"
        label.textColor = AppConstants.Colors.labelTertiary
        label.font = AppConstants.Fonts.subhead
        return label
    }()
    
    lazy var showDoneItemsButton: UIButton = {
        let button = UIButton(type: .system)
        //        let button = UIButton(type: .custom)
        //        let systemBlue = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
        //        button.setTitleColor(systemBlue, for: .normal)
        //        button.setTitleColor(systemBlue, for: .selected)
        button.setTitle("Показать", for: .normal)
        button.setTitle("Скрыть", for: .selected)
        //        button.isUserInteractionEnabled = true
        //        becomeFirstResponder()
        button.titleLabel?.font = AppConstants.Fonts.subheadBold
        button.addTarget(self, action: #selector(shitAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc func shitAction() {
        print("fuck")
    }
    
    lazy var doneItemsControl: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.addArrangedSubviews(doneItemsCountLabel, showDoneItemsButton)
        return view
    }()
    
    //    var rootView: ToDoListView {
    //        return (view as! ToDoListView)
    //    }
    
    override func loadView() {
        view = toDoListView
        view.backgroundColor = AppConstants.Colors.backPrimary
        //        view = UIView()
    }
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        setUp()
    //    }
    
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
    
    func addEmptyItem() {
        presentToDoItemView(with: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseId, for: indexPath)
    //
    //        guard let cell = cell as? Cell else {
    //            let h = cell.contentView.bounds.height
    //            return h
    //        }
    //        let h = cell.contentView.bounds.height
    //        return h
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        navigationController?.pushViewController(ToDoItemViewController(fileCache: fileCache), animated: true)
        
        let item = fileCache.toDoItems[indexPath.row]
        presentToDoItemView(with: item)
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        "fuck"
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        doneItemsControl
    }
    
    // MARK: - UITableViewController
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fileCache.toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseId, for: indexPath)
        
        guard let cell = cell as? Cell else {
            return cell
        }
        
        let item = fileCache.toDoItems[indexPath.row]
        
        setUpCell(cell, with: item)
        
        return cell
    }
    
    private func setUpCell(_ cell: Cell, with item: ToDoItem) {
        cell.setToDoText(with: item.text)
        cell.setDeadline(with: item.deadline)
        cell.setPriority(with: item.priority)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fileCache.remove(fileCache.toDoItems[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    func showAddItem() {
        
    }
    
    
    //    func showAddItem() {
    //        let toDoItem = ToDoItemViewController(fileCache: fileCache)
    //        self.navigationController?.navigationBar.barTintColor = .cyan
    //        toDoItem.modalPresentationStyle = .automatic
    //        navigationController?.present(toDoItem, animated: true)
    //
    //    }
    
    // MARK: - ModelObserver
    func didAddItem() {
        //        updateViews()
    }
    func didRemoveItem() {
        //        updateViews()
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


