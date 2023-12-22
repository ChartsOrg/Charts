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

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

open class BarChartDataSet: BarLineScatterCandleBubbleChartDataSet, BarChartDataSetProtocol
{
    @objc
    public enum BarGradientOrientation: Int
    {
        case vertical
        case horizontal
    }
    
    private func initialize()
    {
        self.highlightColor = NSUIColor.black
        
        self.calcStackSize(entries: entries as! [BarChartDataEntry])
        self.calcEntryCountIncludingStacks(entries: entries as! [BarChartDataEntry])
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(entries: [ChartDataEntry], label: String)
    {
        super.init(entries: entries, label: label)
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
    private func calcEntryCountIncludingStacks(entries: [BarChartDataEntry])
    {
        _entryCountStacks = entries.lazy
            .map(\.stackSize)
            .reduce(into: 0, +=)
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(entries: [BarChartDataEntry])
    {
        _stackSize = entries.lazy
            .map(\.stackSize)
            .max() ?? 1
    }
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? BarChartDataEntry,
            !e.y.isNaN
            else { return }
        
        if e.yValues == nil
        {
            _yMin = Swift.min(e.y, _yMin)
            _yMax = Swift.max(e.y, _yMax)
        }
        else
        {
            _yMin = Swift.min(-e.negativeSum, _yMin)
            _yMax = Swift.max(e.positiveSum, _yMax)
        }

        calcMinMaxX(entry: e)
    }
    
    /// The maximum number of bars that can be stacked upon another in this DataSet.
    open var stackSize: Int
    {
        return _stackSize
    }
    
    /// `true` if this DataSet is stacked (stacksize > 1) or not.
    open var isStacked: Bool
    {
        return _stackSize > 1
    }
    
    /// The overall entry count, including counting each stack-value individually
    @objc open var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    /// array of labels used to describe the different values of the stacked bars
    open var stackLabels: [String] = []
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    open var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    open var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    open var barBorderColor = NSUIColor.black

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    open var highlightAlpha = CGFloat(120.0 / 255.0)
    
    /// array of gradient colors [[color1, color2], [color3, color4]]
    open var barGradientColors: [[NSUIColor]]?
    
    open var barGradientOrientation: BarChartDataSet.BarGradientOrientation = .vertical
    
    /// - returns: The gradient colors at the given index of the DataSet's gradient color array.
    /// This prevents out-of-bounds by performing a modulus on the gradient color index, so colours will repeat themselves.
    open func barGradientColor(atIndex index: Int) -> [NSUIColor]?
    {
        guard let gradientColors = barGradientColors
        else { return nil }
        
        var index = index
        if index < 0
        {
            index = 0
        }
        return gradientColors[index % gradientColors.count]
    }
    
    // MARK: - NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BarChartDataSet
        copy._stackSize = _stackSize
        copy._entryCountStacks = _entryCountStacks
        copy.stackLabels = stackLabels

        copy.barShadowColor = barShadowColor
        copy.barBorderWidth = barBorderWidth
        copy.barBorderColor = barBorderColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}
