//
//  LargeValueFormatter.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Charts
import Foundation

open class LargeValueFormatter: NSObject, ValueFormatter, AxisValueFormatter {
    fileprivate static let MAX_LENGTH = 5

    /// Suffix to be appended after the values.
    ///
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    open var suffix = ["", "k", "m", "b", "t"]

    /// An appendix text to be added at the end of the formatted value.
    open var appendix: String?

    override public init() {}

    public init(appendix: String?) {
        self.appendix = appendix
    }

    fileprivate func format(value: Double) -> String {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1

        while sig >= 1000.0, length < maxLength {
            sig /= 1000.0
            length += 1
        }

        var r = String(format: "%2.f", sig) + suffix[length]

        if appendix != nil {
            r += appendix!
        }

        return r
    }

    open func stringForValue(
        _ value: Double, axis _: AxisBase?
    ) -> String {
        return format(value: value)
    }

    open func stringForValue(
        _ value: Double,
        entry _: ChartDataEntry,
        dataSetIndex _: Int,
        viewPortHandler _: ViewPortHandler?
    ) -> String {
        return format(value: value)
    }
}
