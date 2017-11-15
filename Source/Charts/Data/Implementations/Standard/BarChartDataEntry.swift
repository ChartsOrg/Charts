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

open class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    fileprivate var _yVals: [Double]?
    
    /// the ranges for the individual stack values - automatically calculated
    fileprivate var _ranges: [Range]?
    
    /// the sum of all negative values this entry (if stacked) contains
    fileprivate var _negativeSum: Double = 0.0
    
    /// the sum of all positive values this entry (if stacked) contains
    fileprivate var _positiveSum: Double = 0.0
    
    public required init()
    {
        super.init()
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double)
    {
        super.init(x: x, y: y)
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double, data: AnyObject?)
    {
        super.init(x: x, y: y, data: data)
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double, icon: NSUIImage?)
    {
        super.init(x: x, y: y, icon: icon)
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: x, y: y, icon: icon, data: data)
    }
    
    /// Constructor for stacked bar entries.
    @objc public init(x: Double, yValues: [Double])
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues))
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// This constructor is misleading, please use the `data` argument instead of `label`.
    @objc @available(*, deprecated: 1.0, message: "Use `data` argument instead of `label`.")
    public init(x: Double, yValues: [Double], label: String)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), data: label as AnyObject?)
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], data: AnyObject?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), data: data)
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), icon: icon, data: data)
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], icon: NSUIImage?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), icon: icon)
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    @objc open func sumBelow(stackIndex :Int) -> Double
    {
        guard let yVals = _yVals else
        {
            return 0
        }
        
        var remainder: Double = 0.0
        var index = yVals.count - 1
        
        while (index > stackIndex && index >= 0)
        {
            remainder += yVals[index]
            index -= 1
        }
        
        return remainder
    }
    
    /// - returns: The sum of all negative values this entry (if stacked) contains. (this is a positive number)
    @objc open var negativeSum: Double
    {
        return _negativeSum
    }
    
    /// - returns: The sum of all positive values this entry (if stacked) contains.
    @objc open var positiveSum: Double
    {
        return _positiveSum
    }

    @objc open func calcPosNegSum()
    {
        guard let _yVals = _yVals else
        {
            _positiveSum = 0.0
            _negativeSum = 0.0
            return
        }
        
        var sumNeg: Double = 0.0
        var sumPos: Double = 0.0
        
        for f in _yVals
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
    @objc open func calcRanges()
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
                _ranges?.append(Range(from: negRemain, to: negRemain - value))
                negRemain -= value
            }
            else
            {
                _ranges?.append(Range(from: posRemain, to: posRemain + value))
                posRemain += value
            }
        }
    }
    
    // MARK: Accessors
    
    /// the values the stacked barchart holds
    @objc open var isStacked: Bool { return _yVals != nil }
    
    /// the values the stacked barchart holds
    @objc open var yValues: [Double]?
    {
        get { return self._yVals }
        set
        {
            self.y = BarChartDataEntry.calcSum(values: newValue)
            self._yVals = newValue
            calcPosNegSum()
            calcRanges()
        }
    }
    
    /// - returns: The ranges of the individual stack-entries. Will return null if this entry is not stacked.
    @objc open var ranges: [Range]?
    {
        return _ranges
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
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
    fileprivate static func calcSum(values: [Double]?) -> Double
    {
        guard let values = values
            else { return 0.0 }
        
        var sum = 0.0
        
        for f in values
        {
            sum += f
        }
        
        return sum
    }
}
