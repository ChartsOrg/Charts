//
//  BarLineScatterCandleBubbleRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

open class BarLineScatterCandleBubbleRenderer: DataRenderer {
    public let viewPortHandler: ViewPortHandler

    public final var accessibleChartElements: [NSUIAccessibilityElement] = []

    public let animator: Animator

    internal var _xBounds = XBounds() // Reusable XBounds object

    public init(animator: Animator, viewPortHandler: ViewPortHandler) {
        self.viewPortHandler = viewPortHandler
        self.animator = animator
    }

    open func drawData(context _: CGContext) {}

    open func drawValues(context _: CGContext) {}

    open func drawExtras(context _: CGContext) {}

    open func drawHighlighted(context _: CGContext, indices _: [Highlight]) {}

    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    internal func isInBoundsX(entry e: ChartDataEntry, dataSet: BarLineScatterCandleBubbleChartDataSet) -> Bool
    {
        let entryIndex = dataSet.firstIndex(of: e)!
        return Double(entryIndex) < Double(dataSet.count) * animator.phaseX
    }

    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    internal func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                          dataSet: BarLineScatterCandleBubbleChartDataSet,
                          animator: Animator?) -> XBounds
    {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }

    /// - Returns: `true` if the DataSet values should be drawn, `false` if not.
    internal func shouldDrawValues(forDataSet set: ChartDataSet) -> Bool {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }

    open func initBuffers() {}

    open func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool {
        guard let data = dataProvider?.data else { return false }
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }

    /// Class representing the bounds of the current viewport in terms of indices in the values array of a DataSet.
    public class XBounds {
        /// minimum visible entry index
        public var min: Int = 0

        /// maximum visible entry index
        public var max: Int = 0

        /// range of visible entry indices
        public var range: Int = 0

        public init() {}

        public init(
            chart: BarLineScatterCandleBubbleChartDataProvider,
            dataSet: BarLineScatterCandleBubbleChartDataSet,
            animator: Animator?
        ) {
            set(chart: chart, dataSet: dataSet, animator: animator)
        }

        /// Calculates the minimum and maximum x values as well as the range between them.
        public func set(
            chart: BarLineScatterCandleBubbleChartDataProvider,
            dataSet: BarLineScatterCandleBubbleChartDataSet,
            animator: Animator?
        ) {
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator?.phaseX ?? 1.0))

            let low = chart.lowestVisibleX
            let high = chart.highestVisibleX

            let entryFrom = dataSet.entryForXValue(low, closestToY: .nan, rounding: .down)
            let entryTo = dataSet.entryForXValue(high, closestToY: .nan, rounding: .up)

            min = entryFrom.flatMap(dataSet.firstIndex(of:)) ?? 0
            max = entryTo.flatMap(dataSet.firstIndex(of:)) ?? 0
            range = Int(Double(max - min) * phaseX)
        }
    }

    public func createAccessibleHeader(usingChart chart: ChartViewBase, andData data: ChartData, withDefaultDescription defaultDescription: String) -> NSUIAccessibilityElement {
        return AccessibleHeader.create(usingChart: chart, andData: data, withDefaultDescription: defaultDescription)
    }
}

extension BarLineScatterCandleBubbleRenderer.XBounds: RangeExpression {
    public typealias Bound = Int
    public func relative<C>(to collection: C) -> Range<Bound> where
        C : Collection, Bound == C.Index
    {
        return Swift.Range<Bound>(min ... min + range)
    }

    public func contains(_ element: Int) -> Bool {
        return (min ... min + range).contains(element)
    }
}

extension BarLineScatterCandleBubbleRenderer.XBounds: Sequence {
    public struct Iterator: IteratorProtocol {
        private var iterator: IndexingIterator<ClosedRange<Int>>

        fileprivate init(min: Int, max: Int) {
            iterator = (min ... max).makeIterator()
        }

        public mutating func next() -> Int? {
            return iterator.next()
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(min: min, max: min + range)
    }
}

extension BarLineScatterCandleBubbleRenderer.XBounds: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "min:\(min), max:\(max), range:\(range)"
    }
}
