//
//  IShapeRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

@objc
public protocol IShapeRenderer : NSObjectProtocol
{
    /// Renders the provided ScatterDataSet with a shape.
    ///
    /// - parameter context:         CGContext for drawing on
    /// - parameter dataSet:         the DataSet to be drawn
    /// - parameter viewPortHandler: contains information about the current state of the view
    /// - parameter buffer:          buffer containing the transformed values of all entries in the DataSet:
    /// - parameter renderPaint:     Paint object used for styling and drawing
    /// - parameter shapeSize:
    func renderShape(
        context context: CGContext,
                dataSet: IScatterChartDataSet,
                viewPortHandler: ChartViewPortHandler,
                point: CGPoint,
                color: NSUIColor)
}
