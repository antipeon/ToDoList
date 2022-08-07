//
//  ToDoListView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit

class ToDoListView<Module: ToDoListModule>: UIView {
    
    // MARK: - Properties
    private weak var module: Module?
    
    // MARK: - Views
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Item", for: .normal)
        button.addTarget(self, action: #selector(showAddItem), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(module: Module) {
        self.module = module
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetUp
    private func setUp() {
        addSubview(button)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
    }
    
    // MARK: - Methods
    @objc private func showAddItem() {
        module?.showAddItem()
    }
}
