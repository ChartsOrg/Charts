//
//  RandomAccessCollection+BinarySearch.swift
//  Charts
//
//  Created by Jacob Christie on 2019-01-13.
//

import Foundation

extension RandomAccessCollection {
    /// In a sorted collection, finds the correct insertion point of an
    /// arbitrary value as compared to `Element`.
    ///
    /// - Parameters:
    ///   - value: the arbitrary value to be inserted, if transformed into `Element`
    ///   - sortedAscending: the method in which to compare the value to `Element`
    /// - Returns: The index in which to insert value, given it is transformed into `Element`
    func sortedInsertionPoint<T>(
        of value: T,
        _ sortedAscending: (T, Element) -> Bool
    ) -> Index {
        var slice = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if sortedAscending(value, slice[middle]) {
                slice = slice[..<middle]
            } else {
                slice = slice[slice.index(after: middle)...]
            }
        }

        return slice.startIndex
    }

    /// In a sorted collection, finds the indices of `Element` which equal an
    /// arbitrary value.
    ///
    /// - Parameters:
    ///   - value: the arbitrary value in which to search for
    ///   - sortedAscending: the method in which to compare the value to `Element`
    ///   - isEqual: the method in which to equate the value to `Element`
    /// - Returns: The indices which match `value`
    func sortedIndices<T>(
        of value: T,
        sortedAscending: (T, Element) -> Bool,
        isEqual: (T, Element) -> Bool
    ) -> Swift.Range<Index> {
        let last = sortedInsertionPoint(of: value, sortedAscending)
        var first = last

        while first > startIndex, isEqual(value, self[index(before: first)]) {
            first = index(before: first)
        }

        return first..<last
    }
}
