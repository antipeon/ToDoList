//
//  Collection+Extensions.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 31.07.2022.
//

import Foundation

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Index? {
        firstIndex { $0.id == element.id }
    }
}
