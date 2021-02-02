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

open class DefaultAxisValueFormatter: AxisValueFormatter
{
    public typealias Block = (
        _ value: Double,
        _ axis: AxisBase?) -> String
    
    open var block: Block?
    
    open var hasAutoDecimals: Bool = false
    
    private var _formatter: NumberFormatter?
    open var formatter: NumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }

    // TODO: Documentation. Especially the nil case
    private var _decimals: Int?
    open var decimals: Int?
    {
        get { return _decimals }
        set
        {
            _decimals = newValue
            
            if let digits = newValue
            {
                self.formatter?.minimumFractionDigits = digits
                self.formatter?.maximumFractionDigits = digits
                self.formatter?.usesGroupingSeparator = true
            }
        }
    }
    
    public init()
    {
        self.formatter = NumberFormatter()
        hasAutoDecimals = true
    }
    
    public init(formatter: NumberFormatter)
    {
        self.formatter = formatter
    }
    
    public init(decimals: Int)
    {
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    public init(block: @escaping Block)
    {
        self.block = block
    }
    
    public static func with(block: @escaping Block) -> DefaultAxisValueFormatter?
    {
        return DefaultAxisValueFormatter(block: block)
    }
    
    open func stringForValue(_ value: Double,
                               axis: AxisBase?) -> String
    {
        if let block = block {
            return block(value, axis)
        } else {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
}
