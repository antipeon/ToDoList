//
//  NSLayoutConstraint+Extensions.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 07.08.2022.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    class func activate(_ constraints: NSLayoutConstraint...) {
        activate(constraints)
    }

    class func deactivate(_ constaints: NSLayoutConstraint...) {
        deactivate(constaints)
    }
}
