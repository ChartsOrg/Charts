//
//  CrossShapeRenderer.swift
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

open class CrossShapeRenderer: ShapeRenderer {
    open func renderShape(
        context: CGContext,
        dataSet: ScatterChartDataSetProtocol,
        viewPortHandler _: ViewPortHandler,
        point: CGPoint,
        color: NSUIColor
    ) {
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0

        context.setLineWidth(1.0)
        context.setStrokeColor(color.cgColor)

        context.beginPath()
        context.move(to: CGPoint(x: point.x - shapeHalf, y: point.y))
        context.addLine(to: CGPoint(x: point.x + shapeHalf, y: point.y))
        context.move(to: CGPoint(x: point.x, y: point.y - shapeHalf))
        context.addLine(to: CGPoint(x: point.x, y: point.y + shapeHalf))
        context.strokePath()
    }
}
