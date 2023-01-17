//
//  SequenceExtension.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 14/1/2023.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}