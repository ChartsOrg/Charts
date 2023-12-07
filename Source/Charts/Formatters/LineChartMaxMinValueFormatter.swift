//
//  LineChartMaxMinValueFormatter.swift
//  DGCharts
//
//  Created by Joy BIAN on 2023/12/4.
//

import UIKit

@objc(LineChartMaxMinValueFormatter)
open class LineChartMaxMinValueFormatter: NSObject, ValueFormatter
{
    public typealias Block = (
        _ value: Double,
        _ entry: ChartDataEntry,
        _ dataSetIndex: Int,
        _ viewPortHandler: ViewPortHandler?) -> String
    
    @objc open var block: Block?
    
    @objc open var hasAutoDecimals: Bool
    
    @objc open var formatter: NumberFormatter?
    {
        willSet
        {
            hasAutoDecimals = false
        }
    }
    
    open var decimals: Int?
    {
        didSet
        {
            setupDecimals(decimals: decimals)
        }
    }
    
    open var toProfit: Bool = true

    private func setupDecimals(decimals: Int?)
    {
        if let digits = decimals
        {
            formatter?.minimumFractionDigits = digits
            formatter?.maximumFractionDigits = digits
            formatter?.usesGroupingSeparator = true
        }
    }
    
    public override init()
    {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        decimals = 2
        hasAutoDecimals = true

        super.init()
        setupDecimals(decimals: decimals)
    }
    
    @objc public init(formatter: NumberFormatter, toProfit: Bool)
    {
        self.formatter = formatter
        self.toProfit = toProfit
        hasAutoDecimals = false

        super.init()
    }
    
    @objc public init(decimals: Int)
    {
        formatter = NumberFormatter()
        formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true

        super.init()
        setupDecimals(decimals: decimals)
    }
    
    @objc public init(block: @escaping Block)
    {
        self.block = block
        hasAutoDecimals = false

        super.init()
    }

    /// This function is deprecated - Use `init(block:)` instead.
    // DEC 11, 2017
    @available(*, deprecated, message: "Use `init(block:)` instead.")
    @objc public static func with(block: @escaping Block) -> DefaultValueFormatter
    {
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
            var finalValue = value
            if toProfit {
                finalValue = finalValue * 100
                let text = formatter?.string(from: NSNumber(floatLiteral: finalValue)) ?? ""
                return text.isEmpty ? text:"\(text)%"
            }
            return formatter?.string(from: NSNumber(floatLiteral: finalValue)) ?? ""
        }
    }
}
