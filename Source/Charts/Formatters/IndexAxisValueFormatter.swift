//
//  IndexAxisValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// This formatter is used for passing an array of x-axis labels, on whole x steps.
@objc(ChartIndexAxisValueFormatter)
open class IndexAxisValueFormatter: NSObject, IAxisValueFormatter
{
    @objc public var values = [String]()

    public override init()
    {
        super.init()
    }
    
    @objc public init(values: [String])
    {
        super.init()
        
        self.values = values
    }
    
    @objc public static func with(values: [String]) -> IndexAxisValueFormatter?
    {
        return IndexAxisValueFormatter(values: values)
    }
    
    open func stringForValue(_ value: Double,
                             axis: AxisBase?) -> String
    {
        let index = Int(value.rounded())
        
        if index < 0 || index >= values.count || index != Int(value)
        {
            return ""
        }
        
        return values[index]
    }
}
