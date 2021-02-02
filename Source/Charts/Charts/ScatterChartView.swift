//
//  ScatterChartView.swift
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

/// The ScatterChart. Draws dots, triangles, squares and custom shapes into the chartview.
open class ScatterChartView: BarLineChartViewBase, ScatterChartDataProvider {
    override open func initialize() {
        super.initialize()

        renderer = ScatterChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)

        xAxis.spaceMin = 0.5
        xAxis.spaceMax = 0.5
    }

    // MARK: - ScatterChartDataProvider

    open var scatterData: ScatterChartData? { return data as? ScatterChartData }
}
