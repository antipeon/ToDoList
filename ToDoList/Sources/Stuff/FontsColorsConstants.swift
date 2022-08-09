//
//  FontsColorsConstants.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 03.08.2022.
//

import Foundation
import UIKit

struct AppConstants {
    struct Colors {
        static let secondary = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let backPrimary = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        static let supporNavBar = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)
        static let separatorColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        static let labelTertiary = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        static let labelPrimary = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        static let lightGray = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
        static let lightGreen = UIColor(red: 52, green: 199, blue: 89, alpha: 91)
    }

    struct Fonts {
        static let body: UIFont = .systemFont(ofSize: 22)
        static let subhead: UIFont = .systemFont(ofSize: 20)
        static let subheadBold: UIFont = .systemFont(ofSize: 20, weight: .bold)
        static let footnote: UIFont = .systemFont(ofSize: 18, weight: .bold)
    }
}
