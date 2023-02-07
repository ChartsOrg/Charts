//
//  ViewPortHandler.swift
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

/// Class that contains information about the charts current viewport settings, including offsets, scale & translation levels, ...
@objc(ChartViewPortHandler)
open class ViewPortHandler: NSObject
{
    /// matrix used for touch events
    @objc open private(set) var touchMatrix = CGAffineTransform.identity

    /// this rectangle defines the area in which graph values can be drawn
    @objc open private(set) var contentRect = CGRect()
    
    @objc open private(set) var chartWidth: CGFloat = 0
    @objc open private(set) var chartHeight: CGFloat = 0

    /// minimum scale value on the y-axis
    @objc open private(set) var minScaleY: CGFloat = 1.0

    /// maximum scale value on the y-axis
    @objc open private(set) var maxScaleY = CGFloat.greatestFiniteMagnitude

    /// minimum scale value on the x-axis
    @objc open private(set) var minScaleX: CGFloat = 1.0

    /// maximum scale value on the x-axis
    @objc open private(set) var maxScaleX = CGFloat.greatestFiniteMagnitude

    /// contains the current scale factor of the x-axis
    @objc open private(set) var scaleX: CGFloat = 1.0

    /// contains the current scale factor of the y-axis
    @objc open private(set) var scaleY: CGFloat = 1.0

    /// current translation (drag / pan) distance on the x-axis
    @objc open private(set) var transX: CGFloat = 0

    /// current translation (drag / pan) distance on the y-axis
    @objc open private(set) var transY: CGFloat = 0

    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var transOffsetX: CGFloat = 0

    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var transOffsetY: CGFloat = 0

    /// Constructor - don't forget calling setChartDimens(...)
    @objc public init(width: CGFloat, height: CGFloat)
    {
        super.init()
        
        setChartDimens(width: width, height: height)
    }
    
    @objc open func setChartDimens(width: CGFloat, height: CGFloat)
    {
        let offsetLeft = self.offsetLeft
        let offsetTop = self.offsetTop
        let offsetRight = self.offsetRight
        let offsetBottom = self.offsetBottom
        
        chartHeight = height
        chartWidth = width
        
        restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    @objc open var hasChartDimens: Bool
    {
        return chartHeight > 0.0
            && chartWidth > 0.0
    }

    @objc open func restrainViewPort(offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat)
    {
        contentRect.origin.x = offsetLeft
        contentRect.origin.y = offsetTop
        contentRect.size.width = chartWidth - offsetLeft - offsetRight
        contentRect.size.height = chartHeight - offsetBottom - offsetTop
    }
    
    @objc open var offsetLeft: CGFloat
    {
        return contentRect.origin.x
    }
    
    @objc open var offsetRight: CGFloat
    {
        return chartWidth - contentRect.size.width - contentRect.origin.x
    }
    
    @objc open var offsetTop: CGFloat
    {
        return contentRect.origin.y
    }
    
    @objc open var offsetBottom: CGFloat
    {
        return chartHeight - contentRect.size.height - contentRect.origin.y
    }
    
    @objc open var contentTop: CGFloat
    {
        return contentRect.origin.y
    }
    
    @objc open var contentLeft: CGFloat
    {
        return contentRect.origin.x
    }
    
    @objc open var contentRight: CGFloat
    {
        return contentRect.origin.x + contentRect.size.width
    }
    
    @objc open var contentBottom: CGFloat
    {
        return contentRect.origin.y + contentRect.size.height
    }
    
    @objc open var contentWidth: CGFloat
    {
        return contentRect.size.width
    }
    
    @objc open var contentHeight: CGFloat
    {
        return contentRect.size.height
    }

    @objc open var contentCenter: CGPoint
    {
        return CGPoint(x: contentRect.origin.x + contentRect.size.width / 2.0, y: contentRect.origin.y + contentRect.size.height / 2.0)
    }

    // MARK: - Scaling/Panning etc.
    
    /// Zooms by the specified zoom factors.
    @objc open func zoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        return touchMatrix.scaledBy(x: scaleX, y: scaleY)
    }
    
    /// Zooms around the specified center
    @objc open func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return touchMatrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
    }
    
    /// Zooms in by 1.4, x and y are the coordinates (in pixels) of the zoom center.
    @objc open func zoomIn(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    /// Zooms out by 0.7, x and y are the coordinates (in pixels) of the zoom center.
    @objc open func zoomOut(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    /// Zooms out to original size.
    @objc open func resetZoom() -> CGAffineTransform
    {
        return zoom(scaleX: 1.0, scaleY: 1.0, x: 0.0, y: 0.0)
    }
    
    /// Sets the scale factor to the specified values.
    @objc open func setZoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        var matrix = touchMatrix
        matrix.a = scaleX
        matrix.d = scaleY
        return matrix
    }
    
    /// Sets the scale factor to the specified values. x and y is pivot.
    @objc open func setZoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = touchMatrix
        matrix.a = 1.0
        matrix.d = 1.0
        matrix = matrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
        return matrix
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    @objc open func fitScreen() -> CGAffineTransform
    {
        minScaleX = 1.0
        minScaleY = 1.0

        return .identity
    }
    
    /// Translates to the specified point.
    @objc open func translate(pt: CGPoint) -> CGAffineTransform
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        
        return matrix
    }
    
    /// Centers the viewport around the specified position (x-index and y-value) in the chart.
    /// Centering the viewport outside the bounds of the chart is not possible.
    /// Makes most sense in combination with the setScaleMinima(...) method.
    @objc open func centerViewPort(pt: CGPoint, chart: ChartViewBase)
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    /// call this method to refresh the graph with a given matrix
    @objc @discardableResult open func refresh(newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        touchMatrix = newMatrix
        
        // make sure scale and translation are within their bounds
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
        
        chart.setNeedsDisplay()
        
        return touchMatrix
    }
    
    /// limits the maximum scale and X translation of the given matrix
    private func limitTransAndScale(matrix: inout CGAffineTransform, content: CGRect)
    {
        // min scale-x is 1
        scaleX = min(max(minScaleX, matrix.a), maxScaleX)
        
        // min scale-y is 1
        scaleY = min(max(minScaleY,  matrix.d), maxScaleY)
        
        let width = content.width
        let height = content.height

        let maxTransX = -width * (scaleX - 1.0)
        transX = min(max(matrix.tx, maxTransX - transOffsetX), transOffsetX)
        
        let maxTransY = height * (scaleY - 1.0)
        transY = max(min(matrix.ty, maxTransY + transOffsetY), -transOffsetY)
        
        matrix.tx = transX
        matrix.a = scaleX
        matrix.ty = transY
        matrix.d = scaleY
    }
    
    /// Sets the minimum scale factor for the x-axis
    @objc open func setMinimumScaleX(_ xScale: CGFloat)
    {
        minScaleX = max(xScale, 1)
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the maximum scale factor for the x-axis
    @objc open func setMaximumScaleX(_ xScale: CGFloat)
    {
        maxScaleX = xScale == 0 ? .greatestFiniteMagnitude : xScale
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the minimum and maximum scale factors for the x-axis
    @objc open func setMinMaxScaleX(minScaleX: CGFloat, maxScaleX: CGFloat)
    {
        self.minScaleX = max(minScaleX, 1)
        self.maxScaleX = maxScaleX == 0 ? .greatestFiniteMagnitude : maxScaleX
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the minimum scale factor for the y-axis
    @objc open func setMinimumScaleY(_ yScale: CGFloat)
    {
        minScaleY = max(yScale, 1)
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the maximum scale factor for the y-axis
    @objc open func setMaximumScaleY(_ yScale: CGFloat)
    {
        maxScaleY = yScale == 0 ? .greatestFiniteMagnitude : yScale
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    @objc open func setMinMaxScaleY(minScaleY: CGFloat, maxScaleY: CGFloat)
    {

        self.minScaleY = max(minScaleY, 1)
        self.maxScaleY = maxScaleY == 0 ? .greatestFiniteMagnitude : maxScaleY
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }

    // MARK: - Boundaries Check
    
    @objc open func isInBoundsX(_ x: CGFloat) -> Bool
    {
        return isInBoundsLeft(x) && isInBoundsRight(x)
    }
    
    @objc open func isInBoundsY(_ y: CGFloat) -> Bool
    {
        return isInBoundsTop(y) && isInBoundsBottom(y)
    }
    
    /**
     A method to check whether coordinate lies within the viewport.
     
     - Parameters:
         - point: a coordinate.
     */
    @objc open func isInBounds(point: CGPoint) -> Bool
    {
        return isInBounds(x: point.x, y: point.y)
    }
    
    @objc open func isInBounds(x: CGFloat, y: CGFloat) -> Bool
    {
        return isInBoundsX(x) && isInBoundsY(y)
    }
    
    @objc open func isInBoundsLeft(_ x: CGFloat) -> Bool
    {
        return contentRect.origin.x <= x + 1.0
    }
    
    @objc open func isInBoundsRight(_ x: CGFloat) -> Bool
    {
        let x = floor(x * 100.0) / 100.0
        return (contentRect.origin.x + contentRect.size.width) >= x - 1.0
    }
    
    @objc open func isInBoundsTop(_ y: CGFloat) -> Bool
    {
        return contentRect.origin.y <= y
    }
    
    @objc open func isInBoundsBottom(_ y: CGFloat) -> Bool
    {
        let normalizedY = floor(y * 100.0) / 100.0
        return (contentRect.origin.y + contentRect.size.height) >= normalizedY
    }
    
    /**
     A method to check whether a line between two coordinates intersects with the view port  by using a linear function.
     
        Linear function (calculus): `y = ax + b`
            
        Note: this method will not check for collision with the right edge of the view port, as we assume lines run from left
        to right (e.g. `startPoint < endPoint`).
     
     - Parameters:
        - startPoint: the start coordinate of the line.
        - endPoint: the end coordinate of the line.
     */
    @objc open func isIntersectingLine(from startPoint: CGPoint, to endPoint: CGPoint) -> Bool
    {
        // If start- and/or endpoint fall within the viewport, bail out early.
        if isInBounds(point: startPoint) || isInBounds(point: endPoint) { return true }
        // check if x in bound when it's a vertical line
        if startPoint.x == endPoint.x { return isInBoundsX(startPoint.x) }
        
        // Calculate the slope (`a`) of the line (e.g. `a = (y2 - y1) / (x2 - x1)`).
        let a = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        // Calculate the y-correction (`b`) of the line (e.g. `b = y1 - (a * x1)`).
        let b = startPoint.y - (a * startPoint.x)
        
        // Check for colission with the left edge of the view port (e.g. `y = (a * minX) + b`).
        // if a is 0, it's a horizontal line; checking b here is still valid, as b is `point.y` all the time
        if isInBoundsY((a * contentRect.minX) + b) { return true }

        // Skip unnecessary check for collision with the right edge of the view port
        // (e.g. `y = (a * maxX) + b`), as such a line will either begin inside the view port,
        // or intersect the left, top or bottom edges of the view port. Leaving this logic here for clarity's sake:
        // if isInBoundsY((a * contentRect.maxX) + b) { return true }
        
        // While slope `a` can theoretically never be `0`, we should protect against division by zero.
        guard a != 0 else { return false }
        
        // Check for collision with the bottom edge of the view port (e.g. `x = (maxY - b) / a`).
        if isInBoundsX((contentRect.maxY - b) / a) { return true }
        
        // Check for collision with the top edge of the view port (e.g. `x = (minY - b) / a`).
        if isInBoundsX((contentRect.minY - b) / a) { return true }

        // This line does not intersect the view port.
        return false
    }
    
    /// if the chart is fully zoomed out, return true
    @objc open var isFullyZoomedOut: Bool
    {
        return isFullyZoomedOutX && isFullyZoomedOutY
    }
    
    /// `true` if the chart is fully zoomed out on it's y-axis (vertical).
    @objc open var isFullyZoomedOutY: Bool
    {
        return !(scaleY > minScaleY || minScaleY > 1.0)
    }
    
    /// `true` if the chart is fully zoomed out on it's x-axis (horizontal).
    @objc open var isFullyZoomedOutX: Bool
    {
        return !(scaleX > minScaleX || minScaleX > 1.0)
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the x-axis.
    @objc open func setDragOffsetX(_ offset: CGFloat)
    {
        transOffsetX = offset
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the y-axis.
    @objc open func setDragOffsetY(_ offset: CGFloat)
    {
        transOffsetY = offset
    }
    
    /// `true` if both drag offsets (x and y) are zero or smaller.
    @objc open var hasNoDragOffset: Bool
    {
        return transOffsetX <= 0.0 && transOffsetY <= 0.0
    }
    
    /// `true` if the chart is not yet fully zoomed out on the x-axis
    @objc open var canZoomOutMoreX: Bool
    {
        return scaleX > minScaleX
    }
    
    /// `true` if the chart is not yet fully zoomed in on the x-axis
    @objc open var canZoomInMoreX: Bool
    {
        return scaleX < maxScaleX
    }
    
    /// `true` if the chart is not yet fully zoomed out on the y-axis
    @objc open var canZoomOutMoreY: Bool
    {
        return scaleY > minScaleY
    }
    
    /// `true` if the chart is not yet fully zoomed in on the y-axis
    @objc open var canZoomInMoreY: Bool
    {
        return scaleY < maxScaleY
    }
}
