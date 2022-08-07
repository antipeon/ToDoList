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
}
