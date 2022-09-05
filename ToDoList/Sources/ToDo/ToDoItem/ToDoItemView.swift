//
//  ToDoItemView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 27.07.2022.
//

import UIKit

final class ToDoItemView: UIView {

    typealias Module = ToDoItemViewController

    // MARK: - Views
    lazy var vStackView: UIStackView = {
        let view = UIStackView.makeVStackView()
        view.spacing = Constants.defaultOffset
        return view
    }()

    lazy var toDoText: UITextView = {
        let view = UITextView()
        view.textAlignment = .left
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainerInset = defaultLayoutMargins
        view.backgroundColor = AppConstants.Colors.secondary
        view.font = AppConstants.Fonts.body
        view.autocorrectionType = .no

        view.delegate = module

        return view
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = AppConstants.Fonts.body
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = AppConstants.Colors.secondary
        button.translatesAutoresizingMaskIntoConstraints = false

        button.isEnabled = item == nil ? false : true
        button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        return button
    }()

    private lazy var calendar: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = AppConstants.Colors.secondary
        datePicker.layer.cornerRadius = Constants.cornerRadius
        datePicker.layer.masksToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.setDate(deadline, animated: true)
        datePicker.addTarget(self, action: #selector(datePickerDateChanged), for: .valueChanged)

        datePicker.isHidden = true

        return datePicker
    }()

    private lazy var dividerView2: UIView = {
        let divider = ToDoItemView.getDivider()
        divider.isHidden = true
        return divider
    }()

    lazy var lowerSectionVstackView: UIStackView = {
        let view = UIStackView.makeVStackView()
        view.backgroundColor = AppConstants.Colors.secondary
        view.layer.cornerRadius = Constants.cornerRadius
        view.distribution = .fill
        view.layoutMargins = defaultLayoutMargins

        return view
    }()

    private lazy var switchSection = SwitchSectionView(frame: .zero)

    // MARK: - Properties

    private var module: Module
    private let item: ToDoItem?
    private let isNewItem: Bool

    // MARK: - Init

    init(module: Module, item: ToDoItem?, isNewItem: Bool) {
        self.module = module
        self.item = item
        self.isNewItem = isNewItem
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func cancel() {
//        module.dismiss()
        module.delegate?.didFinish(controller: module, didSave: false)
    }

    func save() throws {
        updateModel()
        module.addItem(item?.toImmutable, isNew: isNewItem)
//        module.dismiss()

        module.delegate?.didFinish(controller: module, didSave: true)
    }

    func setUpTextViewPlaceholder(_ textView: UITextView) {
        textView.text = ToDoItemView.Constants.textViewPlaceholder
        textView.textColor = AppConstants.Colors.labelTertiary
    }

    func updateViewsDisplay() {
        deleteButton.isEnabled = enoughInfoFilled
        module.navigationItem.rightBarButtonItem?.isEnabled = enoughInfoFilled
        switchSection.deadlineView.calendarButton.isHidden = !dateSelected
        if !dateSelected {
            calendar.isHidden = true
        }
    }

    // MARK: - Private Methods
    private func setUp() {
        backgroundColor = AppConstants.Colors.backPrimary
        addViews()
        setUpDeadlineView()
        setUpConstraints()
        loadModel()
        updateViewsDisplay()
    }

    private func setUpDeadlineView() {
        switchSection.deadlineView.calendarButton.setTitle(dateStr, for: .normal)
        switchSection.deadlineView.calendarButton.addTarget(
            self,
            action: #selector(switchCalendarState),
            for: .touchUpInside
        )
        switchSection.deadlineView.calendarSwitch.isOn = (item?.deadline == nil ? false : true)
        switchSection.deadlineView.calendarSwitch.addTarget(
            self,
            action: #selector(toggleCalendarState),
            for: .touchUpInside
        )
    }

    private func addViews() {

        lowerSectionVstackView.addArrangedSubviews(
            switchSection,
            dividerView2,
            calendar
        )

        vStackView.addArrangedSubviews(
            toDoText,
            lowerSectionVstackView,
            deleteButton
        )

        addSubview(vStackView)
    }

    lazy var viewBottomAnchor = vStackView.bottomAnchor.constraint(
        equalTo: safeAreaLayoutGuide.bottomAnchor,
        constant: -Constants.defaultOffset
    )

    private func setUpConstraints() {
        NSLayoutConstraint.activate(
            switchSection.heightAnchor.constraint(equalToConstant: Constants.switchSectionHeight),

            lowerSectionVstackView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.lowerSectionMaxHeight),

            vStackView.leftAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leftAnchor,
                constant: Constants.defaultOffset
            ),
            vStackView.rightAnchor.constraint(
                equalTo: safeAreaLayoutGuide.rightAnchor,
                constant: -Constants.defaultOffset
            ),
            vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            viewBottomAnchor,
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButttonHeight),

            dividerView2.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
        )
    }

    private func loadModel() {
        setUpToDoText()
        setUpPriority()
    }

    private func setUpToDoText() {
        if let item = item {
            toDoText.text = item.text
            toDoText.textColor = AppConstants.Colors.labelPrimary
            return
        }
        setUpTextViewPlaceholder(toDoText)
    }

    private func setUpPriority() {
        if let item = item {
            switch item.priority {
            case .high:
                switchSection.prioritySwitchAndLabel.prioritySwitch.selectedSegmentIndex = 2
            case .normal:
                switchSection.prioritySwitchAndLabel.prioritySwitch.selectedSegmentIndex = 1
            case .low:
                switchSection.prioritySwitchAndLabel.prioritySwitch.selectedSegmentIndex = 0
            }
        }
    }

    private func toggleCalendar() {
        calendar.isHidden.toggle()
        dividerView2.isHidden = calendar.isHidden
    }

    private func showCalendar() {
        calendar.isHidden = false
        dividerView2.isHidden = false
    }

    private func hideCalendar() {
        calendar.isHidden = true
        dividerView2.isHidden = true
    }

    private var enoughInfoFilled: Bool {
        textLabelNotEmpty
    }

    private var textLabelNotEmpty: Bool {
        !(toDoText.text.isEmpty) &&
        !(toDoText.textColor == AppConstants.Colors.labelTertiary && toDoText.text == Constants.textViewPlaceholder)
    }

    private lazy var defaultLayoutMargins = UIEdgeInsets(top: Constants.defaultOffset,
                                                         left: Constants.defaultOffset,
                                                         bottom: Constants.defaultOffset,
                                                         right: Constants.defaultOffset)

    static func getDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = AppConstants.Colors.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private var dateStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        return dateFormatter.string(from: deadline)
    }

    private func updateSelectedDate() {
        calendar.date = deadline
        switchSection.deadlineView.calendarButton.setTitle(dateStr, for: .normal)
    }

    private lazy var initialDeadline: Date = {
        if let deadline = item?.deadline {
            return deadline
        }

        var dayComponent = DateComponents()
        dayComponent.day = 1
        let date: Date? = Calendar.current.date(byAdding: dayComponent, to: .now)

        guard let date = date else {
            fatalError("can't convert date")
        }
        return date
    }()

    private lazy var deadline: Date = {
        initialDeadline
    }()

    private var dateSelected: Bool {
        switchSection.deadlineView.calendarSwitch.isOn
    }

    // MARK: - Actions
    @objc private func deleteItem() throws {
        guard let item = item else {
            return
        }

        updateModel()
        module.deleteItem(item.toImmutable)
//        module.dismiss()

        item.managedObjectContext?.delete(item)

        module.delegate?.didFinish(controller: module, didSave: true)
    }

    @objc private func datePickerDateChanged() {
        deadline = calendar.date
        switchSection.deadlineView.calendarButton.setTitle(dateStr, for: .normal)
        hideCalendar()
        updateViewsDisplay()
        setNeedsDisplay()
    }

    @objc private func switchCalendarState() {
        toggleCalendar()
        updateViewsDisplay()
        setNeedsDisplay()
    }

    @objc private func toggleCalendarState() {
        toggleCalendar()
        deadline = initialDeadline
        updateSelectedDate()
        updateViewsDisplay()
        setNeedsDisplay()
    }

    private func updateModel() {
        let index = switchSection.prioritySwitchAndLabel.prioritySwitch.selectedSegmentIndex
        guard let priority = ToDoItemModel.Priority.makePriorityFromSelectedSegmentIndex(index) else {
            fatalError("no such priority")
        }

        let deadline = switchSection.deadlineView.calendarSwitch.isOn ? deadline : nil

        let now = Date.now

        guard let item = item else {
            return
        }

        item.text = toDoText.text
        item.priority = priority
        item.deadline = deadline
        item.modifiiedAt = now

        if isNewItem {
            item.createdAt = now
            item.done = false
            item.id = UUID().uuidString
        }

//        if let item = item {
//            self.item = ToDoItemModel(
//                id: item.id,
//                text: toDoText.text,
//                priority: priority,
//                createdAt: item.createdAt,
//                deadline: deadline,
//                done: item.done,
//                modifiedAt: now
//            )
//            return
//        }
//
//        item = ToDoItemModel(
//            text: toDoText.text,
//            priority: priority,
//            createdAt: now,
//            deadline: deadline,
//            modifiedAt: now
//        )
    }

    // MARK: - Constants
    enum Constants {

        static let defaultOffset: CGFloat = 16
        static let switchSectionTopInset: CGFloat = 10
        static let cornerRadius: CGFloat = 20
        static let textViewMinHeight: CGFloat = 120
        static let textViewMaxHeight: CGFloat = 484
        static let navBarHeight: CGFloat = 56
        static let lowerSectionMaxHeight: CGFloat = 449
        static let deleteButttonHeight: CGFloat = 56
        static let dividerHeight: CGFloat = 0.5
        static let switchSectionHeight: CGFloat = 112.5

        static let textViewPlaceholder = "Что надо сделать?"
    }
}

extension ToDoItemModel.Priority {
    static func makePriorityFromSelectedSegmentIndex(_ index: Int) -> ToDoItemModel.Priority? {
        let allCases = ToDoItemModel.Priority.allCases
        guard index < allCases.count else {
            return nil
        }
        return allCases[index]
    }
}
