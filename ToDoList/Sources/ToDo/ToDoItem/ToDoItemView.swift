//
//  ToDoItemView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 27.07.2022.
//

import UIKit

final class ToDoItemView: UIView  {
    
    typealias Module = ToDoItemModule
    
    // MARK: - Views
    private lazy var vStackView: UIStackView = {
        let view = UIStackView.makeVStackView()
        view.spacing = Constants.defaultOffset
        return view
    }()
    
    private lazy var toDoText: UITextView = {
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
    
    private lazy var deleteButton: UIButton = {
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
    
    private lazy var calendarSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.isOn = (item?.deadline == nil ? false : true)
        switchButton.addTarget(self, action: #selector(toggleCalendarState), for: .touchUpInside)
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
    
    private lazy var dividerView1: UIView = {
        getDivider()
    }()
    
    private lazy var dividerView2: UIView = {
        let divider = getDivider()
        divider.isHidden = true
        return divider
    }()
    
    private lazy var calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(dateStr, for: .normal)
        button.titleLabel?.font = AppConstants.Fonts.footnote
        button.contentHorizontalAlignment = .left
        button.backgroundColor = AppConstants.Colors.secondary
        button.addTarget(self, action: #selector(switchCalendarState), for: .touchUpInside)
        button.layer.cornerRadius = Constants.cornerRadius
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }()
    
    private lazy var doBeforeLabelAndCalendarButton: UIStackView = {
        UIStackView.makeVStackView()
    }()
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = AppConstants.Fonts.body
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var prioritySwitch: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(with: UIImage(systemName: "arrow.down"), at: 0, animated: false)
        view.insertSegment(withTitle: "нет", at: 1, animated: false)
        let exclamationMark = UIImage(systemName: "exclamationmark.2")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        view.insertSegment(with: exclamationMark, at: 2, animated: false)
        view.selectedSegmentIndex = 1
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var prioritySwitchAndLabel: UIStackView = {
        let view = UIStackView.makeHStackView()
        view.alignment = .center
        return view
    }()
    
    private lazy var calendarButtonAndSwitch: UIStackView = {
        let view = UIStackView.makeHStackView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.alignment = .center
        return view
    }()
    
    private lazy var lowerSectionVstackView: UIStackView = {
        let view = UIStackView.makeVStackView()
        view.backgroundColor = AppConstants.Colors.secondary
        view.layer.cornerRadius = Constants.cornerRadius
        view.distribution = .fill
        view.spacing = Constants.defaultOffset
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = defaultLayoutMargins
        
        return view
    }()
    
    private lazy var switchSection: UIStackView = {
        let view = UIStackView.makeVStackView()
        view.spacing = Constants.defaultOffset
        return view
    }()
    
    // MARK: - Properties
    
    private weak var module: Module?
    private var item: ToDoItem?
    
    // MARK: - Init
    
    init(module: Module, item: ToDoItem?) {
        self.module = module
        self.item = item
        super.init(frame: .zero)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func cancel() {
        module?.dismiss()
    }
    
    func save() {
        updateModel()
        module?.addItem(item)
        module?.dismiss()
    }
    
    func setUpTextViewPlaceholder(_ textView: UITextView) {
        textView.text = ToDoItemView.Constants.textViewPlaceholder
        textView.textColor = AppConstants.Colors.labelTertiary
    }
    
    func updateViewsDisplay() {
        deleteButton.isEnabled = enoughInfoFilled
        module?.navigationItem.rightBarButtonItem?.isEnabled = enoughInfoFilled
        calendarButton.isHidden = !dateSelected
        if !dateSelected {
            calendar.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    private func setUp() {
        backgroundColor = AppConstants.Colors.backPrimary
        addViews()
        setUpConstraints()
        loadModel()
        updateViewsDisplay()
    }
    
    private func addViews() {
        
        doBeforeLabelAndCalendarButton.addArrangedSubviews(doBeforeLabel, calendarButton)
        
        calendarButtonAndSwitch.addArrangedSubviews(doBeforeLabelAndCalendarButton, calendarSwitch)
        
        prioritySwitchAndLabel.addArrangedSubviews(priorityLabel, prioritySwitch)

        switchSection.addArrangedSubviews(prioritySwitchAndLabel, dividerView1, calendarButtonAndSwitch)
        
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
    
    private func setUpConstraints() {
        
        NSLayoutConstraint.activate([
            switchSection.heightAnchor.constraint(equalToConstant: Constants.switchSectionHeight),
            prioritySwitchAndLabel.heightAnchor.constraint(equalTo: calendarButtonAndSwitch.heightAnchor),
            prioritySwitch.heightAnchor.constraint(equalToConstant: Constants.prioritySwitchHeight),
            priorityLabel.heightAnchor.constraint(equalToConstant: Constants.priorityLabelHeight),

            toDoText.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewMinHeight),
            lowerSectionVstackView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.lowerSectionMaxHeight),
            
            vStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: Constants.defaultOffset),
            vStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -Constants.defaultOffset),
            vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.defaultOffset),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButttonHeight),

            dividerView1.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),
            dividerView2.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
        ])
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
                prioritySwitch.selectedSegmentIndex = 2
            case .normal:
                prioritySwitch.selectedSegmentIndex = 1
            case .low:
                prioritySwitch.selectedSegmentIndex = 0
            }
        }
    }
    
    private func toggleCalendar() {
        calendar.isHidden.toggle()
        dividerView2.isHidden.toggle()
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
    
    
    
    private func getDivider() -> UIView {
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
        calendarButton.setTitle(dateStr, for: .normal)
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
        calendarSwitch.isOn
    }
    
    // MARK: - Actions
    @objc private func deleteItem() {
        updateModel()
        module?.deleteItem(item)
        module?.dismiss()
    }
    
    @objc private func datePickerDateChanged() {
        deadline = calendar.date
        calendarButton.setTitle(dateStr, for: .normal)
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
        guard let priority = ToDoItem.Priority.makePriorityFromSelectedSegmentIndex(prioritySwitch.selectedSegmentIndex) else {
            fatalError("no such priority")
        }
        
        let deadline = calendarSwitch.isOn ? deadline : nil
        
        let now = Date.now
        
        if let item = item {
            self.item = ToDoItem(id: item.id, text: toDoText.text, priority: priority, createdAt: item.createdAt, deadline: deadline, done: item.done, modifiedAt: now)
            return
        }

        item = ToDoItem(text: toDoText.text, priority: priority, createdAt: now, deadline: deadline, modifiedAt: now)
    }
    
    // MARK: - Constants
    private struct Constants {
        
        static let defaultOffset: CGFloat = 16
        static let cornerRadius: CGFloat = 20
        static let textViewMinHeight: CGFloat = 120
        static let textViewMaxHeight: CGFloat = 484
        static let navBarHeight: CGFloat = 56
        static let lowerSectionMaxHeight: CGFloat = 449
        static let deleteButttonHeight: CGFloat = 56
        static let dividerHeight: CGFloat = 0.5
        static let switchSectionHeight: CGFloat = 112.5
        static let prioritySwitchHeight: CGFloat = 36
        static let priorityLabelHeight: CGFloat = 22
        
        static let textViewPlaceholder = "Что надо сделать?"
    }
}

extension ToDoItem.Priority {
    static func makePriorityFromSelectedSegmentIndex(_ index: Int) -> ToDoItem.Priority? {
        let allCases = ToDoItem.Priority.allCases
        guard index < allCases.count else {
            return nil
        }
        return allCases[index]
    }
}
