//
//  SwitchSectionView.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

class SwitchSectionView: UIView {

    
    // MARK: - Views
    private lazy var switchSection: UIStackView = {
        let view = UIStackView.makeVStackView()
        return view
    }()
    
    lazy var prioritySwitchAndLabel = PriorityView(frame: .zero)
    
    lazy var deadlineView: DeadlineView = DeadlineView(frame: .zero)
    
    private lazy var dividerView1: UIView = {
        ToDoItemView.getDivider()
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        switchSection.addArrangedSubviews(prioritySwitchAndLabel, dividerView1, deadlineView)
        addSubview(switchSection)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate(
            dividerView1.heightAnchor.constraint(equalToConstant: ToDoItemView.Constants.dividerHeight),
            prioritySwitchAndLabel.heightAnchor.constraint(equalTo: deadlineView.heightAnchor),
            
            switchSection.leftAnchor.constraint(equalTo: leftAnchor),
            switchSection.rightAnchor.constraint(equalTo: rightAnchor),
            switchSection.bottomAnchor.constraint(equalTo: bottomAnchor),
            switchSection.topAnchor.constraint(equalTo: topAnchor)
        )
    }
}
