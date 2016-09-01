//
//  BaseDataSet.swift
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


public class ChartBaseDataSet: NSObject, IChartDataSet
{
    public required override init()
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.blackColor())
    }
    
    public init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(NSUIColor.blackColor())
        
        self.label = label
    }
    
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged()
    {
        calcMinMax()
    }
    
    public func calcMinMax()
    {
        fatalError("calcMinMax is not implemented in ChartBaseDataSet")
    }
    
    public func calcMinMaxY(fromX fromX: Double, toX: Double)
    {
        fatalError("calcMinMaxY(fromX:, toX:) is not implemented in ChartBaseDataSet")
    }
    
    public var yMin: Double
    {
        fatalError("yMin is not implemented in ChartBaseDataSet")
    }
    
    public var yMax: Double
    {
        fatalError("yMax is not implemented in ChartBaseDataSet")
    }
    
    public var xMin: Double
    {
        fatalError("xMin is not implemented in ChartBaseDataSet")
    }
    
    public var xMax: Double
    {
        fatalError("xMax is not implemented in ChartBaseDataSet")
    }
    
    public var entryCount: Int
    {
        fatalError("entryCount is not implemented in ChartBaseDataSet")
    }
        
    public func entryForIndex(i: Int) -> ChartDataEntry?
    {
        fatalError("entryForIndex is not implemented in ChartBaseDataSet")
    }
    
    public func entryForXValue(x: Double, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        fatalError("entryForXValue(x, rounding) is not implemented in ChartBaseDataSet")
    }
    
    public func entryForXValue(x: Double) -> ChartDataEntry?
    {
        fatalError("entryForXValue(x) is not implemented in ChartBaseDataSet")
    }
    
    public func entriesForXValue(x: Double) -> [ChartDataEntry]
    {
        fatalError("entriesForXValue is not implemented in ChartBaseDataSet")
    }
    
    public func entryIndex(x x: Double, rounding: ChartDataSetRounding) -> Int
    {
        fatalError("entryIndex(x, rounding) is not implemented in ChartBaseDataSet")
    }
    
    public func entryIndex(entry e: ChartDataEntry) -> Int
    {
        fatalError("entryIndex(entry) is not implemented in ChartBaseDataSet")
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
    
    public func removeEntry(index index: Int) -> Bool
    {
        if let entry = entryForIndex(index)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    public func removeEntry(x x: Double) -> Bool
    {
        if let entry = entryForXValue(x)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    public func removeFirst() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(0)
            {
                return removeEntry(entry)
            }
        }
        return false
    }
    
    public func removeLast() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(entryCount - 1)
            {
                return removeEntry(entry)
            }
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
    public var colors = [NSUIColor]()
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    public var valueColors = [NSUIColor]()

    /// The label string that describes the DataSet.
    public var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    public var axisDependency = YAxis.AxisDependency.Left
    
    /// - returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    public func colorAt(index: Int) -> NSUIColor
    {
        var index = index
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
    public func addColor(color: NSUIColor)
    {
        colors.append(color)
    }
    
    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    public func setColor(color: NSUIColor)
    {
        colors.removeAll(keepCapacity: false)
        colors.append(color)
    }
    
    /// Sets colors to a single color a specific alpha value.
    /// - parameter color: the color to set
    /// - parameter alpha: alpha to apply to the set `color`
    public func setColor(color: NSUIColor, alpha: CGFloat)
    {
        setColor(color.colorWithAlphaComponent(alpha))
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    public func setColors(colors: [NSUIColor], alpha: CGFloat)
    {
        var colorsWithAlpha = colors
        
        for i in 0 ..< colorsWithAlpha.count
        {
            colorsWithAlpha[i] = colorsWithAlpha[i] .colorWithAlphaComponent(alpha)
        }
        
        self.colors = colorsWithAlpha
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    public func setColors(colors: NSUIColor...)
    {
        self.colors = colors
    }
    
    /// if true, value highlighting is enabled
    public var highlightEnabled = true
    
    /// - returns: `true` if value highlighting is enabled for this dataset
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// Custom formatter that is used instead of the auto-formatter if set
    internal var _valueFormatter: IValueFormatter?
    
    /// Custom formatter that is used instead of the auto-formatter if set
    public var valueFormatter: IValueFormatter?
    {
        get
        {
            if needsFormatter
            {
                return ChartUtils.defaultValueFormatter()
            }
            
            return _valueFormatter
        }
        set
        {
            if newValue == nil { return }
            
            _valueFormatter = newValue
        }
    }
    
    public var needsFormatter: Bool
    {
        return _valueFormatter == nil
    }
    
    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    public var valueTextColor: NSUIColor
    {
        get
        {
            return valueColors[0]
        }
        set
        {
            valueColors.removeAll(keepCapacity: false)
            valueColors.append(newValue)
        }
    }
    
    /// - returns: The color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    public func valueTextColorAt(index: Int) -> NSUIColor
    {
        var index = index
        if (index < 0)
        {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }
    
    /// the font for the value-text labels
    public var valueFont: NSUIFont = NSUIFont.systemFontOfSize(7.0)
    
    /// The form to draw for this dataset in the legend.
    public var form = Legend.Form.Default
    
    /// The form size to draw for this dataset in the legend.
    ///
    /// Return `NaN` to use the default legend form size.
    public var formSize: CGFloat = CGFloat.NaN
    
    /// The line width for drawing the form of this dataset in the legend
    ///
    /// Return `NaN` to use the default legend form line width.
    public var formLineWidth: CGFloat = CGFloat.NaN
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var formLineDashLengths: [CGFloat]? = nil
    
    /// Set this to true to draw y-values on the chart
    public var drawValuesEnabled = true
    
    /// - returns: `true` if y-value drawing is enabled, `false` ifnot
    public var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled
    }
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    public var visible = true
    
    /// - returns: `true` if this DataSet is visible inside the chart, or `false` ifit is currently hidden.
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
        
        for i in 0 ..< self.entryCount
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
        copy.valueColors = valueColors
        copy.label = label
        
        return copy
    }
}


