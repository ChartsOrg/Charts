//
//  DefaultFillFormatter.swift
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

/// Default formatter that calculates the position of the filled line.
public struct DefaultFillFormatter: FillFormatter {
    public func getFillLinePosition(
        dataSet: LineChartDataSetProtocol,
        dataProvider: LineChartDataProvider
    ) -> CGFloat {
        var fillMin: CGFloat = 0.0

        if dataSet.yMax > 0.0, dataSet.yMin < 0.0 {
            fillMin = 0.0
        } else if let data = dataProvider.data {
            let max = data.yMax > 0.0 ? 0.0 : dataProvider.chartYMax
            let min = data.yMin < 0.0 ? 0.0 : dataProvider.chartYMin

            fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max)
        }

        return fillMin
    }
}
