//
//  ToDoItemView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 27.07.2022.
//

import UIKit

final class ToDoItemView: UIView, UITextViewDelegate {
    
    typealias Module = ToDoItemModule
    
    // MARK: - Views
    private lazy var vStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.defaultOffset
        return view
    }()
    
    private lazy var toDoText: UITextView = {
        let view = UITextView()
        view.textAlignment = .left
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainerInset = defaultLayoutMargins
        view.backgroundColor = Constants.Colors.secondary
        view.font = Constants.Fonts.body
        view.autocorrectionType = .no
        
        view.delegate = self
        
        return view
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = Constants.Fonts.body
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = Constants.Colors.secondary
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isEnabled = item == nil ? false : true
        button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendar: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = Constants.Colors.secondary
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
        return switchButton
        
    }()
    
    private lazy var doBeforeLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = Constants.Fonts.body
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
        button.titleLabel?.font = Constants.Fonts.footnote
        button.contentHorizontalAlignment = .left
        button.backgroundColor = Constants.Colors.secondary
        button.addTarget(self, action: #selector(switchCalendarState), for: .touchUpInside)
        button.layer.cornerRadius = Constants.cornerRadius
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }()
    
    private lazy var doBeforeLabelAndCalendarButton: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.spacing = 20
        return view
    }()
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = Constants.Fonts.body
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
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
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var calendarButtonAndSwitch: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        return view
    }()
    
    private lazy var lowerSectionVstackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = Constants.Colors.secondary
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.spacing = Constants.defaultOffset
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = defaultLayoutMargins
        
        return view
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        let item = UINavigationItem(title: "Дело")
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveItem.isEnabled = (self.item == nil ? false : true)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        item.rightBarButtonItem = saveItem
        item.leftBarButtonItem = cancelItem
        bar.setItems([item], animated: true)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = Constants.Colors.supporNavBar
        return bar
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
    
    // MARK: - Private Methods
    private func setUp() {
        backgroundColor = Constants.Colors.backPrimary
        addViews()
        setUpConstraints()
        loadModel()
        updateViewsDisplay()
    }
    
    private func addViews() {
        
        doBeforeLabelAndCalendarButton.addArrangedSubviews(doBeforeLabel, calendarButton)
        
        calendarButtonAndSwitch.addArrangedSubviews(doBeforeLabelAndCalendarButton, calendarSwitch)
        
        prioritySwitchAndLabel.addArrangedSubviews(priorityLabel, prioritySwitch)

        lowerSectionVstackView.addArrangedSubviews(
            prioritySwitchAndLabel,
            dividerView1,
            calendarButtonAndSwitch,
            dividerView2,
            calendar
        )
        
        vStackView.addArrangedSubviews(
            toDoText,
            lowerSectionVstackView,
            deleteButton
        )
        
        addSubviews(navigationBar, vStackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            vStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: Constants.defaultOffset),
            vStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -Constants.defaultOffset),
            vStackView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            vStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            dividerView1.heightAnchor.constraint(equalToConstant: 1),
            dividerView2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func loadModel() {
        setUpToDoText()
        setUpPriority()
    }
    
    private func setUpToDoText() {
        if let item = item {
            toDoText.text = item.text
            toDoText.textColor = Constants.Colors.labelPrimary
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
//        textLabelNotEmpty && calendarSwitch.isOn
        textLabelNotEmpty
    }
    
    private var textLabelNotEmpty: Bool {
        !(toDoText.text.isEmpty) &&
        !(toDoText.textColor == Constants.Colors.labelTertiary && toDoText.text == Constants.textViewPlaceholder)
    }
    
    private lazy var defaultLayoutMargins = UIEdgeInsets(top: Constants.defaultOffset,
                                                         left: Constants.defaultOffset,
                                                         bottom: Constants.defaultOffset,
                                                         right: Constants.defaultOffset)
    
    private func setUpTextViewPlaceholder(_ textView: UITextView) {
        textView.text = Constants.textViewPlaceholder
        textView.textColor = Constants.Colors.labelTertiary
    }
    
    private func getDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
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
    
    // MARK: -Actions
    @objc func dismiss() {
        module?.dismiss()
    }
    
    @objc func save() {
        updateModel()
        module?.addItem(item)
        module?.dismiss()
    }
    
    @objc func deleteItem() {
        updateModel()
        module?.deleteItem(item)
        module?.dismiss()
    }
    
    @objc func datePickerDateChanged() {
        deadline = calendar.date
        calendarButton.setTitle(dateStr, for: .normal)
        hideCalendar()
        updateViewsDisplay()
        setNeedsDisplay()
    }
    
    @objc func switchCalendarState() {
        toggleCalendar()
        updateViewsDisplay()
        setNeedsDisplay()
    }
    
    @objc func toggleCalendarState() {
        toggleCalendar()
        deadline = initialDeadline
        updateSelectedDate()
        updateViewsDisplay()
        setNeedsDisplay()
    }
    
    // MARK: -TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Constants.Colors.labelTertiary {
            textView.text = nil
            textView.textColor = Constants.Colors.labelPrimary
        } else {
            // idk why this === deselection
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setUpTextViewPlaceholder(textView)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateViewsDisplay()
        setNeedsDisplay(navigationBar.frame)
    }
    
    private func updateViewsDisplay() {
        deleteButton.isEnabled = enoughInfoFilled
        navigationBar.items?.first?.rightBarButtonItem?.isEnabled = enoughInfoFilled
        calendarButton.isHidden = !dateSelected
        if !dateSelected {
            calendar.isHidden = true
        }
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
    
    // MARK: -Constants
    private struct Constants {
        struct Colors {
            static let secondary = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            static let backPrimary = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
            static let supporNavBar = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)
            static let separatorColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            static let labelTertiary = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            static let labelPrimary = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        struct Fonts {
            static let body: UIFont = .systemFont(ofSize: 22)
            static let footnote: UIFont = .systemFont(ofSize: 18, weight: .bold)
        }
        
        static let defaultOffset: CGFloat = 16
        static let cornerRadius: CGFloat = 20
        
        
        static let textViewPlaceholder = "Что надо сделать?"
        static let mockText1 = "shit"
        
        static let mockText =
"""
«Мой дядя самых честных правил,
Когда не в шутку занемог,
Он уважать себя заставил
И лучше выдумать не мог.
Его пример другим наука;
Но, боже мой, какая скука
С больным сидеть и день и ночь,
Не отходя ни шагу прочь!
Какое низкое коварство
Полуживого забавлять,
Ему подушки поправлять,
Печально подносить лекарство,
Вздыхать и думать про себя:
Когда же черт возьмет тебя!»

Так думал молодой повеса,
Летя в пыли на почтовых,
Всевышней волею Зевеса
Наследник всех своих родных.
Друзья Людмилы и Руслана!
С героем моего романа
Без предисловий, сей же час
Позвольте познакомить вас:
Онегин, добрый мой приятель,
Родился на брегах Невы,
Где, может быть, родились вы
Или блистали, мой читатель;
Там некогда гулял и я:
Но вреден север для меня.

Служив отлично благородно,
Долгами жил его отец,
Давал три бала ежегодно
И промотался наконец.
Судьба Евгения хранила:
Сперва Madame за ним ходила,
Потом Monsieur ее сменил.
Ребенок был резов, но мил.
Monsieur l'Abbé, француз убогой,
Чтоб не измучилось дитя,
Учил его всему шутя,
Не докучал моралью строгой,
Слегка за шалости бранил
И в Летний сад гулять водил.

Когда же юности мятежной
Пришла Евгению пора,
Пора надежд и грусти нежной,
Monsieur прогнали со двора.
Вот мой Онегин на свободе;
Острижен по последней моде,
Как dandy лондонский одет —
И наконец увидел свет.
Он по-французски совершенно
Мог изъясняться и писал;
Легко мазурку танцевал
И кланялся непринужденно;
Чего ж вам больше? Свет решил,
Что он умен и очень мил.

Мы все учились понемногу
Чему-нибудь и как-нибудь,
Так воспитаньем, слава богу,
У нас немудрено блеснуть.
Онегин был по мненью многих
(Судей решительных и строгих)
Ученый малый, но педант:
Имел он счастливый талант
Без принужденья в разговоре
Коснуться до всего слегка,
С ученым видом знатока
Хранить молчанье в важном споре
И возбуждать улыбку дам
Огнем нежданных эпиграмм.

Латынь из моды вышла ныне:
Так, если правду вам сказать,
Он знал довольно по-латыне,
Чтоб эпиграфы разбирать,
Потолковать об Ювенале,
В конце письма поставить vale,
Да помнил, хоть не без греха,
Из Энеиды два стиха.
Он рыться не имел охоты
В хронологической пыли
Бытописания земли:
Но дней минувших анекдоты
От Ромула до наших дней
Хранил он в памяти своей.

Высокой страсти не имея
Для звуков жизни не щадить,
Не мог он ямба от хорея,
Как мы ни бились, отличить.
Бранил Гомера, Феокрита;
Зато читал Адама Смита
И был глубокой эконом,
То есть умел судить о том,
Как государство богатеет,
И чем живет, и почему
Не нужно золота ему,
Когда простой продукт имеет.
Отец понять его не мог
И земли отдавал в залог.
"""
    }
}


extension ToDoItem.Priority {
    static func makePriorityFromSelectedSegmentIndex(_ index: Int) -> ToDoItem.Priority? {
        if index == 0 {
            return .low
        }
        if index == 1 {
            return .normal
        }
        if index == 2 {
            return .high
        }
        return nil
    }
}
