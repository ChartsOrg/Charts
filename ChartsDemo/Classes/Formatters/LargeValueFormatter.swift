//
//  LargeValueFormatter.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import Charts

public class LargeValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter
{
    private static let MAX_LENGTH = 5
    
    /// Suffix to be appended after the values.
    ///
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    public var suffix = ["", "k", "m", "b", "t"]
    
    /// An appendix text to be added at the end of the formatted value.
    public var appendix: String?
    
    public override init()
    {
        
    }
    
    public init(appendix: String?)
    {
        self.appendix = appendix
    }
    
    private func format(value: Double) -> String
    {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1
        
        while sig >= 1000.0 && length < maxLength
        {
            sig /= 1000.0
            length += 1
        }
        
        var r = String(format: "%2.f", sig) + suffix[length]
        
        if appendix != nil
        {
            r += appendix!
        }
        
        return r
    }
    
    public func stringForValue(value: Double, axis: AxisBase?) -> String
    {
        return format(value)
    }
    
    public func stringForValue(value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String
    {
        return format(value)
    }
}
