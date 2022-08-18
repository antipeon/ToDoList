//
//  ToDoListView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit

final class ToDoListView: UITableView {

    typealias Module = ToDoListModule & UITableViewDelegate & UITableViewDataSource

    private weak var module: Module!

    // MARK: - init
    init(module: Module) {
        self.module = module
        super.init(frame: .zero, style: .insetGrouped)
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
        backgroundColor = AppConstants.Colors.backPrimary
        setUpTableView()
    }

    private func setUpTableView() {
        register(Cell.self, forCellReuseIdentifier: Cell.Constants.reuseId)
        delegate = module
        dataSource = module
        reloadData()
    }
}
