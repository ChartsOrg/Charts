//
//  BarChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class BarChartDataSet: BarLineScatterCandleBubbleChartDataSet, IBarChartDataSet
{
    fileprivate func initialize()
    {
        self.highlightColor = NSUIColor.black
        
        self.calcStackSize(entries: values as! [BarChartDataEntry])
        self.calcEntryCountIncludingStacks(entries: values as! [BarChartDataEntry])
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(values: [ChartDataEntry], label: String)
    {
        super.init(values: values, label: label)
        initialize()
    }

    // MARK: - Data functions and accessors
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    fileprivate var _stackSize = 1
    
    /// the overall entry count, including counting each stack-value individually
    fileprivate var _entryCountStacks = 0
    
    /// Calculates the total number of entries this DataSet represents, including
    /// stacks. All values belonging to a stack are calculated separately.
    fileprivate func calcEntryCountIncludingStacks(entries: [BarChartDataEntry])
    {
        _entryCountStacks = 0
        
        entries.forEach { _entryCountStacks += $0.yValues?.count ?? 1 }
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    fileprivate func calcStackSize(entries: [BarChartDataEntry])
    {
        for e in entries
        {
            guard let vals = e.yValues, vals.count > _stackSize else {
                continue
            }
            _stackSize = vals.count
        }
    }
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? BarChartDataEntry,
            !e.y.isNaN
            else { return }
        
        if e.yValues == nil
        {
            _yMin = min(e.y, _yMin)
            _yMax = max(e.y, _yMax)
        }
        else
        {
            _yMin = min(-e.negativeSum, _yMin)
            _yMax = max(e.positiveSum, _yMax)
        }

        calcMinMaxX(entry: e)
    }
    
    /// - returns: The maximum number of bars that can be stacked upon another in this DataSet.
    open var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: `true` if this DataSet is stacked (stacksize > 1) or not.
    open var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// - returns: The overall entry count, including counting each stack-value individually
    @objc open var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    /// array of labels used to describe the different values of the stacked bars
    open var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    open var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    open var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    open var barBorderColor = NSUIColor.black

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    open var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BarChartDataSet
        copy._stackSize = _stackSize
        copy._entryCountStacks = _entryCountStacks
        copy.stackLabels = stackLabels

        copy.barShadowColor = barShadowColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}
