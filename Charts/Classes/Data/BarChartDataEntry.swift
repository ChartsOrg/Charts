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
    public var values: [Float]!
    
    /// Constructor for stacked bar entries.
    public init(values: [Float], xIndex: Int)
    {
        super.init(value: BarChartDataEntry.calcSum(values), xIndex: xIndex);
        self.values = values;
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(value: Float, xIndex: Int)
    {
        super.init(value: value, xIndex: xIndex);
    }
    
    /// Constructor for stacked bar entries.
    public init(values: [Float], xIndex: Int, label: String)
    {
        super.init(value: BarChartDataEntry.calcSum(values), xIndex: xIndex, data: label);
        self.values = values;
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(value: Float, xIndex: Int, data: AnyObject?)
    {
        super.init(value: value, xIndex: xIndex, data: data)
    }

    /// Returns the closest value inside the values array (for stacked barchart)
    /// to the value given as a parameter. The closest value must be higher
    /// (above) the provided value.
    public func getClosestIndexAbove(value: Float) -> Int
    {
        if (values == nil)
        {
            return 0;
        }
        
        var index = values.count - 1;
        var remainder: Float = 0.0;
        
        while (index > 0 && value > values[index] + remainder)
        {
            remainder += values[index];
            index--;
        }
        
        return index;
    }
    
    public func getBelowSum(stackIndex :Int) -> Float
    {
        if (values == nil)
        {
            return 0;
        }
        
        var remainder: Float = 0.0;
        var index = values.count - 1;
        
        while (index > stackIndex && index >= 0)
        {
            remainder += values[index];
            index--;
        }
        
        return remainder;
    }

    /// Calculates the sum across all values.
    private class func calcSum(values: [Float]) -> Float
    {
        var sum = Float(0.0);

        for f in values
        {
            sum += f;
        }

        return sum;
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! BarChartDataEntry;
        copy.values = values;
        return copy;
    }
}