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
open class IndexAxisValueFormatter: AxisValueFormatter
{
    public var values: [String] = [String]()

    public init()
    {

    }
    
    public init(values: [String])
    {        
        self.values = values
    }
    
    public static func with(values: [String]) -> IndexAxisValueFormatter?
    {
        return IndexAxisValueFormatter(values: values)
    }
    
    open func stringForValue(_ value: Double,
                             axis: AxisBase?) -> String
    {
        let index = Int(value.rounded())
        guard values.indices.contains(index), index == Int(value) else { return "" }
        return values[index]
    }
}
