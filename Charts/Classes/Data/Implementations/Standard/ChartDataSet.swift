//
//  ChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

public class ChartDataSet: NSObject, IChartDataSet
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
    
    public init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _yVals = yVals == nil ? [ChartDataEntry]() : yVals
        
        self.calcMinMax(start: _lastStart, end: _lastEnd)
    }
    
    public convenience init(yVals: [ChartDataEntry]?)
    {
        self.init(yVals: yVals, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors
    
    internal var _yVals: [ChartDataEntry]!
    internal var _yMax = Double(0.0)
    internal var _yMin = Double(0.0)
    
    /// the last start value used for calcMinMax
    internal var _lastStart: Int = 0
    
    /// the last end value used for calcMinMax
    internal var _lastEnd: Int = 0
    
    public var yVals: [ChartDataEntry] { return _yVals }
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
    }
    
    public func calcMinMax(start start: Int, end: Int)
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
        
        for (var i = start; i <= endValue; i++)
        {
            let e = _yVals[i]
            
            if (!e.value.isNaN)
            {
                if (e.value < _yMin)
                {
                    _yMin = e.value
                }
                if (e.value > _yMax)
                {
                    _yMax = e.value
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    /// - returns: the minimum y-value this DataSet holds
    public var yMin: Double { return _yMin }
    
    /// - returns: the maximum y-value this DataSet holds
    public var yMax: Double { return _yMax }
    
    /// - returns: the number of y-values this DataSet represents
    public var entryCount: Int { return _yVals?.count ?? 0 }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    public func yValForXIndex(x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.NaN }
    }
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public func entryForIndex(i: Int) -> ChartDataEntry?
    {
        return _yVals[i]
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    public func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x)
        if (index > -1)
        {
            return _yVals[index]
        }
        return nil
    }
    
    public func entriesForXIndex(x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _yVals.count - 1
        
        while (low <= high)
        {
            var m = Int((high + low) / 2)
            var entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--
                }
                
                high = _yVals.count
                for (; m < high; m++)
                {
                    entry = _yVals[m]
                    if (entry.xIndex == x)
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                }
            }
            
            if (x > _yVals[m].xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
        }
        
        return entries
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    public func entryIndex(xIndex x: Int) -> Int
    {
        var low = 0
        var high = _yVals.count - 1
        var closest = -1
        
        while (low <= high)
        {
            var m = (high + low) / 2
            let entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--
                }
                
                return m
            }
            
            if (x > entry.xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
            
            closest = m
        }
        
        return closest
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    public func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for (var i = 0; i < _yVals.count; i++)
        {
            if (_yVals[i] === e || _yVals[i].isEqual(e))
            {
                return i
            }
        }
        
        return -1
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public func addEntry(e: ChartDataEntry) -> Bool
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yVals.append(e)
        
        return true
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        if _yVals.last?.xIndex > e.xIndex
        {
            var closestIndex = entryIndex(xIndex: e.xIndex)
            if _yVals[closestIndex].xIndex < e.xIndex
            {
                closestIndex++
            }
            _yVals.insert(e, atIndex: closestIndex)
            return true
        }
        
        _yVals.append(e)
        
        return true
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public func removeEntry(entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for (var i = 0; i < _yVals.count; i++)
        {
            if (_yVals[i] === entry)
            {
                _yVals.removeAtIndex(i)
                removed = true
                break
            }
        }
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter xIndex: the xIndex of the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public func removeEntry(xIndex xIndex: Int) -> Bool
    {
        let index = self.entryIndex(xIndex: xIndex)
        if (index > -1)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
            
            return true
        }
        
        return false
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public func removeFirst() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeFirst()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public func removeLast() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeLast()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    public func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _yVals
        {
            if (entry.isEqual(e))
            {
                return true
            }
        }
        
        return false
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    public func clear()
    {
        _yVals.removeAll(keepCapacity: true)
        _lastStart = 0
        _lastEnd = 0
        notifyDataSetChanged()
    }
    
    // MARK: - Styling functions and accessors
    
    /// The label string that describes the DataSet.
    public var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    public var axisDependency = ChartYAxis.AxisDependency.Left
    
    /// All the colors that are set for this DataSet
    public var colors = [UIColor]()
    
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
    
    public func resetColors()
    {
        colors.removeAll(keepCapacity: false)
    }
    
    public func addColor(color: UIColor)
    {
        colors.append(color)
    }
    
    public func setColor(color: UIColor)
    {
        colors.removeAll(keepCapacity: false)
        colors.append(color)
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
    
    /// - returns: the number of entries this DataSet holds.
    public var valueCount: Int { return _yVals.count }
    
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
        copy._yVals = _yVals
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd
        copy.label = label

        return copy
    }
}


