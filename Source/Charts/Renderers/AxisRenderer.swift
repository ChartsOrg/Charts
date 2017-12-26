//
//  AxisRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public protocol AxisRenderer: Renderer {

    associatedtype Axis: AxisBase

    /// base axis this axis renderer works with
    var axis: Axis { get }

    /// transformer to transform values to screen pixels and return
    var transformer: Transformer? { get }

    /// Draws the axis labels on the specified context
    func renderAxisLabels(context: CGContext)

    /// Draws the grid lines belonging to the axis.
    func renderGridLines(context: CGContext)

    /// Draws the line that goes alongside the axis.
    func renderAxisLine(context: CGContext)

    /// Draws the LimitLines associated with this axis to the screen.
    func renderLimitLines(context: CGContext)

    /// Computes the axis values.
    /// - parameter min: the minimum value in the data object for this axis
    /// - parameter max: the maximum value in the data object for this axis
    func computeAxis(min: Double, max: Double, inverted: Bool)

    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    func computeAxisValues(min: Double, max: Double)
}
