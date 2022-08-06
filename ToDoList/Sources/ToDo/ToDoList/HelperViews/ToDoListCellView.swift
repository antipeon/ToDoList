//
//  ToDoListCellView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

class Cell: UITableViewCell {
    enum Constants {
        static let gap: CGFloat = 16
        static let reuseId: String = "cellId"
        static let maxNumberOfLinesInTextView = 3
        static let cellHorizontalSpacing: CGFloat = 5
        static let doneIconSize: CGFloat = 24
    }
    
    private lazy var text: UILabel = {
        let view = UILabel()
        view.numberOfLines = Constants.maxNumberOfLinesInTextView
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
    
    private lazy var doneIcon: UIImageView = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.font = AppConstants.Fonts.subhead
//        label.textColor = AppConstants.Colors.labelTertiary
//        let configuration = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .large)
//        let label = UIImage(systemName: "calendar", withConfiguration: configuration)

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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textAndDate.addArrangedSubviews(text, dateView)
        
//        containerView.addSubview(text)
        cellContent.addArrangedSubviews(doneIcon, priorityIcon, textAndDate, chevronIcon)
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
                
                doneIcon.widthAnchor.constraint(equalToConstant: Constants.doneIconSize),
                doneIcon.heightAnchor.constraint(equalToConstant: Constants.doneIconSize),
                
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
    
    // MARK: - UITableViewCell
    override func prepareForReuse() {
        text.attributedText = nil
        
        text.textColor = .black
        text.font = AppConstants.Fonts.body
    }
    
    // MARK: - Modify Views func
    func setToDoText(with item: ToDoItem) {
        guard item.done else {
            text.text = item.text
            return
        }
        
        let attrString = NSMutableAttributedString(string: item.text)
        attrString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attrString.length))
        text.textColor = AppConstants.Colors.labelTertiary
        
        text.attributedText = attrString
        
        
    }
    
    func setDeadline(with deadline: Date?) {
        if let deadline = deadline {
            dateView.isHidden = false
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
    
    func setDone(with done: Bool) {
        if done {
            setIconToDone()
            return
        }
        setIconToNotDone()
        setNeedsDisplay()
    }
    
    private func setIconToDone() {
        doneIcon.image = UIImage(systemName: "checkmark.circle.fill")
        doneIcon.tintColor = .systemGreen
    }
    
    private func setIconToNotDone() {
        doneIcon.image = UIImage(systemName: "circle")
        doneIcon.tintColor = AppConstants.Colors.separatorColor
    }
}
