//
//  ScatterChartData.swift
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

open class ScatterChartData: BarLineScatterCandleBubbleChartData {
    public required init() {
        super.init()
    }

    override public init(dataSets: [ChartDataSet]) {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSet...) {
        super.init(dataSets: elements)
    }

    /// - Returns: The maximum shape-size across all DataSets.
    open func getGreatestShapeSize() -> CGFloat {
        return (_dataSets as? [ScatterChartDataSet])?
            .max { $0.scatterShapeSize < $1.scatterShapeSize }?
            .scatterShapeSize ?? 0
    }
}
