//
//  ChartData.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class ChartData: NSObject
{
    internal var _yMax: Double = -DBL_MAX
    internal var _yMin: Double = DBL_MAX
    internal var _xMax: Double = -DBL_MAX
    internal var _xMin: Double = DBL_MAX
    internal var _leftAxisMax: Double = -DBL_MAX
    internal var _leftAxisMin: Double = DBL_MAX
    internal var _rightAxisMax: Double = -DBL_MAX
    internal var _rightAxisMin: Double = DBL_MAX
    
    internal var _dataSets = [IChartDataSet]()
    
    public override init()
    {
        super.init()
        
        _dataSets = [IChartDataSet]()
    }
    
    public init(dataSets: [IChartDataSet]?)
    {
        super.init()
        
        _dataSets = dataSets ?? [IChartDataSet]()
        
        self.initialize(_dataSets)
    }
    
    public convenience init(dataSet: IChartDataSet?)
    {
        self.init(dataSets: dataSet === nil ? nil : [dataSet!])
    }
    
    internal func initialize(dataSets: [IChartDataSet])
    {
        calcMinMax()
    }
    
    /// Call this method to let the ChartData know that the underlying data has changed.
    /// Calling this performs all necessary recalculations needed when the contained data has changed.
    public func notifyDataChanged()
    {
        initialize(_dataSets)
    }
    
    /// calc minimum and maximum y value over all datasets
    public func calcMinMax()
    {
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        _xMax = -DBL_MAX
        _xMin = DBL_MAX
        
        for set in _dataSets
        {
            calcMinMax(dataSet: set)
        }
        
        _leftAxisMax = -DBL_MAX
        _leftAxisMin = DBL_MAX
        _rightAxisMax = -DBL_MAX
        _rightAxisMin = DBL_MAX
        
        // left axis
        let firstLeft = getFirstLeft()
        
        if firstLeft !== nil
        {
            _leftAxisMax = firstLeft!.yMax
            _leftAxisMin = firstLeft!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .Left
                {
                    if dataSet.yMin < _leftAxisMin
                    {
                        _leftAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _leftAxisMax
                    {
                        _leftAxisMax = dataSet.yMax
                    }
                }
            }
        }
        
        // right axis
        let firstRight = getFirstRight()
        
        if firstRight !== nil
        {
            _rightAxisMax = firstRight!.yMax
            _rightAxisMin = firstRight!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .Right
                {
                    if dataSet.yMin < _rightAxisMin
                    {
                        _rightAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _rightAxisMax
                    {
                        _rightAxisMax = dataSet.yMax
                    }
                }
            }
        }
    }
    
    public func calcMinMax(entry e: ChartDataEntry, axis: ChartYAxis.AxisDependency)
    {
        if _yMax < e.y
        {
            _yMax = e.y
        }
        
        if _yMin > e.y
        {
            _yMin = e.y
        }
        
        if _xMax < e.x
        {
            _xMax = e.x
        }
        
        if _xMin > e.x
        {
            _xMin = e.x
        }
        
        if axis == .Left
        {
            if _leftAxisMax < e.y
            {
                _leftAxisMax = e.y
            }
            
            if _leftAxisMin > e.y
            {
                _leftAxisMin = e.y
            }
        }
        else
        {
            if _rightAxisMax < e.y
            {
                _rightAxisMax = e.y
            }
            
            if _rightAxisMin > e.y
            {
                _rightAxisMin = e.y
            }
        }
    }
    
    public func calcMinMax(dataSet d: IChartDataSet)
    {
        if _yMax < d.yMax
        {
            _yMax = d.yMax
        }
        
        if _yMin > d.yMin
        {
            _yMin = d.yMin
        }
        
        if _xMax < d.xMax
        {
            _xMax = d.xMax
        }
        
        if _xMin > d.xMin
        {
            _xMin = d.xMin
        }
        
        if d.axisDependency == .Left
        {
            if _leftAxisMax < d.yMax
            {
                _leftAxisMax = d.yMax
            }
            
            if _leftAxisMin > d.yMin
            {
                _leftAxisMin = d.yMin
            }
        }
        else
        {
            if _rightAxisMax < d.yMax
            {
                _rightAxisMax = d.yMax
            }
            
            if _rightAxisMin > d.yMin
            {
                _rightAxisMin = d.yMin
            }
        }
    }
    
    /// - returns: the number of LineDataSets this object contains
    public var dataSetCount: Int
    {
        return _dataSets.count
    }
    
    /// - returns: the smallest y-value the data object contains.
    public var yMin: Double
    {
        return _yMin
    }
    
    @nonobjc
    public func getYMin() -> Double
    {
        return _yMin
    }
    
    public func getYMin(axis: ChartYAxis.AxisDependency) -> Double
    {
        if axis == .Left
        {
            if _leftAxisMin == DBL_MAX
            {
                return _rightAxisMin
            }
            else
            {
                return _leftAxisMin
            }
        }
        else
        {
            if _rightAxisMin == DBL_MAX
            {
                return _leftAxisMin
            }
            else
            {
                return _rightAxisMin
            }
        }
    }
    
    /// - returns: the greatest y-value the data object contains.
    public var yMax: Double
    {
        return _yMax
    }
    
    @nonobjc
    public func getYMax() -> Double
    {
        return _yMax
    }
    
    public func getYMax(axis: ChartYAxis.AxisDependency) -> Double
    {
        if axis == .Left
        {
            if _leftAxisMax == -DBL_MAX
            {
                return _rightAxisMax
            }
            else
            {
                return _leftAxisMax
            }
        }
        else
        {
            if _rightAxisMax == -DBL_MAX
            {
                return _leftAxisMax
            }
            else
            {
                return _rightAxisMax
            }
        }
    }
    
    /// - returns: the minimum x-value the data object contains.
    public var xMin: Double
    {
        return _xMin
    }
    /// - returns: the maximum x-value the data object contains.
    public var xMax: Double
    {
        return _xMax
    }
    
    /// - returns: all DataSet objects this ChartData object holds.
    public var dataSets: [IChartDataSet]
    {
        get
        {
            return _dataSets
        }
        set
        {
            _dataSets = newValue
            initialize(_dataSets)
        }
    }
    
    /// Retrieve the index of a ChartDataSet with a specific label from the ChartData. Search can be case sensitive or not.
    /// 
    /// **IMPORTANT: This method does calculations at runtime, do not over-use in performance critical situations.**
    ///
    /// - parameter dataSets: the DataSet array to search
    /// - parameter type:
    /// - parameter ignorecase: if true, the search is not case-sensitive
    /// - returns: the index of the DataSet Object with the given label. Sensitive or not.
    internal func getDataSetIndexByLabel(label: String, ignorecase: Bool) -> Int
    {
        if (ignorecase)
        {
            for i in 0 ..< dataSets.count
            {
                if (dataSets[i].label == nil)
                {
                    continue
                }
                if (label.caseInsensitiveCompare(dataSets[i].label!) == NSComparisonResult.OrderedSame)
                {
                    return i
                }
            }
        }
        else
        {
            for i in 0 ..< dataSets.count
            {
                if (label == dataSets[i].label)
                {
                    return i
                }
            }
        }
        
        return -1
    }
    
    /// - returns: the labels of all DataSets as a string array.
    internal func dataSetLabels() -> [String]
    {
        var types = [String]()
        
        for i in 0 ..< _dataSets.count
        {
            if (dataSets[i].label == nil)
            {
                continue
            }
            
            types[i] = _dataSets[i].label!
        }
        
        return types
    }
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: the entry that is highlighted
    public func entryForHighlight(highlight: ChartHighlight) -> ChartDataEntry?
    {
        if highlight.dataSetIndex >= dataSets.count
        {
            return nil
        }
        else
        {
            return dataSets[highlight.dataSetIndex].entryForXPos(highlight.x)
        }
    }
    
    /// **IMPORTANT: This method does calculations at runtime. Use with care in performance critical situations.**
    ///
    /// - parameter label:
    /// - parameter ignorecase:
    /// - returns: the DataSet Object with the given label. Sensitive or not.
    public func getDataSetByLabel(label: String, ignorecase: Bool) -> IChartDataSet?
    {
        let index = getDataSetIndexByLabel(label, ignorecase: ignorecase)
        
        if (index < 0 || index >= _dataSets.count)
        {
            return nil
        }
        else
        {
            return _dataSets[index]
        }
    }
    
    public func getDataSetByIndex(index: Int) -> IChartDataSet!
    {
        if index < 0 || index >= _dataSets.count
        {
            return nil
        }
        
        return _dataSets[index]
    }
    
    public func addDataSet(d: IChartDataSet!)
    {
        calcMinMax(dataSet: d)
        
        _dataSets.append(d)
    }
    
    /// Removes the given DataSet from this data object.
    /// Also recalculates all minimum and maximum values.
    ///
    /// - returns: true if a DataSet was removed, false if no DataSet could be removed.
    public func removeDataSet(dataSet: IChartDataSet!) -> Bool
    {
        if dataSet === nil
        {
            return false
        }
        
        for i in 0 ..< _dataSets.count
        {
            if (_dataSets[i] === dataSet)
            {
                return removeDataSetByIndex(i)
            }
        }
        
        return false
    }
    
    /// Removes the DataSet at the given index in the DataSet array from the data object. 
    /// Also recalculates all minimum and maximum values. 
    ///
    /// - returns: true if a DataSet was removed, false if no DataSet could be removed.
    public func removeDataSetByIndex(index: Int) -> Bool
    {
        if index >= _dataSets.count || index < 0
        {
            return false
        }
        
        _dataSets.removeAtIndex(index)
        
        calcMinMax()
        
        return true
    }
    
    /// Adds an Entry to the DataSet at the specified index. Entries are added to the end of the list.
    public func addEntry(e: ChartDataEntry, dataSetIndex: Int)
    {
        if _dataSets.count > dataSetIndex && dataSetIndex >= 0
        {
            let set = _dataSets[dataSetIndex]
            
            if !set.addEntry(e) { return }
            
            calcMinMax(entry: e, axis: set.axisDependency)
        }
        else
        {
            print("ChartData.addEntry() - Cannot add Entry because dataSetIndex too high or too low.", terminator: "\n")
        }
    }
    
    /// Removes the given Entry object from the DataSet at the specified index.
    public func removeEntry(entry: ChartDataEntry, dataSetIndex: Int) -> Bool
    {
        // entry outofbounds
        if dataSetIndex >= _dataSets.count
        {
            return false
        }
        
        // remove the entry from the dataset
        let removed = _dataSets[dataSetIndex].removeEntry(entry)
        
        if (removed)
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Removes the Entry object closest to the given xIndex from the ChartDataSet at the
    /// specified index. 
    /// - returns: true if an entry was removed, false if no Entry was found that meets the specified requirements.
    public func removeEntry(xValue xValue: Double, dataSetIndex: Int) -> Bool
    {
        if dataSetIndex >= _dataSets.count
        {
            return false
        }
        
        if let entry = _dataSets[dataSetIndex].entryForXPos(xValue)
        {
            return removeEntry(entry, dataSetIndex: dataSetIndex)
        }
        
        return false
    }
    
    /// - returns: the DataSet that contains the provided Entry, or null, if no DataSet contains this entry.
    public func getDataSetForEntry(e: ChartDataEntry!) -> IChartDataSet?
    {
        if (e == nil)
        {
            return nil
        }
        
        for i in 0 ..< _dataSets.count
        {
            let set = _dataSets[i]
            
            if (e === set.entryForXPos(e.x))
            {
                return set
            }
        }
        
        return nil
    }

    /// - returns: the index of the provided DataSet in the DataSet array of this data object, or -1 if it does not exist.
    public func indexOfDataSet(dataSet: IChartDataSet) -> Int
    {
        for i in 0 ..< _dataSets.count
        {
            if (_dataSets[i] === dataSet)
            {
                return i
            }
        }
        
        return -1
    }
    
    /// - returns: the first DataSet from the datasets-array that has it's dependency on the left axis. Returns null if no DataSet with left dependency could be found.
    public func getFirstLeft() -> IChartDataSet?
    {
        for dataSet in _dataSets
        {
            if (dataSet.axisDependency == .Left)
            {
                return dataSet
            }
        }
        
        return nil
    }
    
    /// - returns: the first DataSet from the datasets-array that has it's dependency on the right axis. Returns null if no DataSet with right dependency could be found.
    public func getFirstRight() -> IChartDataSet?
    {
        for dataSet in _dataSets
        {
            if (dataSet.axisDependency == .Right)
            {
                return dataSet
            }
        }
        
        return nil
    }
    
    /// - returns: all colors used across all DataSet objects this object represents.
    public func getColors() -> [NSUIColor]?
    {
        var clrcnt = 0
        
        for i in 0 ..< _dataSets.count
        {
            clrcnt += _dataSets[i].colors.count
        }
        
        var colors = [NSUIColor]()
        
        for i in 0 ..< _dataSets.count
        {
            let clrs = _dataSets[i].colors
            
            for clr in clrs
            {
                colors.append(clr)
            }
        }
        
        return colors
    }
    
    /// Sets a custom ValueFormatter for all DataSets this data object contains.
    public func setValueFormatter(formatter: NSNumberFormatter!)
    {
        for set in dataSets
        {
            set.valueFormatter = formatter
        }
    }
    
    /// Sets the color of the value-text (color in which the value-labels are drawn) for all DataSets this data object contains.
    public func setValueTextColor(color: NSUIColor!)
    {
        for set in dataSets
        {
            set.valueTextColor = color ?? set.valueTextColor
        }
    }
    
    /// Sets the font for all value-labels for all DataSets this data object contains.
    public func setValueFont(font: NSUIFont!)
    {
        for set in dataSets
        {
            set.valueFont = font ?? set.valueFont
        }
    }
    
    /// Enables / disables drawing values (value-text) for all DataSets this data object contains.
    public func setDrawValues(enabled: Bool)
    {
        for set in dataSets
        {
            set.drawValuesEnabled = enabled
        }
    }
    
    /// Enables / disables highlighting values for all DataSets this data object contains.
    /// If set to true, this means that values can be highlighted programmatically or by touch gesture.
    public var highlightEnabled: Bool
    {
        get
        {
            for set in dataSets
            {
                if (!set.highlightEnabled)
                {
                    return false
                }
            }
            
            return true
        }
        set
        {
            for set in dataSets
            {
                set.highlightEnabled = newValue
            }
        }
    }
    
    /// if true, value highlightning is enabled
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// Clears this data object from all DataSets and removes all Entries.
    /// Don't forget to invalidate the chart after this.
    public func clearValues()
    {
        dataSets.removeAll(keepCapacity: false)
        notifyDataChanged()
    }
    
    /// Checks if this data object contains the specified DataSet. 
    /// - returns: true if so, false if not.
    public func contains(dataSet dataSet: IChartDataSet) -> Bool
    {
        for set in dataSets
        {
            if set === dataSet
            {
                return true
            }
        }
        
        return false
    }
    
    /// - returns: The total entry count across all DataSet objects this data object contains.
    public var entryCount: Int
    {
        var count = 0
        
        for set in _dataSets
        {
            count += set.entryCount
        }
        
        return count
    }

    /// - returns: the DataSet object with the maximum number of entries or null if there are no DataSets.
    public var maxEntryCountSet: IChartDataSet?
    {
        if _dataSets.count == 0
        {
            return nil
        }
        
        var max = _dataSets[0]
        
        for set in _dataSets
        {
            if set.entryCount > max.entryCount
            {
                max = set
            }
        }
        
        return max
    }
}
