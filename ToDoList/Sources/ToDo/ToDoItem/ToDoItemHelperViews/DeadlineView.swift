//
//  DeadlineView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

final class DeadlineView: UIView {

    // MARK: - Views
    private lazy var calendarButtonAndSwitch: UIStackView = {
        let view = UIStackView.makeHStackView()
        view.layer.cornerRadius = ToDoItemView.Constants.cornerRadius
        view.alignment = .center
        return view
    }()

    lazy var calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppConstants.Fonts.footnote
        button.contentHorizontalAlignment = .left
        button.backgroundColor = AppConstants.Colors.secondary
        button.layer.cornerRadius = ToDoItemView.Constants.cornerRadius

        button.translatesAutoresizingMaskIntoConstraints = false

        return button

    }()

    lazy var calendarSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return switchButton

    }()

    private lazy var doBeforeLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = AppConstants.Fonts.body
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var doBeforeLabelAndCalendarButton: UIStackView = {
        UIStackView.makeVStackView()
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private funcs
    private func setUpViews() {
        doBeforeLabelAndCalendarButton.addArrangedSubviews(doBeforeLabel, calendarButton)
        calendarButtonAndSwitch.addArrangedSubviews(doBeforeLabelAndCalendarButton, calendarSwitch)
        addSubview(calendarButtonAndSwitch)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate(
            calendarButtonAndSwitch.leftAnchor.constraint(
                equalTo: layoutMarginsGuide.leftAnchor,
                constant: PriorityView.Constants.priorityLabelLeftInset),
            calendarButtonAndSwitch.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            calendarButtonAndSwitch.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            calendarButtonAndSwitch.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        )
    }
}
