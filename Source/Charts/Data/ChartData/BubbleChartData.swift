//
//  BubbleChartData.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

open class BubbleChartData: BarLineScatterCandleBubbleChartData {
    public required init() {
        super.init()
    }

    override public init(dataSets: [ChartDataSet]) {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSet...) {
        super.init(dataSets: elements)
    }

    /// Sets the width of the circle that surrounds the bubble when highlighted for all DataSet objects this data object contains
    open func setHighlightCircleWidth(_ width: CGFloat) {
        (_dataSets as? [BubbleChartDataSet])?.forEach { $0.highlightCircleWidth = width }
    }
}
