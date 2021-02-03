//
//  DefaultValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// The default value formatter used for all chart components that needs a default
public struct DefaultValueFormatter: ValueFormatter {
    public let formatter: NumberFormatter

    public var decimals: Int = 1 {
        didSet {
            setupDecimals(decimals)
        }
    }

    private func setupDecimals(_ decimals: Int) {
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.usesGroupingSeparator = true
    }

    public init(decimals: Int = 1) {
        self.formatter = NumberFormatter()
        self.formatter.usesGroupingSeparator = true

        self.decimals = decimals
    }

    public init(formatter: NumberFormatter) {
        self.formatter = NumberFormatter()
    }

    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int
    ) -> String {
        formatter.string(from: value as NSNumber) ?? ""
    }
}
