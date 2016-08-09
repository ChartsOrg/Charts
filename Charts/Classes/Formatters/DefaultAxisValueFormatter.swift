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

@objc(ChartDefaultAxisValueFormatter)
public class DefaultAxisValueFormatter: NSObject, IAxisValueFormatter
{
    public var formatter: NSNumberFormatter?
    
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
    }
    
    public func stringForValue(value: Double,
                               axis: ChartAxisBase) -> String
    {
        return formatter?.stringFromNumber(value) ?? ""
    }
    
}