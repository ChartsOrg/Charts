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
open class DefaultValueFormatter: ValueFormatter {
    public typealias Block = (
        _ value: Double,
        _ entry: ChartDataEntry,
        _ dataSetIndex: Int,
        _ viewPortHandler: ViewPortHandler?
    ) -> String

    open var block: Block?

    open var hasAutoDecimals: Bool

    open var formatter: NumberFormatter? {
        willSet {
            hasAutoDecimals = false
        }
    }

    open var decimals: Int? {
        didSet {
            setupDecimals(decimals: decimals)
        }
    }

    private func setupDecimals(decimals: Int?) {
        if let digits = decimals {
            formatter?.minimumFractionDigits = digits
            formatter?.maximumFractionDigits = digits
            formatter?.usesGroupingSeparator = true
        }
    }

    public init() {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        decimals = 1
        hasAutoDecimals = true

        setupDecimals(decimals: decimals)
    }

    public init(formatter: NumberFormatter) {
        self.formatter = formatter
        hasAutoDecimals = false
    }

    public init(decimals: Int) {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true

        setupDecimals(decimals: decimals)
    }

    public init(block: @escaping Block) {
        self.block = block
        hasAutoDecimals = false
    }

    /// This function is deprecated - Use `init(block:)` instead.
    // DEC 11, 2017
    @available(*, deprecated, message: "Use `init(block:)` instead.")
    public static func with(block: @escaping Block) -> DefaultValueFormatter {
        return DefaultValueFormatter(block: block)
    }

    open func stringForValue(_ value: Double,
                             entry: ChartDataEntry,
                             dataSetIndex: Int,
                             viewPortHandler: ViewPortHandler?) -> String
    {
        if let block = block {
            return block(value, entry, dataSetIndex, viewPortHandler)
        } else {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
}
