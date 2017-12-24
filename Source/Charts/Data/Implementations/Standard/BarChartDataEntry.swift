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
    /// The values the stacked barchart holds.
    @objc open private(set) var yValues: [Double]? {
        willSet {
            self.y = BarChartDataEntry.calcSum(values: newValue)
        }

        didSet {
            calcPosNegSum()
            calcRanges()
        }
    }
    
    /// The ranges of the individual stack-entries. Will return null if this entry is not stacked.
    @objc open private(set) var ranges: [Range]?

    /// The sum of all negative values this entry (if stacked) contains. (this is a positive number)
    @objc open private(set) var negativeSum: Double = 0.0
    
    /// The sum of all positive values this entry (if stacked) contains.
    @objc open private(set) var positiveSum: Double = 0.0

    /// the values the stacked barchart holds
    @objc open var isStacked: Bool { return yValues != nil }

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
        self.yValues = yValues
        calcPosNegSum()
        calcRanges()
    }
        
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], data: AnyObject?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), data: data)
        self.yValues = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), icon: icon, data: data)
        self.yValues = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public init(x: Double, yValues: [Double], icon: NSUIImage?)
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues), icon: icon)
        self.yValues = yValues
        calcPosNegSum()
        calcRanges()
    }
    
    @objc open func sumBelow(stackIndex :Int) -> Double
    {
        guard let yVals = yValues else
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

    @objc open func calcPosNegSum()
    {
        guard let _yVals = yValues else
        {
            positiveSum = 0.0
            negativeSum = 0.0
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
        
        negativeSum = sumNeg
        positiveSum = sumPos
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
        
        if ranges == nil
        {
            ranges = [Range]()
        }
        else
        {
            ranges?.removeAll()
        }
        
        ranges?.reserveCapacity(values!.count)
        
        var negRemain = -negativeSum
        var posRemain: Double = 0.0
        
        for i in 0 ..< values!.count
        {
            let value = values![i]
            
            if value < 0
            {
                ranges?.append(Range(from: negRemain, to: negRemain - value))
                negRemain -= value
            }
            else
            {
                ranges?.append(Range(from: posRemain, to: posRemain + value))
                posRemain += value
            }
        }
    }

    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BarChartDataEntry
        copy.yValues = yValues
        copy.y = y
        copy.negativeSum = negativeSum
        return copy
    }
    
    /// Calculates the sum across all values of the given stack.
    ///
    /// - parameter vals:
    /// - returns:
    private static func calcSum(values: [Double]?) -> Double
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
