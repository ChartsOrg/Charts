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
public class DefaultValueFormatter: NSObject, IValueFormatter
{
    
    public var hasAutoDecimals: Bool = false
    
    private var _formatter: NSNumberFormatter?
    public var formatter: NSNumberFormatter?
    {
        get { return _formatter }
        set
        {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }
    
    private var _decimals: Int?
    public var decimals: Int?
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
        
        self.formatter = NSNumberFormatter()
        hasAutoDecimals = true
    }
    
    public init(formatter: NSNumberFormatter)
    {
        super.init()
        
        self.formatter = formatter
    }
    
    public init(decimals: Int)
    {
        super.init()
        
        self.formatter = NSNumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    public func stringForValue(value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String
    {
        return formatter?.stringFromNumber(value) ?? ""
    }
    
}