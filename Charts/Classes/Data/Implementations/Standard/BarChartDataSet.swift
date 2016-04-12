//
//  BarChartDataSet.swift
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
import CoreGraphics


public class BarChartDataSet: BarLineScatterCandleBubbleChartDataSet, IBarChartDataSet
{
    private func initialize()
    {
        self.highlightColor = NSUIColor.blackColor()
        
        self.calcStackSize(yVals as! [BarChartDataEntry])
        self.calcEntryCountIncludingStacks(yVals as! [BarChartDataEntry])
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        initialize()
    }

    // MARK: - Data functions and accessors
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    private var _stackSize = 1
    
    /// the overall entry count, including counting each stack-value individually
    private var _entryCountStacks = 0
    
    /// Calculates the total number of entries this DataSet represents, including
    /// stacks. All values belonging to a stack are calculated separately.
    private func calcEntryCountIncludingStacks(yVals: [BarChartDataEntry]!)
    {
        _entryCountStacks = 0
        
        for i in 0 ..< yVals.count
        {
            let vals = yVals[i].values
            
            if (vals == nil)
            {
                _entryCountStacks += 1
            }
            else
            {
                _entryCountStacks += vals!.count
            }
        }
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(yVals: [BarChartDataEntry]!)
    {
        for i in 0 ..< yVals.count
        {
            if let vals = yVals[i].values
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
    }
    
    public override func calcMinMax(start start : Int, end: Int)
    {
        let yValCount = _yVals.count
        
        if yValCount == 0
        {
            return
        }
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for i in start.stride(through: endValue, by: 1)
        {
            if let e = _yVals[i] as? BarChartDataEntry
            {
                if !e.value.isNaN
                {
                    if e.values == nil
                    {
                        if e.value < _yMin
                        {
                            _yMin = e.value
                        }
                        
                        if e.value > _yMax
                        {
                            _yMax = e.value
                        }
                    }
                    else
                    {
                        if -e.negativeSum < _yMin
                        {
                            _yMin = -e.negativeSum
                        }
                        
                        if e.positiveSum > _yMax
                        {
                            _yMax = e.positiveSum
                        }
                    }
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    /// - returns: the maximum number of bars that can be stacked upon another in this DataSet.
    public var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: true if this DataSet is stacked (stacksize > 1) or not.
    public var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// - returns: the overall entry count, including counting each stack-value individually
    public var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    /// array of labels used to describe the different values of the stacked bars
    public var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// space indicator between the bars in percentage of the whole width of one value (0.15 == 15% of bar width)
    public var barSpace: CGFloat = 0.15
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    public var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    public var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    public var barBorderColor = NSUIColor.blackColor()

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    public var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BarChartDataSet
        copy._stackSize = _stackSize
        copy._entryCountStacks = _entryCountStacks
        copy.stackLabels = stackLabels
        copy.barSpace = barSpace
        copy.barShadowColor = barShadowColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}