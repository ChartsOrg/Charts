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

@objc(ChartDefaultValueFormatter)
open class DefaultValueFormatter: NSObject, IValueFormatter
{
    public typealias Block = (
        _ value: Double,
        _ entry: ChartDataEntry,
        _ dataSetIndex: Int,
        _ viewPortHandler: ViewPortHandler?) -> String
    
    open var block: Block?
    
    open var hasAutoDecimals: Bool = false
    
    fileprivate var _formatter: NumberFormatter?
    open var formatter: NumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }
    
    fileprivate var _decimals: Int?
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
    
    public override init()
    {
        super.init()
        
        self.formatter = NumberFormatter()
        hasAutoDecimals = true
    }
    
    public init(formatter: NumberFormatter)
    {
        super.init()
        
        self.formatter = formatter
    }
    
    public init(decimals: Int)
    {
        super.init()
        
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    public init(block: @escaping Block)
    {
        super.init()
        
        self.block = block
    }
    
    public static func with(block: @escaping Block) -> DefaultValueFormatter?
    {
        return DefaultValueFormatter(block: block)
    }
    
    open func stringForValue(_ value: Double,
                             entry: ChartDataEntry,
                             dataSetIndex: Int,
                             viewPortHandler: ViewPortHandler?) -> String
    {
        if block != nil
        {
            return block!(value, entry, dataSetIndex, viewPortHandler)
        }
        else
        {
            return formatter?.string(from: NSNumber(floatLiteral: value)) ?? ""
        }
    }
    
}
