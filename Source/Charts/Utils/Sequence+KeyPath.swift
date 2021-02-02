//
//  Sequence+KeyPath.swift
//  Charts
//
//  Created by Jacob Christie on 2020-12-15.
//

extension Sequence {
    func max<T>(
        by keyPath: KeyPath<Element, T>,
        areInIncreasingOrder: (T, T) -> Bool
    ) -> Element? {
        self.max { areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }

    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        max(by: keyPath, areInIncreasingOrder: <)
    }
}
