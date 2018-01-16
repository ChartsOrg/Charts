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

    @objc public internal(set) var xMax = -Double.greatestFiniteMagnitude
    @objc public internal(set) var xMin = Double.greatestFiniteMagnitude
    @objc public internal(set) var yMax = -Double.greatestFiniteMagnitude
    @objc public internal(set) var yMin = Double.greatestFiniteMagnitude
    var leftAxisMax = -Double.greatestFiniteMagnitude
    var leftAxisMin = Double.greatestFiniteMagnitude
    var rightAxisMax = -Double.greatestFiniteMagnitude
    var rightAxisMin = Double.greatestFiniteMagnitude
    
    var _dataSets = [Element]()
    
    public override required init()
    {
        super.init()
    }

    public required init(arrayLiteral elements: Element...)
    {
        super.init()
        self.dataSets = elements
    }

    @objc public init(dataSets: [Element])
    {
        super.init()
        self.dataSets = dataSets
    }
    
    @objc public convenience init(dataSet: Element)
    {
        self.init(dataSets: [dataSet])
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
        leftAxisMax = -.greatestFiniteMagnitude
        leftAxisMin = .greatestFiniteMagnitude
        rightAxisMax = -.greatestFiniteMagnitude
        rightAxisMin = .greatestFiniteMagnitude
        xMax = -.greatestFiniteMagnitude
        xMin = .greatestFiniteMagnitude
        
        forEach { calcMinMax(dataSet: $0) }
    }
    
    /// Adjusts the current minimum and maximum values based on the provided Entry object.
    @objc open func calcMinMax(entry e: ChartDataEntry, axis: YAxis.AxisDependency)
    {
        xMax = Swift.max(xMax, e.x)
        xMin = Swift.min(xMin, e.x)
        yMax = Swift.max(yMax, e.y)
        yMin = Swift.min(yMin, e.y)

        switch axis
        {
        case .left:
            leftAxisMax = Swift.max(leftAxisMax, e.y)
            leftAxisMin = Swift.min(leftAxisMin, e.y)

        case .right:
            rightAxisMax = Swift.max(rightAxisMax, e.y)
            rightAxisMin = Swift.min(rightAxisMin, e.y)
        }
    }
    
    /// Adjusts the minimum and maximum values based on the given DataSet.
    @objc open func calcMinMax(dataSet d: Element)
    {
        xMax = Swift.max(xMax, d.xMax)
        xMin = Swift.min(xMin, d.xMin)
        yMax = Swift.max(yMax, d.yMax)
        yMin = Swift.min(yMin, d.yMin)

        switch d.axisDependency
        {
        case .left:
            leftAxisMax = Swift.max(leftAxisMax, d.yMax)
            leftAxisMin = Swift.min(leftAxisMin, d.yMin)

        case .right:
            rightAxisMax = Swift.max(rightAxisMax, d.yMax)
            rightAxisMin = Swift.min(rightAxisMin, d.yMin)
        }
    }
    
    /// - returns: The number of LineDataSets this object contains
    // exists only for objc compatibility
    @objc open var dataSetCount: Int
    {
        return dataSets.count
    }

    @objc open func getYMin(axis: YAxis.AxisDependency) -> Double
    {
        // TODO: Why does it make sense to return the other axisMin if there is none for the one requested?
        switch axis
        {
        case .left:
            if leftAxisMin == .greatestFiniteMagnitude
            {
                return rightAxisMin
            }
            else
            {
                return leftAxisMin
            }

        case .right:
            if rightAxisMin == .greatestFiniteMagnitude
            {
                return leftAxisMin
            }
            else
            {
                return rightAxisMin
            }
        }
    }
        
    @objc open func getYMax(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if leftAxisMax == -.greatestFiniteMagnitude
            {
                return rightAxisMax
            }
            else
            {
                return leftAxisMax
            }
        }
        else
        {
            if rightAxisMax == -.greatestFiniteMagnitude
            {
                return leftAxisMax
            }
            else
            {
                return rightAxisMax
            }
        }
    }
        
    /// - returns: All DataSet objects this ChartData object holds.
    @objc open var dataSets: [Element]
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

    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    @objc open func entry(for highlight: Highlight) -> ChartDataEntry?
    {
        guard indices.contains(highlight.dataSetIndex) else { return nil }
        return self[highlight.dataSetIndex].entryForXValue(highlight.x, closestToY: highlight.y)
    }
    
    /// **IMPORTANT: This method does calculations at runtime. Use with care in performance critical situations.**
    ///
    /// - parameter label:
    /// - parameter ignorecase:
    /// - returns: The DataSet Object with the given label. Sensitive or not.
    @objc open func dataSet(forLabel label: String, ignorecase: Bool) -> Element?
    {
        guard let index = index(forLabel: label, ignoreCase: ignorecase) else { return nil }
        return self[index]
    }
    
    @objc open func dataSet(forIndex index: Index) -> Element?
    {
        guard dataSets.indices.contains(index) else { return nil }
        return self[index]
    }

    /// Removes the given DataSet from this data object.
    /// Also recalculates all minimum and maximum values.
    ///
    /// - returns: `true` if a DataSet was removed, `false` ifno DataSet could be removed.
    @objc @discardableResult open func removeDataSet(_ dataSet: Element) -> Element?
    {
        guard let index = index(where: { $0 === dataSet }) else { return nil }
        return remove(at: index)
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
    @objc @discardableResult open func removeEntry(_ entry: ChartDataEntry, dataSetIndex: Index) -> Bool
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
    @objc @discardableResult open func removeEntry(xValue: Double, dataSetIndex: Index) -> Bool
    {
        guard
            indices.contains(dataSetIndex),
            let entry = self[dataSetIndex].entryForXValue(xValue, closestToY: .nan)
            else { return false }

        return removeEntry(entry, dataSetIndex: dataSetIndex)
    }
    
    /// - returns: The DataSet that contains the provided Entry, or null, if no DataSet contains this entry.
    @objc open func getDataSetForEntry(_ e: ChartDataEntry) -> Element?
    {
        return first { $0.entryForXValue(e.x, closestToY: e.y) === e }
    }

    /// - returns: The index of the provided DataSet in the DataSet array of this data object, or -1 if it does not exist.
    @objc open func index(of dataSet: Element) -> Index
    {
        return index(where: { $0 === dataSet }) ?? -1
    }
    
    /// - returns: The first DataSet from the datasets-array that has it's dependency on the left axis. Returns null if no DataSet with left dependency could be found.
    @objc open func getFirstLeft(dataSets: [Element]) -> Element?
    {
        return first { $0.axisDependency == .left }
    }
    
    /// - returns: The first DataSet from the datasets-array that has it's dependency on the right axis. Returns null if no DataSet with right dependency could be found.
    @objc open func getFirstRight(dataSets: [Element]) -> Element?
    {
        return first { $0.axisDependency == .right }
    }
    
    /// - returns: All colors used across all DataSet objects this object represents.
    @objc open func getColors() -> [NSUIColor]
    {
        return flatMap { $0.colors.map { $0 } }
    }
    
    /// Sets a custom ValueFormatter for all DataSets this data object contains.
    @objc open func setValueFormatter(_ formatter: ValueFormatter)
    {
        forEach { $0.valueFormatter = formatter }
    }
    
    /// Sets the color of the value-text (color in which the value-labels are drawn) for all DataSets this data object contains.
    @objc open func setValueTextColor(_ color: NSUIColor)
    {
        forEach { $0.valueTextColor = color }
    }
    
    /// Sets the font for all value-labels for all DataSets this data object contains.
    @objc open func setValueFont(_ font: NSUIFont)
    {
        forEach { $0.valueFont = font }
    }
    
    /// Enables / disables drawing values (value-text) for all DataSets this data object contains.
    @objc open func setDrawValues(_ enabled: Bool)
    {
        forEach { $0.drawValuesEnabled = enabled }
    }
    
    /// Enables / disables highlighting values for all DataSets this data object contains.
    /// If set to true, this means that values can be highlighted programmatically or by touch gesture.
    @objc open var isHighlightEnabled: Bool
    {
        get { return first { $0.highlightEnabled == false } == nil }
        set { forEach { $0.highlightEnabled = newValue } }
    }

    /// Clears this data object from all DataSets and removes all Entries.
    /// Don't forget to invalidate the chart after this.
    @objc open func clearValues()
    {
        removeAll(keepingCapacity: false)
    }
    
    /// Checks if this data object contains the specified DataSet. 
    /// - returns: `true` if so, `false` ifnot.
    @objc open func contains(dataSet: Element) -> Bool
    {
        return contains { $0 === dataSet }
    }
    
    /// - returns: The total entry count across all DataSet objects this data object contains.
    @objc open var entryCount: Int
    {
        return reduce(0) { return $0 + $1.entryCount }
    }

    /// - returns: The DataSet object with the maximum number of entries or null if there are no DataSets.
    @objc open var maxEntryCountSet: Element?
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
        return dataSets.startIndex
    }

    public var endIndex: Index
    {
        return dataSets.endIndex
    }

    public func index(after: Index) -> Index
    {
        return dataSets.index(after: after)
    }

    public subscript(position: Index) -> Element
    {
        get { return dataSets[position] }
        set { self._dataSets[position] = newValue }
    }
}

// MARK: RandomAccessCollection
extension ChartData: RandomAccessCollection
{
    public func index(before: Index) -> Index
    {
        return dataSets.index(before: before)
    }
}

// MARK: RangeReplaceableCollection
extension ChartData: RangeReplaceableCollection
{
    @objc(addDataSet:)
    public func append(_ newElement: Element)
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("append(_:) not supported for CombinedData")
        }

        _dataSets.append(newElement)
        calcMinMax(dataSet: newElement)
    }

    @objc(removeDataSetByIndex:)
    public func remove(at position: Index) -> Element
    {
        guard !(self is CombinedChartData) else
        {
            fatalError("remove(at:) not supported for CombinedData")
        }

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

    public func removeSubrange<R>(_ bounds: R) where R : RangeExpression, ChartData.Index == R.Bound
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
        guard !(self is CombinedChartData) else
        {
            fatalError("subscript(entry:) not supported for CombinedData")
        }

        guard let index = index(where: { $0.entryForXValue(entry.x, closestToY: entry.y) === entry }) else { return nil }
        return self[index]
    }
}
