//
//  PriorityView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

class PriorityView: UIView {
    enum Constants {
        static let prioritySwitchHeight: CGFloat = 36
        static let priorityLabelHeight: CGFloat = 22
        static let priorityLabelLeftInset: CGFloat = 10
        static let prioritySwitchWidth: CGFloat = 150
    }
    
    // MARK: - Views
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = AppConstants.Fonts.body
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var prioritySwitch: UISegmentedControl = {
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
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private funcs
    private func setUp() {
        prioritySwitchAndLabel.addArrangedSubviews(priorityLabel, prioritySwitch)
        addSubview(prioritySwitchAndLabel)
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate(
            prioritySwitchAndLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: Constants.priorityLabelLeftInset),
            prioritySwitchAndLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            prioritySwitchAndLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            prioritySwitchAndLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            
            prioritySwitch.heightAnchor.constraint(equalToConstant: Constants.prioritySwitchHeight),
            priorityLabel.heightAnchor.constraint(equalToConstant: Constants.priorityLabelHeight),
            
            
            prioritySwitch.leftAnchor.constraint(equalTo: priorityLabel.rightAnchor),
            prioritySwitch.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.prioritySwitchWidth)
        )
    }
}
