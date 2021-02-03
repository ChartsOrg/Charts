//
//  DefaultAxisValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public struct DefaultAxisValueFormatter: AxisValueFormatter {
    public var formatter: NumberFormatter?

    // TODO: Documentation. Especially the nil case
    public var decimals: Int? {
        didSet {
            if let digits = decimals {
                formatter?.minimumFractionDigits = digits
                formatter?.maximumFractionDigits = digits
                formatter?.usesGroupingSeparator = true
            }
        }
    }

    public init() {
        formatter = NumberFormatter()
    }

    public init(formatter: NumberFormatter) {
        self.formatter = formatter
    }

    public init(decimals: Int) {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        self.decimals = decimals    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
    }
}
