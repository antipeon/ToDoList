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
    
    lazy var addNewItemButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .large)
        let buttonImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addEmptyItem), for: .touchUpInside)
        return button
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
    
    // MARK: - Actions
    @objc private func addEmptyItem() {
        module.addEmptyItem()
    }
}

class Cell: UITableViewCell {
    private struct Constants {
        static let gap: CGFloat = 16
    }
    
    private lazy var text: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = AppConstants.Fonts.body
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
//        label.numberOfLines = 1
        label.font = AppConstants.Fonts.subhead
        label.textColor = AppConstants.Colors.labelTertiary
        return label
    }()
    
    private lazy var calendarIcon: UIImageView = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.font = AppConstants.Fonts.subhead
//        label.textColor = AppConstants.Colors.labelTertiary
//        let configuration = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .large)
//        let label = UIImage(systemName: "calendar", withConfiguration: configuration)
        guard let image = UIImage(systemName: "calendar") else {
            fatalError("no such image")
        }
        
        let view = UIImageView(image: image)
        view.tintColor = AppConstants.Colors.labelTertiary
        return view
    }()
    
    private lazy var priorityIcon: UIImageView = {
        return UIImageView()
    }()
    
    private func dateStr(from deadline: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter.string(from: deadline)
    }
    
    private lazy var dateView: UIStackView = {
        let stackView = UIStackView.makeHStackView()
        
        
        stackView.alignment = .center
        
        stackView.addArrangedSubviews(calendarIcon, dateLabel)
        
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.preservesSuperviewLayoutMargins = true
        view.layoutMargins = insets
        //        view.insetsLayoutMarginsFromSafeArea = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cellContent: UIStackView = {
        let view = UIStackView.makeHStackView()
        view.alignment = .center
        view.spacing = 5
        return view
    }()
    
    private lazy var textAndDate: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textAndDate.addArrangedSubviews(text, dateView)
        
//        containerView.addSubview(text)
        cellContent.addArrangedSubviews(priorityIcon, textAndDate)
        containerView.addSubview(cellContent)
        contentView.addSubview(containerView)
        text.sizeToFit()
        applyConstraints()
    }
    
    let insets = UIEdgeInsets(top: Constants.gap,
                              left: Constants.gap,
                              bottom: Constants.gap,
                              right: Constants.gap)
    
    private func applyConstraints() {
        NSLayoutConstraint.activate(
            [
                containerView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
                containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
//
//                text.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor),
//                text.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor
//                                           ),
//                text.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
//                text.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
                
                cellContent.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor),
                cellContent.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor
                                           ),
                cellContent.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
                cellContent.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
                
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("unimplemented")
    }
    
    // MARK: - Modify Views func
    
    func setToDoText(with text: String?) {
        self.text.text = text
    }
    
    func setDeadline(with deadline: Date?) {
        if let deadline = deadline {
            dateLabel.text = dateStr(from: deadline)
        } else {
            dateView.isHidden = true
        }
    }
    
    func setPriority(with priority: ToDoItem.Priority) {
        switch priority {
        case .normal:
            priorityIcon.isHidden = true
        case .high:
            priorityIcon.isHidden = false
            priorityIcon.image = UIImage(systemName: "exclamationmark.2")
            priorityIcon.tintColor = .red
        case .low:
            priorityIcon.isHidden = false
            priorityIcon.image = UIImage(systemName: "arrow.down")
            priorityIcon.tintColor = .gray
        }
    }
    
    
    
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        containerView.bounds = contentView.bounds
    //    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        text.frame.origin = .init(x: 0, y: 0)
    //        text.sizeToFit()
    //        let containerWidth = contentView.bounds.width - 2 * Constants.gap
    ////        text.frame.size = .init(width: containerWidth, height: 20)
    //
    //
    //        let contentHeight = text.bounds.height
    //        containerView.frame = .init(x: Constants.gap, y: (contentView.bounds.height - contentHeight) / 2, width: containerWidth, height: contentHeight)
    //    }
    
}
