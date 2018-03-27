//
//  DataSetDrawingOptions.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-19.
//

import Foundation

public protocol DataSetDrawingOptions {

    /// The axis this DataSet should be plotted against.
    var axisDependency: YAxis.AxisDependency { get }

    /// if true, value highlighting is enabled
    var isHighlightEnabled: Bool { get set }

    /// Set this to true to draw y-values on the chart.
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no values will be drawn even if this is enabled.
    var isDrawValuesEnabled: Bool { get set }

    /// Set this to true to draw y-icons on the chart
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no icons will be drawn even if this is enabled.
    var isDrawIconsEnabled: Bool { get set }

    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    var isVisible: Bool { get set }
}
