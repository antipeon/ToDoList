//
//  ToDoListCellView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

final class Cell: UITableViewCell {
    enum Constants {
        static let gap: CGFloat = 16
        static let reuseId: String = "cellId"
        static let maxNumberOfLinesInTextView = 3
        static let cellHorizontalSpacing: CGFloat = 5
        static let doneIconSize: CGFloat = 24
    }

    // MARK: - Views
    private lazy var text: UILabel = {
        let view = UILabel()
        view.numberOfLines = Constants.maxNumberOfLinesInTextView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = AppConstants.Fonts.body
        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppConstants.Fonts.subhead
        label.textColor = AppConstants.Colors.labelTertiary
        return label
    }()

    private lazy var calendarIcon: UIImageView = {
        guard let image = UIImage(systemName: "calendar") else {
            fatalError("no such image")
        }
        let view = UIImageView(image: image)
        view.tintColor = AppConstants.Colors.labelTertiary
        return view
    }()

    private lazy var doneIcon: UIImageView = {
        let view = UIImageView(image: nil)
        return view
    }()

    private lazy var chevronIcon: UIImageView = {
        guard let image = UIImage(systemName: "chevron.forward") else {
            fatalError("no such image")
        }
        let view = UIImageView(image: image)
        view.tintColor = AppConstants.Colors.labelTertiary
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()

    private lazy var priorityIcon: UIImageView = {
        return UIImageView()
    }()

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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cellContent: UIStackView = {
        let view = UIStackView.makeHStackView()
        view.alignment = .center
        view.spacing = Constants.cellHorizontalSpacing
        return view
    }()

    private lazy var textAndDate: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("unimplemented")
    }

    // MARK: - UITableViewCell
    override func prepareForReuse() {
        text.attributedText = nil
        text.textColor = .black
        text.font = AppConstants.Fonts.body
    }

    // MARK: - Modify Views func
    func setUpCell(with item: ToDoItem) {
        setDone(with: item)
        setToDoText(with: item)
        setDeadline(with: item.deadline)
        setPriority(with: item.priority)
    }

    private func setToDoText(with item: ToDoItem) {
        guard item.done else {
            text.text = item.text
            return
        }

        guard let itemText = item.text else {
            return
        }

        let attrString = NSMutableAttributedString(string: itemText)
        attrString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: 2,
            range: NSRange(location: 0, length: attrString.length)
        )
        text.textColor = AppConstants.Colors.labelTertiary
        text.attributedText = attrString
    }

    private func setDeadline(with deadline: Date?) {
        if let deadline = deadline {
            dateView.isHidden = false
            dateLabel.text = dateStr(from: deadline)
        } else {
            dateView.isHidden = true
        }
    }

    private func setPriority(with priority: ToDoItemModel.Priority) {
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

    private func setDone(with item: ToDoItem) {
        if item.done {
            setIconToDone()
            return
        } else if let deadline = item.deadline, deadline < .now {
            setIconToDeadlineMiss()
            return
        }
        setIconToNotDone()
    }

    // MARK: Private funcs
    private func setIconToDone() {
        doneIcon.image = UIImage(systemName: "checkmark.circle.fill")
        doneIcon.tintColor = .systemGreen
    }

    private func setIconToNotDone() {
        doneIcon.image = UIImage(systemName: "circle")
        doneIcon.tintColor = AppConstants.Colors.separatorColor
    }

    private func setIconToDeadlineMiss() {
        doneIcon.image = UIImage(systemName: "circle")
        doneIcon.tintColor = .red
    }

    private func dateStr(from deadline: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter.string(from: deadline)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate(
                containerView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
                containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

                doneIcon.widthAnchor.constraint(equalToConstant: Constants.doneIconSize),
                doneIcon.heightAnchor.constraint(equalToConstant: Constants.doneIconSize),

                cellContent.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor),
                cellContent.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor
                                           ),
                cellContent.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
                cellContent.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)

            )
    }

    private func setUpViews() {
        textAndDate.addArrangedSubviews(text, dateView)
        cellContent.addArrangedSubviews(doneIcon, priorityIcon, textAndDate, chevronIcon)
        containerView.addSubview(cellContent)
        contentView.addSubview(containerView)
    }

    private let insets = UIEdgeInsets(top: Constants.gap,
                              left: Constants.gap,
                              bottom: Constants.gap,
                              right: Constants.gap)
}
