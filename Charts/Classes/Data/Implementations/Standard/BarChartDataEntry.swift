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
//  https://github.com/danielgindi/Charts
//

import Foundation

open class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    private var _values: [Double]?
    
    /// the sum of all negative values this entry (if stacked) contains
    private var _negativeSum: Double = 0.0
    
    /// the sum of all positive values this entry (if stacked) contains
    private var _positiveSum: Double = 0.0
    
    public required init()
    {
        super.init()
    }
    
    /// Constructor for stacked bar entries.
    public init(values: [Double], xIndex: Int)
    {
        super.init(value: BarChartDataEntry.calcSum(values), xIndex: xIndex)
        self.values = values
        calcPosNegSum()
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
    public override init(value: Double, xIndex: Int, data: Any?)
    {
        super.init(value: value, xIndex: xIndex, data: data)
    }
    
    open func getBelowSum(_ stackIndex :Int) -> Double
    {
        if (values == nil)
        {
            return 0
        }
        
        var remainder: Double = 0.0
        var index = values!.count - 1
        
        while (index > stackIndex && index >= 0)
        {
            remainder += values![index]
            index -= 1
        }
        
        return remainder
    }
    
    /// - returns: the sum of all negative values this entry (if stacked) contains. (this is a positive number)
    open var negativeSum: Double
    {
        return _negativeSum
    }
    
    /// - returns: the sum of all positive values this entry (if stacked) contains.
    open var positiveSum: Double
    {
        return _positiveSum
    }

    open func calcPosNegSum()
    {
        if _values == nil
        {
            _positiveSum = 0.0
            _negativeSum = 0.0
            return
        }
        
        var sumNeg: Double = 0.0
        var sumPos: Double = 0.0
        
        for f in _values!
        {
            if f < 0.0
            {
                sumNeg += -f
            }
            else
            {
                sumPos += f
            }
        }
        
        _negativeSum = sumNeg
        _positiveSum = sumPos
    }

    // MARK: Accessors
    
    /// the values the stacked barchart holds
    open var isStacked: Bool { return _values != nil }
    
    /// the values the stacked barchart holds
    open var values: [Double]?
    {
        get { return self._values }
        set
        {
            self.value = BarChartDataEntry.calcSum(newValue)
            self._values = newValue
            calcPosNegSum()
        }
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! BarChartDataEntry
        copy._values = _values
        copy.value = value
        copy._negativeSum = _negativeSum
        return copy
    }
    
    /// Calculates the sum across all values of the given stack.
    ///
    /// - parameter vals:
    /// - returns:
    private static func calcSum(_ vals: [Double]?) -> Double
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
