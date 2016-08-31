//
//  ChartTransformer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 6/3/15.
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
open class ChartTransformer: NSObject
{
    /// matrix to map the values to the screen pixels
    internal var _matrixValueToPx = CGAffineTransform.identity

    /// matrix for handling the different offsets of the chart
    internal var _matrixOffset = CGAffineTransform.identity

    internal var _viewPortHandler: ChartViewPortHandler

    public init(viewPortHandler: ChartViewPortHandler)
    {
        _viewPortHandler = viewPortHandler
    }

    /// Prepares the matrix that transforms values to pixels. Calculates the scale factors from the charts size and offsets.
    open func prepareMatrixValuePx(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
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
        _matrixValueToPx = CGAffineTransform.identity
        _matrixValueToPx = _matrixValueToPx.scaledBy(x: scaleX, y: -scaleY)
        _matrixValueToPx = _matrixValueToPx.translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }

    /// Prepares the matrix that contains all offsets.
    open func prepareMatrixOffset(_ inverted: Bool)
    {
        if (!inverted)
        {
            _matrixOffset = CGAffineTransform(translationX: _viewPortHandler.offsetLeft, y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransform(scaleX: 1.0, y: -1.0)
            _matrixOffset = _matrixOffset.translatedBy(x: _viewPortHandler.offsetLeft, y: -_viewPortHandler.offsetTop)
        }
    }
    
    /// Transforms an Entry into a transformed point for bar chart
    open func getTransformedValueBarChart(entry: ChartDataEntry, xIndex: Int, dataSetIndex: Int, phaseY: CGFloat, dataSetCount: Int, groupSpace: CGFloat) -> CGPoint
    {
        // calculate the x-position, depending on datasetcount
        let x = CGFloat(xIndex + (xIndex * (dataSetCount - 1)) + dataSetIndex) + groupSpace * CGFloat(xIndex) + groupSpace / 2.0
        let y = entry.value
        
        var valuePoint = CGPoint(
            x: x,
            y: CGFloat(y) * phaseY
        )
        
        pointValueToPixel(&valuePoint)
        
        return valuePoint
    }
    
    /// Transforms an Entry into a transformed point for horizontal bar chart
    open func getTransformedValueHorizontalBarChart(entry: ChartDataEntry, xIndex: Int, dataSetIndex: Int, phaseY: CGFloat, dataSetCount: Int, groupSpace: CGFloat) -> CGPoint
    {
        // calculate the x-position, depending on datasetcount
        let x = CGFloat(xIndex + (xIndex * (dataSetCount - 1)) + dataSetIndex) + groupSpace * CGFloat(xIndex) + groupSpace / 2.0
        let y = entry.value
        
        var valuePoint = CGPoint(
            x: CGFloat(y) * phaseY,
            y: x
        )
        
        pointValueToPixel(&valuePoint)
        
        return valuePoint
    }

    /// Transform an array of points with all matrices.
    // VERY IMPORTANT: Keep matrix order "value-touch-offset" when transforming.
    open func pointValuesToPixel(_ pts: inout [CGPoint])
    {
        let trans = valueToPixelMatrix
        for i in 0 ..< pts.count
        {
            pts[i] = pts[i].applying(trans)
        }
    }
    
    open func pointValueToPixel(_ point: inout CGPoint)
    {
        point = point.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    open func rectValueToPixel(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    open func rectValueToPixel(_ r: inout CGRect, phaseY: CGFloat)
    {
        // multiply the height of the rect with the phase
        var bottom = r.origin.y + r.size.height
        bottom *= phaseY
        let top = r.origin.y * phaseY
        r.size.height = bottom - top
        r.origin.y = top

        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    open func rectValueToPixelHorizontal(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    open func rectValueToPixelHorizontal(_ r: inout CGRect, phaseY: CGFloat)
    {
        // multiply the height of the rect with the phase
        var right = r.origin.x + r.size.width
        right *= phaseY
        let left = r.origin.x * phaseY
        r.size.width = right - left
        r.origin.x = left
        
        r = r.applying(valueToPixelMatrix)
    }

    /// transforms multiple rects with all matrices
    open func rectValuesToPixel(_ rects: inout [CGRect])
    {
        let trans = valueToPixelMatrix
        
        for i in 0 ..< rects.count
        {
            rects[i] = rects[i].applying(trans)
        }
    }
    
    /// Transforms the given array of touch points (pixels) into values on the chart.
    open func pixelsToValue(_ pixels: inout [CGPoint])
    {
        let trans = pixelToValueMatrix
        
        for i in 0 ..< pixels.count
        {
            pixels[i] = pixels[i].applying(trans)
        }
    }
    
    /// Transforms the given touch point (pixels) into a value on the chart.
    open func pixelToValue(_ pixel: inout CGPoint)
    {
        pixel = pixel.applying(pixelToValueMatrix)
    }
    
    /// - returns: the x and y values in the chart at the given touch point
    /// (encapsulated in a PointD). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    open func getValueByTouchPoint(_ point: CGPoint) -> CGPoint
    {
        return point.applying(pixelToValueMatrix)
    }
    
    open var valueToPixelMatrix: CGAffineTransform
    {
        return
            _matrixValueToPx.concatenating(_viewPortHandler.touchMatrix
                ).concatenating(_matrixOffset
        )
    }
    
    open var pixelToValueMatrix: CGAffineTransform
    {
        return valueToPixelMatrix.inverted()
    }
}
