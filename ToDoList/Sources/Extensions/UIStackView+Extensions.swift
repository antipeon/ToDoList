//
//  UIView+Extensions.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 30.07.2022.
//

import UIKit

extension UIStackView {

    func addArrangedSubviews(_ views: UIView...) {
        addArrangedSubviews(views)
    }

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }

    static func makeVStackView() -> UIStackView {
        let view = makeStackView()
        view.axis = .vertical
        return view
    }

    static func makeHStackView() -> UIStackView {
        let view = makeStackView()
        view.axis = .horizontal
        return view
    }

    static func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
