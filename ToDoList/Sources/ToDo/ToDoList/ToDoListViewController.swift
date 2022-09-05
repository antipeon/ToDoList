//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit
import CocoaLumberjack
import WebKit
import CoreData

final class ToDoListViewController: UIViewController, ToDoItemModule,
                                    ToDoListServiceDelegate, UITableViewDelegate, UITableViewDataSource, NetworkServiceObserverDelegate {

    // MARK: - init
    init(model: ToDoListService, observer: NetworkServiceObserver) {
        self.model = model
        self.networkServiceObserver = observer

        super.init(nibName: nil, bundle: nil)
        model.delegate = self
        networkServiceObserver.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private vars
    private var rootView: ToDoListView {
        guard let view = view as? ToDoListView else {
            fatalError("view \(String(describing: view)) not initialised")
        }
        return view
    }

    private let coreDataStack = CoreDataStack.shared

    private lazy var fetchedItemsController: NSFetchedResultsController<ToDoItem> = {
        let fetchRequest = baseFetchRequest
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()

    private lazy var notDoneItemsPredicate: NSPredicate = {
        NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ToDoItem.done), false])
    }()

    private lazy var toDoListView = ToDoListView(module: self)

    private let model: ToDoListService

    private let networkServiceObserver: NetworkServiceObserver

    private var showOnlyNotDone = true {
        didSet {
            baseFetchRequest.predicate = (baseFetchRequest.predicate == nil ? notDoneItemsPredicate : nil)
            performFetch()
        }
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

    private lazy var spinner: SpinnerView = {
        SpinnerView(frame: .zero)
    }()

    private lazy var networkSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()

    // MARK: - UIViewController
    override func loadView() {
        super.loadView()
        view = toDoListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchedItemsController.delegate = self
        performFetch()

        setUpAddNewItemButton()
        setUpSpinner()
        setUpNetworkSpinner()

        rootView.register(Header.self, forHeaderFooterViewReuseIdentifier: Header.Constants.reuseIdentifier)
        rootView.register(LastCell.self, forCellReuseIdentifier: LastCell.Constants.reuseIdentifier)

        model.load()
    }

    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: "Мои дела")
        item.rightBarButtonItem = UIBarButtonItem(customView: networkSpinner)
        return item
    }

    func addItem(_ item: ToDoItemModel?, isNew: Bool) {
        model.addItem(item, isNew: isNew)
    }

    func deleteItem(_ item: ToDoItemModel?) {
        model.deleteItem(item)
    }

    func didDeleteItem() {
        updateViews()
    }

    func didAddItem() {
        updateViews()
    }

    func didSave() {}

    func didLoad() {
        spinner.removeFromSuperview()
        updateViews()
    }

    func didSynchronize() {
        updateViews()
    }

    func didLoadFail() {}

    func didSaveFail() {}

    func didAddItemFail() {}

    func didDeleteItemFail() {}

    // MARK: - Actions
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

        let item = fetchedItemsController.object(at: indexPath)
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
        guard let sectionInfo = fetchedItemsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects + 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedItemsController.sections?.count ?? 0
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

        let item = fetchedItemsController.object(at: indexPath)

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

        let item = fetchedItemsController.object(at: swipedRow)
        let itemModel = item.toImmutable

        fetchedItemsController.managedObjectContext.delete(item)
        coreDataStack.saveContext()

        refreshHeaderTitle(inSection: 0)
        deleteItem(itemModel)
    }

    private func infoSwiped() {
        DDLogError("\(#function) not implemented")
    }

    private func moveSwipedItemToDone(in view: UIView) {
        guard let swipedRow = swipedRow else {
            return
        }

        let item = fetchedItemsController.object(at: swipedRow)
        item.done.toggle()
        item.modifiiedAt = .now

        coreDataStack.saveContext()
        let itemModel = item.toImmutable

        refreshHeaderTitle(inSection: 0)
        addItem(itemModel, isNew: false)
    }

    // MARK: - NetworkServiceObserverDelegate
    func didNetworkWorkStart() {
        networkSpinner.startAnimating()
    }

    func didNetworkWorkFinish() {
        networkSpinner.stopAnimating()
    }

    // MARK: - Private funcs
    private func updateViews() {
        performFetch()
    }

    private func presentToDoItemView(with item: ToDoItem?) {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = coreDataStack.mainContext

        var childToDoItem: ToDoItem?
        var isNewItem: Bool
        if let item = item {
            childToDoItem = childContext.object(with: item.objectID) as? ToDoItem
            isNewItem = false
        } else {
            childToDoItem = ToDoItem(context: childContext)
            isNewItem = true
        }

        let toDoItem = ToDoItemViewController(module: self, item: childToDoItem, context: childContext, isNewItem: isNewItem)
        toDoItem.delegate = self

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

    private func refreshHeaderTitle(inSection section: Int) {
        rootView.beginUpdates()

        guard let headerView = rootView.headerView(forSection: section) as? Header else {
            return
        }

        headerView.doneItemsCountLabel.text = "Выполнено – \(doneItemsCount)"

        rootView.endUpdates()
    }

    private func setUpSpinner() {

        spinner.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(spinner)

        NSLayoutConstraint.activate(
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: Constants.spinnerSize),
            spinner.heightAnchor.constraint(equalToConstant: Constants.spinnerSize)
        )
    }

    private func setUpNetworkSpinner() {
        networkSpinner.hidesWhenStopped = true
    }

    private lazy var baseFetchRequest: NSFetchRequest<ToDoItem> = {
        let fetchRequest = ToDoItem.fetchRequest()
        fetchRequest.fetchBatchSize = Constants.batchSize
        fetchRequest.predicate = notDoneItemsPredicate
        let sortByCreatedAt = NSSortDescriptor(key: #keyPath(ToDoItem.createdAt), ascending: false)

        fetchRequest.sortDescriptors = [sortByCreatedAt]
        return fetchRequest
    }()

    private func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }

        let item = fetchedItemsController.object(at: indexPath)
        cell.setUpCell(with: item)
    }

    private func performFetch() {
        do {
            try fetchedItemsController.performFetch()
            rootView.reloadData()
        } catch let error as NSError {
            fatalError("\(#function) failed with error: \(error.localizedDescription)")
        }
    }

    private var doneItemsCount: Int {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "ToDoItem")

        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ToDoItem.done), true])

        fetchRequest.resultType = .countResultType

        do {
            let countResult = try coreDataStack.mainContext.fetch(fetchRequest)
            return countResult.first?.intValue ?? 0
        } catch let error as NSError {
            fatalError(error.description)
        }
    }

    private enum Constants {
        static let newItemButtonSize: CGFloat = 44
        static let spinnerSize: CGFloat = 100
        static let batchSize = 20
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ToDoListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        rootView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }

            rootView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            rootView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }

            rootView.deleteRows(at: [indexPath], with: .automatic)
            rootView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            guard let cell = rootView.dequeueReusableCell(withIdentifier: Cell.Constants.reuseId, for: indexPath) as? Cell else { return }

            configure(cell: cell, for: indexPath)
            rootView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError("unexpected error at \(#function)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        rootView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType
    ) {
        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            rootView.insertSections(indexSet, with: .automatic)
        case .delete:
            rootView.deleteSections(indexSet, with: .automatic)
        case .move:
            rootView.deleteSections(indexSet, with: .automatic)
            rootView.insertSections(indexSet, with: .automatic)
        case .update:
            rootView.reloadSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}

// MARK: - ToDoItemViewControllerDelegate
extension ToDoListViewController: ToDoItemViewControllerDelegate {
    func didFinish(controller: ToDoItemViewController, didSave: Bool) {
        defer {
            dismiss(animated: true)
        }

        guard didSave, let context = controller.context, context.hasChanges else {
            return
        }

        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                DDLogError(error)
            }

            self.coreDataStack.saveContext()
        }
    }
}

extension Array where Element == ToDoItemModel {
    func orderedByDate() -> [ToDoItemModel] {
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
