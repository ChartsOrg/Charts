//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Algorithms
import Foundation
import CoreGraphics

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-value is not found.
public enum ChartDataSetRounding: Int {
    case up = 0
    case down = 1
    case closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
open class ChartDataSet: ChartBaseDataSet, NSCopying {
    public required init() {
        self.entries = []
    }

    public init(entries: [ChartDataEntry] = [], label: String = "DataSet") {
        self.entries = entries
        self.label = label
        calcMinMax()
    }

    // MARK: - Data functions and accessors

    /// - Note: Calls `notifyDataSetChanged()` after setting a new value.
    /// - Returns: The array of y-values that this DataSet represents.
    /// the entries that this dataset represents / holds together
    open private(set) var entries: [ChartDataEntry]

    /// Used to replace all entries of a data set while retaining styling properties.
    /// This is a separate method from a setter on `entries` to encourage usage
    /// of `Collection` conformances.
    ///
    /// - Parameter entries: new entries to replace existing entries in the dataset
    public func replaceEntries(_ entries: [ChartDataEntry]) {
        self.entries = entries
        notifyDataSetChanged()
    }

    open func calcMinMax() {
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        xMax = -Double.greatestFiniteMagnitude
        xMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }

        forEach(calcMinMax)
    }

    open func calcMinMaxY(fromX: Double, toX: Double) {
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }

        let indexFrom = entryIndex(x: fromX, closestToY: .nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: .nan, rounding: .up)

        guard indexTo >= indexFrom else { return }
        // only recalculate y
        self[indexFrom ... indexTo].forEach(calcMinMaxY)
    }

    open func calcMinMaxX(entry e: ChartDataEntry) {
        xMin = Swift.min(e.x, xMin)
        xMax = Swift.max(e.x, xMax)
    }

    open func calcMinMaxY(entry e: ChartDataEntry) {
        yMin = Swift.min(e.y, yMin)
        yMax = Swift.max(e.y, yMax)
    }

    /// Updates the min and max x and y value of this DataSet based on the given Entry.
    ///
    /// - Parameters:
    ///   - e:
    internal func calcMinMax(entry e: ChartDataEntry) {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
    }

    /// The minimum y-value this DataSet holds
    public internal(set) var yMin: Double = Double.greatestFiniteMagnitude

    /// The maximum y-value this DataSet holds
    public internal(set) var yMax: Double = -Double.greatestFiniteMagnitude

    /// The minimum x-value this DataSet holds
    public internal(set) var xMin: Double = Double.greatestFiniteMagnitude

    /// The maximum x-value this DataSet holds
    public internal(set) var xMax: Double = -Double.greatestFiniteMagnitude

    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    public func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding
    ) -> ChartDataEntry? {
        let index = entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1 {
            return self[index]
        }
        return nil
    }

    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    public func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double
    ) -> ChartDataEntry? {
        entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }

    /// - Returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    public func entriesForXValue(_ xValue: Double) -> [ChartDataEntry] {
        let match: (ChartDataEntry) -> Bool = { $0.x == xValue }
        let i = partitioningIndex(where: match)
        guard i < endIndex else { return [] }
        return self[i...].prefix(while: match)
    }

    /// - Parameters:
    ///   - xValue: x-value of the entry to search for
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: Rounding method if exact value was not found
    /// - Returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    public func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding
    ) -> Int {
        var closest = partitioningIndex { $0.x >= xValue }
        guard closest < endIndex else { return closest }

        let closestXValue = self[closest].x

        switch rounding {
        case .up:
            // If rounding up, and found x-value is lower than specified x, and we can go upper...
            if closestXValue < xValue, closest < index(before: endIndex) {
                formIndex(after: &closest)
            }

        case .down:
            // If rounding down, and found x-value is upper than specified x, and we can go lower...
            if closestXValue > xValue, closest > startIndex {
                formIndex(before: &closest)
            }

        case .closest:
            break
        }

        guard closest < endIndex else { return endIndex }

        // Search by closest to y-value
        if !yValue.isNaN {
            while closest > startIndex, self[index(before: closest)].x == closestXValue {
                formIndex(before: &closest)
            }

            var closestYValue = self[closest].y
            var closestYIndex = closest

            while closest < endIndex - 1 {
                formIndex(after: &closest)
                let value = self[closest]

                if value.x != closestXValue { break }
                if abs(value.y - yValue) <= abs(closestYValue - yValue) {
                    closestYValue = yValue
                    closestYIndex = closest
                }
            }

            closest = closestYIndex
        }

        return closest
    }

    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    ///
    /// - Parameters:
    ///   - e: the entry to add
    public func addEntryOrdered(_ e: ChartDataEntry) {
        if let last = last, last.x > e.x {
            let startIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            let closestIndex = self[startIndex...].lastIndex { $0.x < e.x }
                ?? startIndex
            calcMinMax(entry: e)
            entries.insert(e, at: closestIndex)
        } else {
            append(e)
        }
    }

    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    ///
    /// - Parameters:
    ///   - entry: the entry to remove
    /// - Returns: `true` if the entry was removed successfully, else if the entry does not exist
    open func remove(_ entry: ChartDataEntry) -> Bool {
        guard let index = firstIndex(of: entry) else { return false }
        _ = remove(at: index)
        return true
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()

        copy.colors = colors
        copy.valueColors = valueColors
        copy.label = label
        copy.axisDependency = axisDependency
        copy.isHighlightEnabled = isHighlightEnabled
        copy.valueFormatter = valueFormatter
        copy.valueFont = valueFont
        copy.form = form
        copy.formSize = formSize
        copy.formLineWidth = formLineWidth
        copy.formLineDashPhase = formLineDashPhase
        copy.formLineDashLengths = formLineDashLengths
        copy.isDrawValuesEnabled = isDrawValuesEnabled
        copy.isDrawIconsEnabled = isDrawIconsEnabled
        copy.iconsOffset = iconsOffset
        copy.isVisible = isVisible

        copy.entries = entries
        copy.yMax = yMax
        copy.yMin = yMin
        copy.xMax = xMax
        copy.xMin = xMin

        return copy
    }

    // MARK: - Styling functions and accessors

    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    open var colors: [NSUIColor] = [
        NSUIColor(red: 140.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    ]

    /// List representing all colors that are used for drawing the actual values for this DataSet
    open var valueColors: [NSUIColor] = [.labelOrBlack]

    /// The label string that describes the DataSet.
    open var label: String? = "DataSet"

    /// The axis this DataSet should be plotted against.
    open var axisDependency = YAxis.AxisDependency.left

    /// - Returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    open func color(atIndex index: Int) -> NSUIColor {
        var index = index
        if index < 0 {
            index = 0
        }
        return colors[index % colors.count]
    }

    /// Resets all colors of this DataSet and recreates the colors array.
    open func resetColors() {
        colors.removeAll(keepingCapacity: false)
    }

    /// Adds a new color to the colors array of the DataSet.
    ///
    /// - Parameters:
    ///   - color: the color to add
    open func addColor(_ color: NSUIColor) {
        colors.append(color)
    }

    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    ///
    /// - Parameters:
    ///   - color: the color to set
    open func setColor(_ color: NSUIColor) {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }

    /// Sets colors to a single color a specific alpha value.
    ///
    /// - Parameters:
    ///   - color: the color to set
    ///   - alpha: alpha to apply to the set `color`
    open func setColor(_ color: NSUIColor, alpha: CGFloat) {
        setColor(color.withAlphaComponent(alpha))
    }

    /// Sets colors with a specific alpha value.
    ///
    /// - Parameters:
    ///   - colors: the colors to set
    ///   - alpha: alpha to apply to the set `colors`
    open func setColors(_ colors: [NSUIColor], alpha: CGFloat) {
        self.colors = colors.map { $0.withAlphaComponent(alpha) }
    }

    /// Sets colors with a specific alpha value.
    ///
    /// - Parameters:
    ///   - colors: the colors to set
    ///   - alpha: alpha to apply to the set `colors`
    open func setColors(_ colors: NSUIColor...) {
        self.colors = colors
    }

    /// `true` if value highlighting is enabled for this dataset
    open var isHighlightEnabled: Bool = true

    /// Custom formatter that is used instead of the auto-formatter if set
    open lazy var valueFormatter: ValueFormatter = DefaultValueFormatter()

    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    open var valueTextColor: NSUIColor {
        get {
            return valueColors[0]
        }
        set {
            valueColors.removeAll(keepingCapacity: false)
            valueColors.append(newValue)
        }
    }

    /// - Returns: The color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    open func valueTextColorAt(_ index: Int) -> NSUIColor {
        var index = index
        if index < 0 {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }

    /// the font for the value-text labels
    open var valueFont = NSUIFont.systemFont(ofSize: 7.0)

    /// The rotation angle (in degrees) for value-text labels
    open var valueLabelAngle = CGFloat(0.0)

    /// The form to draw for this dataset in the legend.
    open var form = Legend.Form.default

    /// The form size to draw for this dataset in the legend.
    ///
    /// Return `NaN` to use the default legend form size.
    open var formSize = CGFloat.nan

    /// The line width for drawing the form of this dataset in the legend
    ///
    /// Return `NaN` to use the default legend form line width.
    open var formLineWidth = CGFloat.nan

    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    open var formLineDashPhase: CGFloat = 0.0

    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    open var formLineDashLengths: [CGFloat]?

    open var isDrawValuesEnabled: Bool = true

    open var isDrawIconsEnabled: Bool = true

    /// Offset of icons drawn on the chart.
    ///
    /// For all charts except Pie and Radar it will be ordinary (x offset, y offset).
    ///
    /// For Pie and Radar chart it will be (y offset, distance from center offset); so if you want icon to be rendered under value, you should increase X component of CGPoint, and if you want icon to be rendered closet to center, you should decrease height component of CGPoint.
    open var iconsOffset = CGPoint(x: 0, y: 0)

    open var isVisible: Bool = true
}

// MARK: - MutableCollection

extension ChartDataSet: MutableCollection {
    public typealias Index = Int
    public typealias Element = ChartDataEntry

    public var startIndex: Index {
        return entries.startIndex
    }

    public var endIndex: Index {
        return entries.endIndex
    }

    public func index(after: Index) -> Index {
        return entries.index(after: after)
    }

    open var count: Int {
        entries.count
    }

    public subscript(position: Index) -> Element {
        get {
            // This is intentionally not a safe subscript to mirror
            // the behaviour of the built in Swift Collection Types
            return entries[position]
        }
        set {
            calcMinMax(entry: newValue)
            entries[position] = newValue
        }
    }
}

// MARK: RandomAccessCollection

extension ChartDataSet: RandomAccessCollection {
    public func index(before: Index) -> Index {
        return entries.index(before: before)
    }
}

// MARK: RangeReplaceableCollection

extension ChartDataSet: RangeReplaceableCollection {
    public func append(_ newElement: Element) {
        calcMinMax(entry: newElement)
        entries.append(newElement)
    }

    public func remove(at position: Index) -> Element {
        let element = entries.remove(at: position)
        notifyDataSetChanged()
        return element
    }

    public func removeFirst() -> Element {
        let element = entries.removeFirst()
        notifyDataSetChanged()
        return element
    }

    public func removeFirst(_ n: Int) {
        entries.removeFirst(n)
        notifyDataSetChanged()
    }

    public func removeLast() -> Element {
        let element = entries.removeLast()
        notifyDataSetChanged()
        return element
    }

    public func removeLast(_ n: Int) {
        entries.removeLast(n)
        notifyDataSetChanged()
    }

    public func removeSubrange<R>(_ bounds: R) where R: RangeExpression, Index == R.Bound {
        entries.removeSubrange(bounds)
        notifyDataSetChanged()
    }

    public func removeAll(keepingCapacity keepCapacity: Bool) {
        entries.removeAll(keepingCapacity: keepCapacity)
        notifyDataSetChanged()
    }
}

// MARK: - CustomStringConvertible
extension ChartDataSet: CustomStringConvertible {
    open var description: String {
        String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(type(of: self)), self.label ?? "", self.count])
    }
}

// MARK: - CustomDebugStringConvertible
extension ChartDataSet: CustomDebugStringConvertible {
    open var debugDescription: String {
        reduce(into: description + ":") {
            $0 += "\n\($1.description)"
        }
    }
}
