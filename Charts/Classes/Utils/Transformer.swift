//
//  Transformer.swift
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

/// Transformer class that contains all matrices and is responsible for transforming values into pixels on the screen and backwards.
@objc(ChartTransformer)
public class Transformer: NSObject
{
    /// matrix to map the values to the screen pixels
    internal var _matrixValueToPx = CGAffineTransformIdentity

    /// matrix for handling the different offsets of the chart
    internal var _matrixOffset = CGAffineTransformIdentity

    internal var _viewPortHandler: ViewPortHandler

    public init(viewPortHandler: ViewPortHandler)
    {
        _viewPortHandler = viewPortHandler
    }

    /// Prepares the matrix that transforms values to pixels. Calculates the scale factors from the charts size and offsets.
    public func prepareMatrixValuePx(chartXMin chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
    {
        var scaleX = (_viewPortHandler.contentWidth / deltaX)
        var scaleY = (_viewPortHandler.contentHeight / deltaY)
        
        if CGFloat.infinity == scaleX
        {
            scaleX = 0.0
        }
        if CGFloat.infinity == scaleY
        {
            scaleY = 0.0
        }

        // setup all matrices
        _matrixValueToPx = CGAffineTransformIdentity
        _matrixValueToPx = CGAffineTransformScale(_matrixValueToPx, scaleX, -scaleY)
        _matrixValueToPx = CGAffineTransformTranslate(_matrixValueToPx, CGFloat(-chartXMin), CGFloat(-chartYMin))
    }

    /// Prepares the matrix that contains all offsets.
    public func prepareMatrixOffset(inverted: Bool)
    {
        if (!inverted)
        {
            _matrixOffset = CGAffineTransformMakeTranslation(_viewPortHandler.offsetLeft, _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransformMakeScale(1.0, -1.0)
            _matrixOffset = CGAffineTransformTranslate(_matrixOffset, _viewPortHandler.offsetLeft, -_viewPortHandler.offsetTop)
        }
    }

    /// Transform an array of points with all matrices.
    // VERY IMPORTANT: Keep matrix order "value-touch-offset" when transforming.
    public func pointValuesToPixel(inout pts: [CGPoint])
    {
        let trans = valueToPixelMatrix
        for i in 0 ..< pts.count
        {
            pts[i] = CGPointApplyAffineTransform(pts[i], trans)
        }
    }
    
    public func pointValueToPixel(inout point: CGPoint)
    {
        point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
    }
    
    public func pixelForValues(x x: Double, y: Double) -> CGPoint
    {
        return CGPointApplyAffineTransform(CGPoint(x: x, y: y), valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    public func rectValueToPixel(inout r: CGRect)
    {
        r = CGRectApplyAffineTransform(r, valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    public func rectValueToPixel(inout r: CGRect, phaseY: Double)
    {
        // multiply the height of the rect with the phase
        var bottom = r.origin.y + r.size.height
        bottom *= CGFloat(phaseY)
        let top = r.origin.y * CGFloat(phaseY)
        r.size.height = bottom - top
        r.origin.y = top

        r = CGRectApplyAffineTransform(r, valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    public func rectValueToPixelHorizontal(inout r: CGRect)
    {
        r = CGRectApplyAffineTransform(r, valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    public func rectValueToPixelHorizontal(inout r: CGRect, phaseY: Double)
    {
        // multiply the height of the rect with the phase
        let left = r.origin.x * CGFloat(phaseY)
        let right = (r.origin.x + r.size.width) * CGFloat(phaseY)
        r.size.width = right - left
        r.origin.x = left
        
        r = CGRectApplyAffineTransform(r, valueToPixelMatrix)
    }

    /// transforms multiple rects with all matrices
    public func rectValuesToPixel(inout rects: [CGRect])
    {
        let trans = valueToPixelMatrix
        
        for i in 0 ..< rects.count
        {
            rects[i] = CGRectApplyAffineTransform(rects[i], trans)
        }
    }
    
    /// Transforms the given array of touch points (pixels) into values on the chart.
    public func pixelsToValues(inout pixels: [CGPoint])
    {
        let trans = pixelToValueMatrix
        
        for i in 0 ..< pixels.count
        {
            pixels[i] = CGPointApplyAffineTransform(pixels[i], trans)
        }
    }
    
    /// Transforms the given touch point (pixels) into a value on the chart.
    public func pixelToValues(inout pixel: CGPoint)
    {
        pixel = CGPointApplyAffineTransform(pixel, pixelToValueMatrix)
    }
    
    /// - returns: The x and y values in the chart at the given touch point
    /// (encapsulated in a CGPoint). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    public func valueForTouchPoint(point: CGPoint) -> CGPoint
    {
        return CGPointApplyAffineTransform(point, pixelToValueMatrix)
    }
    
    /// - returns: The x and y values in the chart at the given touch point
    /// (x/y). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    public func valueForTouchPoint(x x: CGFloat, y: CGFloat) -> CGPoint
    {
        return CGPointApplyAffineTransform(CGPoint(x: x, y: y), pixelToValueMatrix)
    }
    
    public var valueToPixelMatrix: CGAffineTransform
    {
        return
            CGAffineTransformConcat(
                CGAffineTransformConcat(
                    _matrixValueToPx,
                    _viewPortHandler.touchMatrix
                ),
                _matrixOffset
        )
    }
    
    public var pixelToValueMatrix: CGAffineTransform
    {
        return CGAffineTransformInvert(valueToPixelMatrix)
    }
}