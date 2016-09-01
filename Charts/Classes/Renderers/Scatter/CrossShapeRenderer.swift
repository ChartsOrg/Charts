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
import Foundation

public class CrossShapeRenderer : NSObject, IShapeRenderer
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
        CGContextMoveToPoint(context, point.x - shapeHalf, point.y)
        CGContextAddLineToPoint(context, point.x + shapeHalf, point.y)
        CGContextMoveToPoint(context, point.x, point.y - shapeHalf)
        CGContextAddLineToPoint(context, point.x, point.y + shapeHalf)
        CGContextStrokePath(context)
    }
}