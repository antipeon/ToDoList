//
//  ToDoListHeaderView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

final class Header: UITableViewHeaderFooterView {

    enum Constants {
        static let reuseIdentifier = "headerId"
    }

    // MARK: - init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views
    lazy var doneItemsControl: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.addArrangedSubviews(doneItemsCountLabel, showDoneItemsButton)
        return view
    }()

    private(set) lazy var doneItemsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppConstants.Colors.labelTertiary
        label.font = AppConstants.Fonts.subhead
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private(set) lazy var showDoneItemsButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppConstants.Fonts.subheadBold
        return button
    }()

    // MARK: - Private funcs
    private func setUpViews() {
        showDoneItemsButton.translatesAutoresizingMaskIntoConstraints = false
        doneItemsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        doneItemsControl.translatesAutoresizingMaskIntoConstraints = false

        doneItemsControl.addArrangedSubviews(doneItemsCountLabel, showDoneItemsButton)
        contentView.addSubview(doneItemsControl)

        NSLayoutConstraint.activate(
            doneItemsControl.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            doneItemsControl.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            doneItemsControl.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            doneItemsControl.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            doneItemsCountLabel.rightAnchor.constraint(equalTo: showDoneItemsButton.leftAnchor),
            doneItemsCountLabel.leftAnchor.constraint(equalTo: doneItemsControl.leftAnchor),
            showDoneItemsButton.rightAnchor.constraint(equalTo: doneItemsControl.rightAnchor)
        )
    }
}
