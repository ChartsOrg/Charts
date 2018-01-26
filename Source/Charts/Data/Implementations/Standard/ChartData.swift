//
//  ChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartData: NSObject, ExpressibleByArrayLiteral
{
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    internal var _leftAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _leftAxisMin: Double = Double.greatestFiniteMagnitude
    internal var _rightAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _rightAxisMin: Double = Double.greatestFiniteMagnitude
    
    internal var _dataSets = [ChartDataSetProtocol]()
    
    public override required init()
    {
        super.init()
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...)
    {
        super.init()

        _dataSets = elements

        self.initialize(dataSets: _dataSets)
    }

    @objc public init(dataSets: [ChartDataSetProtocol]?)
    {
        super.init()
        
        _dataSets = dataSets ?? [ChartDataSetProtocol]()
        
        self.initialize(dataSets: _dataSets)
    }
    
    @objc public convenience init(dataSet: ChartDataSetProtocol?)
    {
        self.init(dataSets: dataSet === nil ? nil : [dataSet!])
    }
    
    internal func initialize(dataSets: [ChartDataSetProtocol])
    {
        notifyDataChanged()
    }
    
    /// Call this method to let the ChartData know that the underlying data has changed.
    /// Calling this performs all necessary recalculations needed when the contained data has changed.
    @objc open func notifyDataChanged()
    {
        calcMinMax()
    }
    
    @objc open func calcMinMaxY(fromX: Double, toX: Double)
    {
        forEach { $0.calcMinMaxY(fromX: fromX, toX: toX) }
        
        // apply the new data
        calcMinMax()
    }
    
    /// calc minimum and maximum y value over all datasets
    @objc open func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        forEach { calcMinMax(dataSet: $0) }
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        // left axis
        let firstLeft = getFirstLeft(dataSets: dataSets)
        
        if firstLeft !== nil
        {
            _leftAxisMax = firstLeft!.yMax
            _leftAxisMin = firstLeft!.yMin

            for dataSet in _dataSets where dataSet.axisDependency == .left
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
        
        // right axis
        let firstRight = getFirstRight(dataSets: dataSets)
        
        if firstRight !== nil
        {
            _rightAxisMax = firstRight!.yMax
            _rightAxisMin = firstRight!.yMin
            
            for dataSet in _dataSets where dataSet.axisDependency == .right
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
    
    /// Adjusts the current minimum and maximum values based on the provided Entry object.
    @objc open func calcMinMax(entry e: ChartDataEntry, axis: YAxis.AxisDependency)
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
        
        if axis == .left
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
    
    /// Adjusts the minimum and maximum values based on the given DataSet.
    @objc open func calcMinMax(dataSet d: ChartDataSetProtocol)
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
        
        if d.axisDependency == .left
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
    
    /// - returns: The number of LineDataSets this object contains
    @objc open var dataSetCount: Int
    {
        return _dataSets.count
    }
    
    /// - returns: The smallest y-value the data object contains.
    @objc open var yMin: Double
    {
        return _yMin
    }
    
    @nonobjc
    open func getYMin() -> Double
    {
        return _yMin
    }
    
    @objc open func getYMin(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if _leftAxisMin == Double.greatestFiniteMagnitude
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
            if _rightAxisMin == Double.greatestFiniteMagnitude
            {
                return _leftAxisMin
            }
            else
            {
                return _rightAxisMin
            }
        }
    }
    
    /// - returns: The greatest y-value the data object contains.
    @objc open var yMax: Double
    {
        return _yMax
    }
    
    @nonobjc
    open func getYMax() -> Double
    {
        return _yMax
    }
    
    @objc open func getYMax(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if _leftAxisMax == -Double.greatestFiniteMagnitude
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
            if _rightAxisMax == -Double.greatestFiniteMagnitude
            {
                return _leftAxisMax
            }
            else
            {
                return _rightAxisMax
            }
        }
    }
    
    /// - returns: The minimum x-value the data object contains.
    @objc open var xMin: Double
    {
        return _xMin
    }
    /// - returns: The maximum x-value the data object contains.
    @objc open var xMax: Double
    {
        return _xMax
    }
    
    /// - returns: All DataSet objects this ChartData object holds.
    @objc open var dataSets: [ChartDataSetProtocol]
    {
        get
        {
            return _dataSets
        }
        set
        {
            _dataSets = newValue
            notifyDataChanged()
        }
    }
    
    /// Retrieve the index of a ChartDataSet with a specific label from the ChartData. Search can be case sensitive or not.
    /// 
    /// **IMPORTANT: This method does calculations at runtime, do not over-use in performance critical situations.**
    ///
    /// - parameter dataSets: the DataSet array to search
    /// - parameter type:
    /// - parameter ignorecase: if true, the search is not case-sensitive
    /// - returns: The index of the DataSet Object with the given label. Sensitive or not.
    internal func getDataSetIndexByLabel(_ label: String, ignorecase: Bool) -> Int
    {
        return ignorecase
            ? index { $0.label?.caseInsensitiveCompare(label) == .orderedSame } ?? -1
            : index { $0.label == label } ?? -1
    }
    
    /// - returns: The labels of all DataSets as a string array.
    internal func dataSetLabels() -> [String]
    {
        return flatMap { $0.label }
    }
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    @objc open func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        guard indices.contains(highlight.dataSetIndex) else { return nil }
        return self[highlight.dataSetIndex].entryForXValue(highlight.x, closestToY: highlight.y)
    }
    
    /// **IMPORTANT: This method does calculations at runtime. Use with care in performance critical situations.**
    ///
    /// - parameter label:
    /// - parameter ignorecase:
    /// - returns: The DataSet Object with the given label. Sensitive or not.
    @objc open func getDataSetByLabel(_ label: String, ignorecase: Bool) -> Element?
    {
        guard let index = index(forLabel: label, ignoreCase: ignorecase) else { return nil }
        return self[index]
    }
    
    @objc open func getDataSetByIndex(_ index: Index) -> Element!
    {
        if index < 0 || index >= _dataSets.count
        {
            return nil
        }
        
        return self[index]
    }

    /// Removes the given DataSet from this data object.
    /// Also recalculates all minimum and maximum values.
    ///
    /// - returns: `true` if a DataSet was removed, `false` ifno DataSet could be removed.
    @objc @discardableResult open func removeDataSet(_ dataSet: Element!) -> Bool
    {
        guard
            dataSet != nil,
            let index = index(where: { $0 === dataSet })
            else { return false }

        _ = remove(at: index)
        return true
    }

    /// Adds an Entry to the DataSet at the specified index. Entries are added to the end of the list.
    @objc(addEntry:dataSetIndex:)
    open func appendEntry(_ e: ChartDataEntry, toDataSet dataSetIndex: Index)
    {
        guard indices.contains(dataSetIndex) else {
            return print("ChartData.addEntry() - Cannot add Entry because dataSetIndex too high or too low.", terminator: "\n")
        }
        
        let set = self[dataSetIndex]
        if !set.addEntry(e) { return }
        calcMinMax(entry: e, axis: set.axisDependency)
    }

    /// Removes the given Entry object from the DataSet at the specified index.
    @objc @discardableResult open func removeEntry(_ entry: ChartDataEntry, dataSetIndex: Int) -> Bool
    {
        guard indices.contains(dataSetIndex) else { return false }

        // remove the entry from the dataset
        let removed = self[dataSetIndex].removeEntry(entry)
        
        if removed
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Removes the Entry object closest to the given xIndex from the ChartDataSet at the
    /// specified index. 
    /// - returns: `true` if an entry was removed, `false` ifno Entry was found that meets the specified requirements.
    @objc @discardableResult open func removeEntry(xValue: Double, dataSetIndex: Int) -> Bool
    {
        guard
            indices.contains(dataSetIndex),
            let entry = self[dataSetIndex].entryForXValue(xValue, closestToY: .nan)
            else { return false }

        return removeEntry(entry, dataSetIndex: dataSetIndex)
    }
    
    /// - returns: The DataSet that contains the provided Entry, or null, if no DataSet contains this entry.
    @objc open func getDataSetForEntry(_ e: ChartDataEntry!) -> ChartDataSetProtocol?
    {
        guard e != nil else { return nil }

        return first { $0.entryForXValue(e.x, closestToY: e.y) === e }
    }

    /// - returns: The index of the provided DataSet in the DataSet array of this data object, or -1 if it does not exist.
    @objc open func indexOfDataSet(_ dataSet: ChartDataSetProtocol) -> Int
    {
        return index(where: { $0 === dataSet }) ?? -1
    }
    
    /// - returns: The first DataSet from the datasets-array that has it's dependency on the left axis. Returns null if no DataSet with left dependency could be found.
    @objc open func getFirstLeft(dataSets: [ChartDataSetProtocol]) -> ChartDataSetProtocol?
    {
        return first { $0.axisDependency == .left }
    }
    
    /// - returns: The first DataSet from the datasets-array that has it's dependency on the right axis. Returns null if no DataSet with right dependency could be found.
    @objc open func getFirstRight(dataSets: [ChartDataSetProtocol]) -> ChartDataSetProtocol?
    {
        return first { $0.axisDependency == .right }
    }
    
    /// - returns: All colors used across all DataSet objects this object represents.
    // TODO: This should return a non-optional array
    @objc open func getColors() -> [NSUIColor]?
    {
        return flatMap { $0.colors.map { $0 } }
    }
    
    /// Sets a custom ValueFormatter for all DataSets this data object contains.
    @objc open func setValueFormatter(_ formatter: ValueFormatter?)
    {
        guard let formatter = formatter
            else { return }

        forEach { $0.valueFormatter = formatter }
    }
    
    /// Sets the color of the value-text (color in which the value-labels are drawn) for all DataSets this data object contains.
    @objc open func setValueTextColor(_ color: NSUIColor!)
    {
        forEach { $0.valueTextColor = color ?? $0.valueTextColor }
    }
    
    /// Sets the font for all value-labels for all DataSets this data object contains.
    @objc open func setValueFont(_ font: NSUIFont!)
    {
        forEach { $0.valueFont = font ?? $0.valueFont }
    }
    
    /// Enables / disables drawing values (value-text) for all DataSets this data object contains.
    @objc open func setDrawValues(_ enabled: Bool)
    {
        forEach { $0.drawValuesEnabled = enabled }
    }
    
    /// Enables / disables highlighting values for all DataSets this data object contains.
    /// If set to true, this means that values can be highlighted programmatically or by touch gesture.
    @objc open var highlightEnabled: Bool
    {
        get
        {
            return first { $0.highlightEnabled == false } == nil
        }
        set
        {
            forEach { $0.highlightEnabled = newValue }
        }
    }
    
    /// if true, value highlightning is enabled
    @objc open var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// Clears this data object from all DataSets and removes all Entries.
    /// Don't forget to invalidate the chart after this.
    @objc open func clearValues()
    {
        dataSets.removeAll(keepingCapacity: false)
        notifyDataChanged()
    }
    
    /// Checks if this data object contains the specified DataSet. 
    /// - returns: `true` if so, `false` ifnot.
    @objc open func contains(dataSet: ChartDataSetProtocol) -> Bool
    {
        return contains { $0 === dataSet }
    }
    
    /// - returns: The total entry count across all DataSet objects this data object contains.
    @objc open var entryCount: Int
    {
        return reduce(0) { return $0 + $1.entryCount }
    }

    /// - returns: The DataSet object with the maximum number of entries or null if there are no DataSets.
    @objc open var maxEntryCountSet: ChartDataSetProtocol?
    {
        return self.max { $0.entryCount > $1.entryCount }
    }
}

// MARK: MutableCollection
extension ChartData: MutableCollection
{
    public typealias Index = Int
    public typealias Element = ChartDataSetProtocol

    public var startIndex: Index
    {
        return _dataSets.startIndex
    }

    public var endIndex: Index
    {
        return _dataSets.endIndex
    }

    public func index(after: Index) -> Index
    {
        return _dataSets.index(after: after)
    }

    public subscript(position: Index) -> Element
    {
        get{ return _dataSets[position] }
        set{ self._dataSets[position] = newValue }
    }
}

// MARK: RandomAccessCollection
extension ChartData: RandomAccessCollection
{
    public func index(before: Index) -> Index
    {
        return _dataSets.index(before: before)
    }
}

// MARK: RangeReplaceableCollection
extension ChartData: RangeReplaceableCollection
{
    @objc(addDataSet:)
    public func append(_ newElement: Element)
    {
        _dataSets.append(newElement)
        calcMinMax(dataSet: newElement)
    }

    @objc(removeDataSetByIndex:)
    public func remove(at position: Index) -> Element
    {
        let element = _dataSets.remove(at: position)
        calcMinMax()
        return element
    }

    public func removeFirst() -> Element
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeFirst() not supported for CombinedData")
        }

        let element = _dataSets.removeFirst()
        notifyDataChanged()
        return element
    }

    public func removeFirst(_ n: Int)
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeFirst(_:) not supported for CombinedData")
        }

        _dataSets.removeFirst(n)
        notifyDataChanged()
    }

    public func removeLast() -> Element
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeLast() not supported for CombinedData")
        }

        let element = _dataSets.removeLast()
        notifyDataChanged()
        return element
    }

    public func removeLast(_ n: Int)
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeLast(_:) not supported for CombinedData")
        }

        _dataSets.removeLast(n)
        notifyDataChanged()
    }

    public func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Index == R.Bound
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeSubrange<R>(_:) not supported for CombinedData")
        }

        _dataSets.removeSubrange(bounds)
        notifyDataChanged()
    }

    public func removeAll(keepingCapacity keepCapacity: Bool)
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("removeAll(keepingCapacity:) not supported for CombinedData")
        }

        _dataSets.removeAll(keepingCapacity: keepCapacity)
        notifyDataChanged()
    }

    public func replaceSubrange<C>(_ subrange: Swift.Range<Index>, with newElements: C) where C : Collection, Element == C.Element
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("replaceSubrange<C>(_:) not supported for CombinedData")
        }

        _dataSets.replaceSubrange(subrange, with: newElements)
        newElements.forEach { self.calcMinMax(dataSet: $0) }
    }
}

// MARK: Swift Accessors
extension ChartData
{
    /// Retrieve the index of a ChartDataSet with a specific label from the ChartData. Search can be case sensitive or not.
    /// **IMPORTANT: This method does calculations at runtime, do not over-use in performance critical situations.**
    ///
    /// - Parameters:
    ///   - label: The label to search for
    ///   - ignoreCase: if true, the search is not case-sensitive
    /// - Returns: The index of the DataSet Object with the given label. `nil` if not found
    public func index(forLabel label: String, ignoreCase: Bool) -> Index?
    {
        return ignoreCase
            ? index { $0.label?.caseInsensitiveCompare(label) == .orderedSame }
            : index { $0.label == label }
    }

    public subscript(label: String, ignoreCase: Bool) -> Element?
    {
        guard let index = index(forLabel: label, ignoreCase: ignoreCase) else { return nil }
        return self[index]
    }
    
    public subscript(entry: ChartDataEntry) -> Element?
    {
        guard let index = index(where: { $0.entryForXValue(entry.x, closestToY: entry.y) === entry }) else { return nil }
        return self[index]
    }
}
