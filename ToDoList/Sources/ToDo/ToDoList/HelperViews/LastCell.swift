//
//  LastCell.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 06.08.2022.
//

import UIKit

class LastCell: UITableViewCell {
    private lazy var footer: UIView = {
        let label = UILabel()
        label.text = "Новое"
        label.font = AppConstants.Fonts.body
        label.textColor = AppConstants.Colors.labelTertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.preservesSuperviewLayoutMargins = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 0)
        view.addSubview(footer)
        return view
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            
            footer.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            footer.topAnchor.constraint(equalTo: containerView.topAnchor),
            footer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            footer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            footer.widthAnchor.constraint(equalToConstant: 100),
//            footer.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
