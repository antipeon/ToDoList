//
//  Spinner.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 12.08.2022.
//

import UIKit

class SpinnerView: UIView {
    lazy var spinner: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .large)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
