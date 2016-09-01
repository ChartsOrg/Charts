//
//  BarChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    private var _yVals: [Double]?
    
    /// the ranges for the individual stack values - automatically calculated
    private var _ranges: [Range]?
    
    /// the sum of all negative values this entry (if stacked) contains
    private var _negativeSum: Double = 0.0
    
    /// the sum of all positive values this entry (if stacked) contains
    private var _positiveSum: Double = 0.0
    
    public required init()
    {
        super.init()
    }
    
    /// Constructor for stacked bar entries.
    public init(x: Double, yValues: [Double])
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(yValues))
        self._yVals = yValues
        calcRanges()
        calcPosNegSum()
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double)
    {
        super.init(x: x, y: y)
    }
    
    /// Constructor for stacked bar entries.
    public init(x: Double, yValues: [Double], label: String)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(yValues), data: label)
        self._yVals = yValues
        calcRanges()
        calcPosNegSum()
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double, data: AnyObject?)
    {
        super.init(x: x, y: y, data: data)
    }
    
    public func getBelowSum(stackIndex :Int) -> Double
    {
        if (_yVals == nil)
        {
            return 0
        }
        
        var remainder: Double = 0.0
        var index = _yVals!.count - 1
        
        while (index > stackIndex && index >= 0)
        {
            remainder += _yVals![index]
            index -= 1
        }
        
        return remainder
    }
    
    /// - returns: The sum of all negative values this entry (if stacked) contains. (this is a positive number)
    public var negativeSum: Double
    {
        return _negativeSum
    }
    
    /// - returns: The sum of all positive values this entry (if stacked) contains.
    public var positiveSum: Double
    {
        return _positiveSum
    }

    public func calcPosNegSum()
    {
        if _yVals == nil
        {
            _positiveSum = 0.0
            _negativeSum = 0.0
            return
        }
        
        var sumNeg: Double = 0.0
        var sumPos: Double = 0.0
        
        for f in _yVals!
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
    
    /// Splits up the stack-values of the given bar-entry into Range objects.
    /// - parameter entry:
    /// - returns:
    public func calcRanges()
    {
        let values = yValues
        if values?.isEmpty != false
        {
            return
        }
        
        if _ranges == nil
        {
            _ranges = [Range]()
        }
        else
        {
            _ranges?.removeAll()
        }
        
        _ranges?.reserveCapacity(values!.count)
        
        var negRemain = -negativeSum
        var posRemain: Double = 0.0
        
        for i in 0 ..< values!.count
        {
            let value = values![i]
            
            if value < 0
            {
                _ranges?.append(Range(from: negRemain, to: negRemain + abs(value)))
                negRemain += abs(value)
            }
            else
            {
                _ranges?.append(Range(from: posRemain, to: posRemain+value))
                posRemain += value
            }
        }
    }
    
    // MARK: Accessors
    
    /// the values the stacked barchart holds
    public var isStacked: Bool { return _yVals != nil }
    
    /// the values the stacked barchart holds
    public var yValues: [Double]?
    {
        get { return self._yVals }
        set
        {
            self.y = BarChartDataEntry.calcSum(newValue)
            self._yVals = newValue
            calcRanges()
            calcPosNegSum()
        }
    }
    
    /// - returns: The ranges of the individual stack-entries. Will return null if this entry is not stacked.
    public var ranges: [Range]?
    {
        return _ranges
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BarChartDataEntry
        copy._yVals = _yVals
        copy.y = y
        copy._negativeSum = _negativeSum
        return copy
    }
    
    /// Calculates the sum across all values of the given stack.
    ///
    /// - parameter vals:
    /// - returns:
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