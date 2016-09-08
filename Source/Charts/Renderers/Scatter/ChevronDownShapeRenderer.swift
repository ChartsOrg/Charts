//
//  ChevronDownShapeRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
import Foundation

public class ChevronDownShapeRenderer : NSObject, IShapeRenderer
{
    public func renderShape(
        context context: CGContext,
                dataSet: IScatterChartDataSet,
                viewPortHandler: ViewPortHandler,
                point: CGPoint,
                color: NSUIColor)
    {
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0
        
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, point.x, point.y + 2 * shapeHalf)
        CGContextAddLineToPoint(context, point.x + 2 * shapeHalf, point.y)
        CGContextMoveToPoint(context, point.x, point.y + 2 * shapeHalf)
        CGContextAddLineToPoint(context, point.x - 2 * shapeHalf, point.y)
        CGContextStrokePath(context)
    }
}