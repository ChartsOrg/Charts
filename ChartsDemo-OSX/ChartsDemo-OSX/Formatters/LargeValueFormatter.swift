//
//  FeedItem.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//  https://en.wikipedia.org/wiki/Metric_prefix

import Foundation
import Charts

open class LargeValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter
{
    fileprivate static let MAX_LENGTH = 5
    fileprivate static let MIN_LENGTH = -5
    
    /// Suffix to be appended after the values.
    ///
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    open var suffix = ["p","n","µ", "m", "" ,"k", "M", "G", "T"]
    
    /// An appendix text to be added at the end of the formatted value.
    open var appendix: String?
    
    public override init()
    {
    }
    
    public init(appendix: String?)
    {
        self.appendix = appendix
    }
    
    fileprivate func format(value: Double) -> String
    {
        var sig = abs(value)
        let sign = value / abs(value)
        var length = 0
        let maxLength = (suffix.count / 2) - 1
        
        if sig >= 1000
        {
            while sig >= 1000.0 && length < maxLength
            {
                sig /= 1000.0
                length += 1
            }
        }
        else
        {
            while sig <= 1 && length < maxLength
            {
                sig *= 1000.0
                length += 1
            }
        }
        
        var r = String(format: "%2.f", sig * sign) + suffix[length + 4]
        
        if appendix != nil
        {
            r += appendix!
        }
        
        return r
    }
    
    open func stringForValue(
        _ value: Double, axis: AxisBase?) -> String
    {
        return format(value: value)
    }
    
    open func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String
    {
        return format(value: value)
    }
}
