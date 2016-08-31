//
//  BaseDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 16/1/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class ChartBaseDataSet: NSObject, IChartDataSet
{
    public required override init()
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.black)
    }
    
    public init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.black)
        
        self.label = label
    }
    
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    open func notifyDataSetChanged()
    {
        calcMinMax(start: 0, end: entryCount - 1)
    }
    
    open func calcMinMax(start: Int, end: Int)
    {
        fatalError("calcMinMax is not implemented in ChartBaseDataSet")
    }
    
    open var yMin: Double
    {
        fatalError("yMin is not implemented in ChartBaseDataSet")
    }
    
    open var yMax: Double
    {
        fatalError("yMax is not implemented in ChartBaseDataSet")
    }
    
    open var entryCount: Int
    {
        fatalError("entryCount is not implemented in ChartBaseDataSet")
    }
    
    open func yValForXIndex(_ x: Int) -> Double
    {
        fatalError("yValForXIndex is not implemented in ChartBaseDataSet")
    }
    
    open func yValsForXIndex(_ x: Int) -> [Double]
    {
        fatalError("yValsForXIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        fatalError("entryForIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXIndex(_ x: Int, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        fatalError("entryForXIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXIndex(_ x: Int) -> ChartDataEntry?
    {
        fatalError("entryForXIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entriesForXIndex(_ x: Int) -> [ChartDataEntry]
    {
        fatalError("entriesForXIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(xIndex x: Int, rounding: ChartDataSetRounding) -> Int
    {
        fatalError("entryIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(entry e: ChartDataEntry) -> Int
    {
        fatalError("entryIndex is not implemented in ChartBaseDataSet")
    }
    
    open func addEntry(_ e: ChartDataEntry) -> Bool
    {
        fatalError("addEntry is not implemented in ChartBaseDataSet")
    }
    
    open func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        fatalError("addEntryOrdered is not implemented in ChartBaseDataSet")
    }
    
    open func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    open func removeEntry(xIndex: Int) -> Bool
    {
        if let entry = entryForXIndex(xIndex)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    open func removeFirst() -> Bool
    {
        if let entry = entryForIndex(0)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    open func removeLast() -> Bool
    {
        if let entry = entryForIndex(entryCount - 1)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    open func contains(_ e: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    open func clear()
    {
        fatalError("clear is not implemented in ChartBaseDataSet")
    }
    
    // MARK: - Styling functions and accessors
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    open var colors = [NSUIColor]()
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    open var valueColors = [NSUIColor]()

    /// The label string that describes the DataSet.
    open var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    open var axisDependency = ChartYAxis.AxisDependency.left
    
    /// - returns: the color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    open func colorAt(_ index: Int) -> NSUIColor
    {
        var index = index
        if (index < 0)
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    /// Resets all colors of this DataSet and recreates the colors array.
    open func resetColors()
    {
        colors.removeAll(keepingCapacity: false)
    }
    
    /// Adds a new color to the colors array of the DataSet.
    /// - parameter color: the color to add
    open func addColor(_ color: NSUIColor)
    {
        colors.append(color)
    }
    
    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    open func setColor(_ color: NSUIColor)
    {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }
    
    /// Sets colors to a single color a specific alpha value.
    /// - parameter color: the color to set
    /// - parameter alpha: alpha to apply to the set `color`
    open func setColor(_ color: NSUIColor, alpha: CGFloat)
    {
        setColor(color.withAlphaComponent(alpha))
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    open func setColors(_ colors: [NSUIColor], alpha: CGFloat)
    {
        var colorsWithAlpha = colors
        
        for i in 0 ..< colorsWithAlpha.count
        {
            colorsWithAlpha[i] = colorsWithAlpha[i] .withAlphaComponent(alpha)
        }
        
        self.colors = colorsWithAlpha
    }
    
    /// if true, value highlighting is enabled
    open var highlightEnabled = true
    
    
    /// the formatter used to customly format the values
    internal var _valueFormatter: NumberFormatter? = ChartUtils.defaultValueFormatter()
    
    /// The formatter used to customly format the values
    open var valueFormatter: NumberFormatter?
    {
        get
        {
            return _valueFormatter
        }
        set
        {
            if newValue == nil
            {
                _valueFormatter = ChartUtils.defaultValueFormatter()
            }
            else
            {
                _valueFormatter = newValue
            }
        }
    }
    
    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    open var valueTextColor: NSUIColor
    {
        get
        {
            return valueColors[0]
        }
        set
        {
            valueColors.removeAll(keepingCapacity: false)
            valueColors.append(newValue)
        }
    }
    
    /// - returns: the color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    open func valueTextColorAt(_ index: Int) -> NSUIColor
    {
        var index = index
        if (index < 0)
        {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }
    
    /// the font for the value-text labels
    open var valueFont: NSUIFont = NSUIFont.systemFont(ofSize: 7.0)
    
    /// Set this to true to draw y-values on the chart
    open var drawValuesEnabled = true
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    open var visible = true
    
    // MARK: - NSObject
    
    open override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(type(of: self)), self.label ?? "", self.entryCount])
    }
    
    open override var debugDescription: String
    {
        var desc = description + ":"
        
        for i in 0 ..< self.entryCount
        {
            desc += "\n" + (self.entryForIndex(i)?.description ?? "")
        }
        
        return desc
    }
    
    // MARK: - NSCopying
    
    open func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = type(of: self).init()
        
        copy.colors = colors
        copy.valueColors = valueColors
        copy.label = label
        
        return copy
    }
}


