//
//  Range.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

// TODO: Remove
open class Range {
    open var from: Double
    open var to: Double

    public init(from: Double, to: Double) {
        self.from = from
        self.to = to
    }

    /// - Parameters:
    ///   - value:
    /// - Returns: `true` if this range contains (if the value is in between) the given value, `false` ifnot.
    open func contains(_ value: Double) -> Bool {
        if value > from, value <= to {
            return true
        } else {
            return false
        }
    }
}
