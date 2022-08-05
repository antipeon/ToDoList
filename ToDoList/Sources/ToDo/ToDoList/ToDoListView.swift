//
//  ToDoListView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit

class ToDoListView: UITableView {
    
    typealias Module = ToDoListModule & UITableViewDelegate & UITableViewDataSource
    
    
    
    private weak var module: Module!
    
    // MARK: - Views
    
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
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = AppConstants.Fonts.subheadBold

        return button
    }()
    
    lazy var doneItemsControl: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    
//    lazy var tableView: UITableView = {
//        let view = UITableView(frame: .zero, style: .insetGrouped)
//        view.layer.cornerRadius = 16
//        return view
//    }()
    
//    lazy var content: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 16
//        content.backgroundColor = .white
//        return view
//    }()
    
    // MARK: - init
    init(module: Module) {
        self.module = module
//        super.init(frame: .zero)
        super.init(frame: .zero, style: .insetGrouped)
        backgroundColor = AppConstants.Colors.backPrimary
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private funcs
    private var doneItemsCount: Int {
        module.doneItemsCount
    }

    private func setUp() {
//                view.backgroundColor = .white
        self.backgroundColor = AppConstants.Colors.backPrimary
        buildViewHierarchy()
        setUpTableView()
    }
    
    private func buildViewHierarchy() {
//        doneItemsControl.addArrangedSubviews(doneItemsCountLabel, showDoneItemsButton)
//        addSubviews(tableView, addNewItemButton, doneItemsControl)
//        addSubviews(tableView, addNewItemButton, doneItemsCountLabel, showDoneItemsButton)
//        addSubviews(tableView)
    }
    
    private func setUpTableView() {
        backgroundColor = .white
        register(Cell.self, forCellReuseIdentifier: ToDoListViewController.Constants.reuseId)
        delegate = module
        dataSource = module
        //        tableView.rowHeight = UITableView.automaticDimension
        //        tableView.estimatedRowHeight =  600
        
        reloadData()
    }
    
    // MARK: - UIView
    override func layoutSubviews() {
        struct Constants {
            static let doneControlXOffset: CGFloat = 32
            static let doneControlYOffset: CGFloat = 18
            static let gap: CGFloat = 16
            static let tableViewYOffset: CGFloat = 12
        }
        
        super.layoutSubviews()
//        doneItemsCountLabel.sizeToFit()
//        showDoneItemsButton.sizeToFit()
////        doneItemsControl.sizeToFit()
////        doneItemsControl.frame.origin = .init(x: Constants.doneControlXOffset, y: Constants.doneControlYOffset)
//        doneItemsCountLabel.frame.origin = .init(x: Constants.doneControlXOffset, y: safeAreaInsets.top + Constants.doneControlYOffset)
////        doneItemsCountLabel.frame.size = .init(width: 113, height: 20)
//
//        guard let titleLabelHeight = showDoneItemsButton.titleLabel?.bounds.height else {
//            fatalError("title label doesn't exist")
//        }
//        let smallOffset = (showDoneItemsButton.bounds.height - titleLabelHeight) / 2
//        showDoneItemsButton.frame.origin = .init(x: bounds.width - Constants.doneControlXOffset - showDoneItemsButton.bounds.width, y: safeAreaInsets.top + Constants.doneControlYOffset - smallOffset)
////        showDoneItemsButton.frame.size = .init(width: 147.5, height: 20)
//
//        let tableViewWidth = self.bounds.width - 2 * Constants.gap
////        let tableViewHeight = self.bounds.height - doneItemsCountLabel.frame.maxY
////        if doneItemsCountLabel.isHidden {
////            tableView.frame = .init(x: Constants.gap, y: 0, width: tableViewWidth, height: tableViewHeight)
////        } else {
////            tableView.frame = .init(x: Constants.gap, y: doneItemsCountLabel.frame.maxY + Constants.tableViewYOffset, width: tableViewWidth, height: tableViewHeight)
////        }
//
//
//        tableView.frame = .init(x: Constants.gap, y: safeAreaInsets.top, width: tableViewWidth, height: 703)
//
//
//        addNewItemButton.sizeToFit()
//
//        let newItemButtonXOffset = (bounds.width - addNewItemButton.bounds.width) / 2
//
//
//        addNewItemButton.frame.origin = .init(x: newItemButtonXOffset, y: bounds.height - 54 - addNewItemButton.bounds.width)
        
        
//        tableView.frame = self.bounds
    }
}
