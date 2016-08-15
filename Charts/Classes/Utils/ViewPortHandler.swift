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
public class ViewPortHandler: NSObject
{
    /// matrix used for touch events
    private var _touchMatrix = CGAffineTransformIdentity
    
    /// this rectangle defines the area in which graph values can be drawn
    private var _contentRect = CGRect()
    
    private var _chartWidth = CGFloat(0.0)
    private var _chartHeight = CGFloat(0.0)
    
    /// minimum scale value on the y-axis
    private var _minScaleY = CGFloat(1.0)
    
    /// maximum scale value on the y-axis
    private var _maxScaleY = CGFloat.max
    
    /// minimum scale value on the x-axis
    private var _minScaleX = CGFloat(1.0)
    
    /// maximum scale value on the x-axis
    private var _maxScaleX = CGFloat.max
    
    /// contains the current scale factor of the x-axis
    private var _scaleX = CGFloat(1.0)
    
    /// contains the current scale factor of the y-axis
    private var _scaleY = CGFloat(1.0)
    
    /// current translation (drag distance) on the x-axis
    private var _transX = CGFloat(0.0)
    
    /// current translation (drag distance) on the y-axis
    private var _transY = CGFloat(0.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var _transOffsetX = CGFloat(0.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var _transOffsetY = CGFloat(0.0)
    
    public override init()
    {
    }
    
    /// Constructor - don't forget calling setChartDimens(...)
    public init(width: CGFloat, height: CGFloat)
    {
        super.init()
        
        setChartDimens(width: width, height: height)
    }
    
    public func setChartDimens(width width: CGFloat, height: CGFloat)
    {
        let offsetLeft = self.offsetLeft
        let offsetTop = self.offsetTop
        let offsetRight = self.offsetRight
        let offsetBottom = self.offsetBottom
        
        _chartHeight = height
        _chartWidth = width
        
        restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    public var hasChartDimens: Bool
    {
        if (_chartHeight > 0.0 && _chartWidth > 0.0)
        {
            return true
        }
        else
        {
            return false
        }
    }

    public func restrainViewPort(offsetLeft offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat)
    {
        _contentRect.origin.x = offsetLeft
        _contentRect.origin.y = offsetTop
        _contentRect.size.width = _chartWidth - offsetLeft - offsetRight
        _contentRect.size.height = _chartHeight - offsetBottom - offsetTop
    }
    
    public var offsetLeft: CGFloat
    {
        return _contentRect.origin.x
    }
    
    public var offsetRight: CGFloat
    {
        return _chartWidth - _contentRect.size.width - _contentRect.origin.x
    }
    
    public var offsetTop: CGFloat
    {
        return _contentRect.origin.y
    }
    
    public var offsetBottom: CGFloat
    {
        return _chartHeight - _contentRect.size.height - _contentRect.origin.y
    }
    
    public var contentTop: CGFloat
    {
        return _contentRect.origin.y
    }
    
    public var contentLeft: CGFloat
    {
        return _contentRect.origin.x
    }
    
    public var contentRight: CGFloat
    {
        return _contentRect.origin.x + _contentRect.size.width
    }
    
    public var contentBottom: CGFloat
    {
        return _contentRect.origin.y + _contentRect.size.height
    }
    
    public var contentWidth: CGFloat
    {
        return _contentRect.size.width
    }
    
    public var contentHeight: CGFloat
    {
        return _contentRect.size.height
    }
    
    public var contentRect: CGRect
    {
        return _contentRect
    }
    
    public var contentCenter: CGPoint
    {
        return CGPoint(x: _contentRect.origin.x + _contentRect.size.width / 2.0, y: _contentRect.origin.y + _contentRect.size.height / 2.0)
    }
    
    public var chartHeight: CGFloat
    { 
        return _chartHeight
    }
    
    public var chartWidth: CGFloat
    { 
        return _chartWidth
    }

    // MARK: - Scaling/Panning etc.
    
    /// Zooms by the specified zoom factors.
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        return CGAffineTransformScale(_touchMatrix, scaleX, scaleY)
    }
    
    /// Zooms around the specified center
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = CGAffineTransformTranslate(_touchMatrix, x, y)
        matrix = CGAffineTransformScale(matrix, scaleX, scaleY)
        matrix = CGAffineTransformTranslate(matrix, -x, -y)
        return matrix
    }
    
    /// Zooms in by 1.4, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomIn(x x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    /// Zooms out by 0.7, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomOut(x x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    /// Sets the scale factor to the specified values.
    public func setZoom(scaleX scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform
    {
        var matrix = _touchMatrix
        matrix.a = scaleX
        matrix.d = scaleY
        return matrix
    }
    
    /// Sets the scale factor to the specified values. x and y is pivot.
    public func setZoom(scaleX scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = _touchMatrix
        matrix.a = 1.0
        matrix.d = 1.0
        matrix = CGAffineTransformTranslate(matrix, x, y)
        matrix = CGAffineTransformScale(matrix, scaleX, scaleY)
        matrix = CGAffineTransformTranslate(matrix, -x, -y)
        return matrix
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    public func fitScreen() -> CGAffineTransform
    {
        _minScaleX = 1.0
        _minScaleY = 1.0

        return CGAffineTransformIdentity
    }
    
    /// Translates to the specified point.
    public func translate(pt pt: CGPoint) -> CGAffineTransform
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = CGAffineTransformConcat(_touchMatrix, CGAffineTransformMakeTranslation(-translateX, -translateY))
        
        return matrix
    }
    
    /// Centers the viewport around the specified position (x-index and y-value) in the chart.
    /// Centering the viewport outside the bounds of the chart is not possible.
    /// Makes most sense in combination with the setScaleMinima(...) method.
    public func centerViewPort(pt pt: CGPoint, chart: ChartViewBase)
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = CGAffineTransformConcat(_touchMatrix, CGAffineTransformMakeTranslation(-translateX, -translateY))
        
        refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    /// call this method to refresh the graph with a given matrix
    public func refresh(newMatrix newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        _touchMatrix = newMatrix
        
        // make sure scale and translation are within their bounds
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
        
        chart.setNeedsDisplay()
        
        return _touchMatrix
    }
    
    /// limits the maximum scale and X translation of the given matrix
    private func limitTransAndScale(inout matrix matrix: CGAffineTransform, content: CGRect?)
    {
        // min scale-x is 1
        _scaleX = min(max(_minScaleX, matrix.a), _maxScaleX)
        
        // min scale-y is 1
        _scaleY = min(max(_minScaleY,  matrix.d), _maxScaleY)
        
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if (content != nil)
        {
            width = content!.width
            height = content!.height
        }
        
        let maxTransX = -width * (_scaleX - 1.0)
        _transX = min(max(matrix.tx, maxTransX - _transOffsetX), _transOffsetX)
        
        let maxTransY = height * (_scaleY - 1.0)
        _transY = max(min(matrix.ty, maxTransY + _transOffsetY), -_transOffsetY)
        
        matrix.tx = _transX
        matrix.a = _scaleX
        matrix.ty = _transY
        matrix.d = _scaleY
    }
    
    /// Sets the minimum scale factor for the x-axis
    public func setMinimumScaleX(xScale: CGFloat)
    {
        var newValue = xScale
        
        if (newValue < 1.0)
        {
            newValue = 1.0
        }
        
        _minScaleX = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    /// Sets the maximum scale factor for the x-axis
    public func setMaximumScaleX(xScale: CGFloat)
    {
        var newValue = xScale
        
        if (newValue == 0.0)
        {
            newValue = CGFloat.max
        }
        
        _maxScaleX = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    /// Sets the minimum and maximum scale factors for the x-axis
    public func setMinMaxScaleX(minScaleX minScaleX: CGFloat, maxScaleX: CGFloat)
    {
        var newMin = minScaleX
        var newMax = minScaleY
        
        if (newMin < 1.0)
        {
            newMin = 1.0
        }
        if (newMax == 0.0)
        {
            newMax = CGFloat.max
        }
        
        _minScaleX = newMin
        _maxScaleX = maxScaleX
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    /// Sets the minimum scale factor for the y-axis
    public func setMinimumScaleY(yScale: CGFloat)
    {
        var newValue = yScale
        
        if (newValue < 1.0)
        {
            newValue = 1.0
        }
        
        _minScaleY = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    /// Sets the maximum scale factor for the y-axis
    public func setMaximumScaleY(yScale: CGFloat)
    {
        var newValue = yScale
        
        if (newValue == 0.0)
        {
            newValue = CGFloat.max
        }
        
        _maxScaleY = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    public func setMinMaxScaleY(minScaleY minScaleY: CGFloat, maxScaleY: CGFloat)
    {
        var minScaleY = minScaleY, maxScaleY = maxScaleY
        
        if minScaleY < 1.0
        {
            minScaleY = 1.0
        }
        
        if maxScaleY == 0.0
        {
            maxScaleY = CGFloat.max
        }
        
        _minScaleY = minScaleY
        _maxScaleY = maxScaleY
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }

    public var touchMatrix: CGAffineTransform
    {
        return _touchMatrix
    }
    
    // MARK: - Boundaries Check
    
    public func isInBoundsX(x: CGFloat) -> Bool
    {
        return isInBoundsLeft(x) && isInBoundsRight(x)
    }
    
    public func isInBoundsY(y: CGFloat) -> Bool
    {
        return isInBoundsTop(y) && isInBoundsBottom(y)
    }
    
    public func isInBounds(x x: CGFloat, y: CGFloat) -> Bool
    {
        return isInBoundsX(x) && isInBoundsY(y)
    }
    
    public func isInBoundsLeft(x: CGFloat) -> Bool
    {
        return _contentRect.origin.x <= x + 1.0
    }
    
    public func isInBoundsRight(x: CGFloat) -> Bool
    {
        let x = floor(x * 100.0) / 100.0
        return (_contentRect.origin.x + _contentRect.size.width) >= x - 1.0
    }
    
    public func isInBoundsTop(y: CGFloat) -> Bool
    {
        return _contentRect.origin.y <= y
    }
    
    public func isInBoundsBottom(y: CGFloat) -> Bool
    {
        let normalizedY = floor(y * 100.0) / 100.0
        return (_contentRect.origin.y + _contentRect.size.height) >= normalizedY
    }
    
    /// - returns: The current x-scale factor
    public var scaleX: CGFloat
    {
        return _scaleX
    }
    
    /// - returns: The current y-scale factor
    public var scaleY: CGFloat
    {
        return _scaleY
    }
    
    /// - returns: The minimum x-scale factor
    public var minScaleX: CGFloat
    {
        return _minScaleX
    }
    
    /// - returns: The minimum y-scale factor
    public var minScaleY: CGFloat
    {
        return _minScaleY
    }
    
    /// - returns: The minimum x-scale factor
    public var maxScaleX: CGFloat
    {
        return _maxScaleX
    }
    
    /// - returns: The minimum y-scale factor
    public var maxScaleY: CGFloat
    {
        return _maxScaleY
    }
    
    /// - returns: The translation (drag / pan) distance on the x-axis
    public var transX: CGFloat
    {
        return _transX
    }
    
    /// - returns: The translation (drag / pan) distance on the y-axis
    public var transY: CGFloat
    {
        return _transY
    }
    
    /// if the chart is fully zoomed out, return true
    public var isFullyZoomedOut: Bool
    {
        return isFullyZoomedOutX && isFullyZoomedOutY
    }
    
    /// - returns: `true` if the chart is fully zoomed out on it's y-axis (vertical).
    public var isFullyZoomedOutY: Bool
    {
        return !(_scaleY > _minScaleY || _minScaleY > 1.0)
    }
    
    /// - returns: `true` if the chart is fully zoomed out on it's x-axis (horizontal).
    public var isFullyZoomedOutX: Bool
    {
        return !(_scaleX > _minScaleX || _minScaleX > 1.0)
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the x-axis.
    public func setDragOffsetX(offset: CGFloat)
    {
        _transOffsetX = offset
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the y-axis.
    public func setDragOffsetY(offset: CGFloat)
    {
        _transOffsetY = offset
    }
    
    /// - returns: `true` if both drag offsets (x and y) are zero or smaller.
    public var hasNoDragOffset: Bool
    {
        return _transOffsetX <= 0.0 && _transOffsetY <= 0.0
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed out on the x-axis
    public var canZoomOutMoreX: Bool
    {
        return _scaleX > _minScaleX
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed in on the x-axis
    public var canZoomInMoreX: Bool
    {
        return _scaleX < _maxScaleX
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed out on the y-axis
    public var canZoomOutMoreY: Bool
    {
        return _scaleY > _minScaleY
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed in on the y-axis
    public var canZoomInMoreY: Bool
    {
        return _scaleY < _maxScaleY
    }
}
