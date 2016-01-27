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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

public class ChartBaseDataSet: NSObject, IChartDataSet
{
    public required override init()
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }
    
    public init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
    }
    
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged()
    {
        calcMinMax(start: 0, end: entryCount - 1)
    }
    
    public func calcMinMax(start start: Int, end: Int)
    {
        fatalError("calcMinMax is not implemented in ChartBaseDataSet")
    }
    
    public var yMin: Double
    {
        fatalError("yMin is not implemented in ChartBaseDataSet")
    }
    
    public var yMax: Double
    {
        fatalError("yMax is not implemented in ChartBaseDataSet")
    }
    
    public var entryCount: Int
    {
        fatalError("entryCount is not implemented in ChartBaseDataSet")
    }
    
    public func yValForXIndex(x: Int) -> Double
    {
        fatalError("yValForXIndex is not implemented in ChartBaseDataSet")
    }
    
    public func entryForIndex(i: Int) -> ChartDataEntry?
    {
        fatalError("entryForIndex is not implemented in ChartBaseDataSet")
    }
    
    public func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        fatalError("entryForXIndex is not implemented in ChartBaseDataSet")
    }
    
    public func entryIndex(xIndex x: Int) -> Int
    {
        fatalError("entryIndex is not implemented in ChartBaseDataSet")
    }
    
    public func entryIndex(entry e: ChartDataEntry) -> Int
    {
        fatalError("entryIndex is not implemented in ChartBaseDataSet")
    }
    
    public func addEntry(e: ChartDataEntry) -> Bool
    {
        fatalError("addEntry is not implemented in ChartBaseDataSet")
    }
    
    public func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        fatalError("addEntryOrdered is not implemented in ChartBaseDataSet")
    }
    
    public func removeEntry(entry: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    public func removeEntry(xIndex xIndex: Int) -> Bool
    {
        if let entry = entryForXIndex(xIndex)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    public func removeFirst() -> Bool
    {
        if let entry = entryForIndex(0)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    public func removeLast() -> Bool
    {
        if let entry = entryForIndex(entryCount - 1)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    public func contains(e: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    public func clear()
    {
        fatalError("clear is not implemented in ChartBaseDataSet")
    }
    
    // MARK: - Styling functions and accessors
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array. 
    public var colors = [UIColor]()
    
    /// The label string that describes the DataSet.
    public var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    public var axisDependency = ChartYAxis.AxisDependency.Left
    
    /// - returns: the color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    public func colorAt(var index: Int) -> UIColor
    {
        if (index < 0)
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    /// Resets all colors of this DataSet and recreates the colors array.
    public func resetColors()
    {
        colors.removeAll(keepCapacity: false)
    }
    
    /// Adds a new color to the colors array of the DataSet.
    /// - parameter color: the color to add
    public func addColor(color: UIColor)
    {
        colors.append(color)
    }
    
    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    public func setColor(color: UIColor)
    {
        colors.removeAll(keepCapacity: false)
        colors.append(color)
    }
    
    /// Sets colors to a single color a specific alpha value.
    /// - parameter color: the color to set
    /// - parameter alpha: alpha to apply to the set `color`
    public func setColor(color: UIColor, alpha: CGFloat)
    {
        setColor(color.colorWithAlphaComponent(alpha))
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    public func setColors(colors: [UIColor], alpha: CGFloat)
    {
        var colorsWithAlpha = colors
        
        for i in 0 ..< colorsWithAlpha.count
        {
            colorsWithAlpha[i] = colorsWithAlpha[i] .colorWithAlphaComponent(alpha)
        }
        
        self.colors = colorsWithAlpha
    }
    
    /// if true, value highlighting is enabled
    public var highlightEnabled = true
    
    /// - returns: true if value highlighting is enabled for this dataset
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// the formatter used to customly format the values
    internal var _valueFormatter: NSNumberFormatter? = ChartUtils.defaultValueFormatter()
    
    /// The formatter used to customly format the values
    public var valueFormatter: NSNumberFormatter?
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
    
    /// the color used for the value-text
    public var valueTextColor: UIColor = UIColor.blackColor()
    
    /// the font for the value-text labels
    public var valueFont: UIFont = UIFont.systemFontOfSize(7.0)
    
    /// Set this to true to draw y-values on the chart
    public var drawValuesEnabled = true
    
    /// Returns true if y-value drawing is enabled, false if not
    public var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled
    }
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    public var visible = true
    
    /// Returns true if this DataSet is visible inside the chart, or false if it is currently hidden.
    public var isVisible: Bool
    {
        return visible
    }
    
    // MARK: - NSObject
    
    public override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(self.dynamicType), self.label ?? "", self.entryCount])
    }
    
    public override var debugDescription: String
    {
        var desc = description + ":"
        
        for (var i = 0, count = self.entryCount; i < count; i++)
        {
            desc += "\n" + (self.entryForIndex(i)?.description ?? "")
        }
        
        return desc
    }
    
    // MARK: - NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = self.dynamicType.init()
        
        copy.colors = colors
        copy.label = label
        
        return copy
    }
}


