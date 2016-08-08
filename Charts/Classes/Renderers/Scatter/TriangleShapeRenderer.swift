//
//  TriangleShapeRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
import Foundation

public class TriangleShapeRenderer : NSObject, IShapeRenderer
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
        let shapeHoleSizeHalf = dataSet.scatterShapeHoleRadius
        let shapeHoleSize = shapeHoleSizeHalf * 2.0
        let shapeHoleColor = dataSet.scatterShapeHoleColor
        let shapeStrokeSize = (shapeSize - shapeHoleSize) / 2.0
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        // create a triangle path
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, point.x, point.y - shapeHalf)
        CGContextAddLineToPoint(context, point.x + shapeHalf, point.y + shapeHalf)
        CGContextAddLineToPoint(context, point.x - shapeHalf, point.y + shapeHalf)
        
        if shapeHoleSize > 0.0
        {
            CGContextAddLineToPoint(context, point.x, point.y - shapeHalf)
            
            CGContextMoveToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
            CGContextAddLineToPoint(context, point.x + shapeHalf - shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
            CGContextAddLineToPoint(context, point.x, point.y - shapeHalf + shapeStrokeSize)
            CGContextAddLineToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
        }
        
        CGContextClosePath(context)
        
        CGContextFillPath(context)
        
        if shapeHoleSize > 0.0 && shapeHoleColor != nil
        {
            CGContextSetFillColorWithColor(context, shapeHoleColor!.CGColor)
            
            // create a triangle path
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, point.x, point.y - shapeHalf + shapeStrokeSize)
            CGContextAddLineToPoint(context, point.x + shapeHalf - shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
            CGContextAddLineToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
            CGContextClosePath(context)
            
            CGContextFillPath(context)
        }
    }
}