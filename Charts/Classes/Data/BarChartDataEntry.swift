//
//  BarChartDataEntry.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    private var _values: [Double]!
    
    /// the sum of all negative values this entry (if stacked) contains
    private var _negativeSum: Double = 0.0
    
    /// Constructor for stacked bar entries. Don't forget to order the stacked-values in an ascending order e.g. (-2,-1,0,1,2).
    public init(values: [Double], xIndex: Int)
    {
        super.init(value: BarChartDataEntry.calcSum(values), xIndex: xIndex)
        self.values = values
        calcNegativeSum()
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(value: Double, xIndex: Int)
    {
        super.init(value: value, xIndex: xIndex)
    }
    
    /// Constructor for stacked bar entries.
    public init(values: [Double], xIndex: Int, label: String)
    {
        super.init(value: BarChartDataEntry.calcSum(values), xIndex: xIndex, data: label)
        self.values = values
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(value: Double, xIndex: Int, data: AnyObject?)
    {
        super.init(value: value, xIndex: xIndex, data: data)
    }
    
    public func getBelowSum(stackIndex :Int) -> Double
    {
        if (values == nil)
        {
            return 0
        }
        
        var remainder: Double = 0.0
        var index = values.count - 1
        
        while (index > stackIndex && index >= 0)
        {
            remainder += values[index]
            index--
        }
        
        return remainder
    }
    
    /// :returns: the sum of all positive values this entry (if stacked) contains.
    public var positiveSum: Double
    {
        if _values == nil
        {
            return 0.0
        }
        
        var sum: Double = 0.0
        
        for f in _values
        {
            if f > 0.0
            {
                sum += f
            }
        }
        
        return sum
    }
    
    /// :returns: the sum of all negative values this entry (if stacked) contains. (this is a positive number)
    public var negativeSum: Double
    {
        return _negativeSum
    }

    public func calcNegativeSum()
    {
        if _values == nil
        {
            _negativeSum = 0.0
            return
        }
        
        var sum: Double = 0.0
        
        for f in _values
        {
            if f < 0.0
            {
                sum += abs(f)
            }
        }
        
        _negativeSum = sum
    }

    // MARK: Accessors

    /// the values the stacked barchart holds
    public var values: [Double]!
    {
        get { return self._values }
        set
        {
            self.value = BarChartDataEntry.calcSum(newValue)
            self._values = newValue
            calcNegativeSum()
        }
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! BarChartDataEntry
        copy._values = _values
        copy.value = value
        copy._negativeSum = _negativeSum
        return copy
    }
    
    /// Calculates the sum across all values of the given stack.
    ///
    /// :param: vals
    /// :returns:
    private static func calcSum(vals: [Double]?) -> Double
    {
        if vals == nil
        {
            return 0.0
        }
        
        var sum = 0.0
        
        for f in vals!
        {
            sum += f
        }
        
        return sum
    }
}