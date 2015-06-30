//
//  ChartViewPortHandler.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public class ChartViewPortHandler: NSObject
{
    /// matrix used for touch events
    private var _touchMatrix = CGAffineTransformIdentity
    
    /// this rectangle defines the area in which graph values can be drawn
    private var _contentRect = CGRect()
    
    private var _chartWidth = CGFloat(0.0)
    private var _chartHeight = CGFloat(0.0)
    
    /// minimum scale value on the y-axis
    private var _minScaleY = CGFloat(1.0)
    
    /// minimum scale value on the x-axis
    private var _minScaleX = CGFloat(1.0)
    
    /// maximum scale value on the x-axis
    private var _maxScaleX = CGFloat.max
    
    /// contains the current scale factor of the x-axis
    private var _scaleX = CGFloat(1.0)
    
    /// contains the current scale factor of the y-axis
    private var _scaleY = CGFloat(1.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var _transOffsetX = CGFloat(0.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private var _transOffsetY = CGFloat(0.0)
    
    public override init()
    {
    }
    
    public init(width: CGFloat, height: CGFloat)
    {
        super.init()
        
        setChartDimens(width: width, height: height)
    }
    
    public func setChartDimens(#width: CGFloat, height: CGFloat)
    {
        var offsetLeft = self.offsetLeft
        var offsetTop = self.offsetTop
        var offsetRight = self.offsetRight
        var offsetBottom = self.offsetBottom
        
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

    public func restrainViewPort(#offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat)
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
    
    public var contentRect: CGRect { return _contentRect; }
    
    public var contentCenter: CGPoint
    {
        return CGPoint(x: _contentRect.origin.x + _contentRect.size.width / 2.0, y: _contentRect.origin.y + _contentRect.size.height / 2.0)
    }
    
    public var chartHeight: CGFloat { return _chartHeight; }
    
    public var chartWidth: CGFloat { return _chartWidth; }

    // MARK: - Scaling/Panning etc.
    
    /// Zooms around the specified center
    public func zoom(#scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = CGAffineTransformTranslate(_touchMatrix, x, y)
        matrix = CGAffineTransformScale(matrix, scaleX, scaleY)
        matrix = CGAffineTransformTranslate(matrix, -x, -y)
        return matrix
    }
    
    /// Zooms in by 1.4, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomIn(#x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    /// Zooms out by 0.7, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomOut(#x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    public func fitScreen() -> CGAffineTransform
    {
        _minScaleX = 1.0
        _minScaleY = 1.0

        return CGAffineTransformIdentity
    }
    
    /// Centers the viewport around the specified position (x-index and y-value) in the chart.
    public func centerViewPort(#pt: CGPoint, chart: ChartViewBase)
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        var matrix = CGAffineTransformConcat(_touchMatrix, CGAffineTransformMakeTranslation(-translateX, -translateY))
        
        refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    /// call this method to refresh the graph with a given matrix
    public func refresh(#newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        _touchMatrix = newMatrix
        
        // make sure scale and translation are within their bounds
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
        
        chart.setNeedsDisplay()
        
        return _touchMatrix
    }
    
    /// limits the maximum scale and X translation of the given matrix
    private func limitTransAndScale(inout #matrix: CGAffineTransform, content: CGRect?)
    {
        // min scale-x is 1, max is the max CGFloat
        _scaleX = min(max(_minScaleX, matrix.a), _maxScaleX)
        
        // min scale-y is 1
        _scaleY = max(_minScaleY, matrix.d)
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if (content != nil)
        {
            width = content!.width
            height = content!.height
        }
        
        var maxTransX = -width * (_scaleX - 1.0)
        var newTransX = min(max(matrix.tx, maxTransX - _transOffsetX), _transOffsetX)
        
        var maxTransY = height * (_scaleY - 1.0)
        var newTransY = max(min(matrix.ty, maxTransY + _transOffsetY), -_transOffsetY)
        
        matrix.tx = newTransX
        matrix.a = _scaleX
        matrix.ty = newTransY
        matrix.d = _scaleY
    }
    
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
    
    public func setMaximumScaleX(xScale: CGFloat)
    {
        _maxScaleX = xScale
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    public func setMinMaxScaleX(#minScaleX: CGFloat, maxScaleX: CGFloat)
    {
        var newMin = minScaleX
        
        if (newMin < 1.0)
        {
            newMin = 1.0
        }
        
        _minScaleX = newMin
        _maxScaleX = maxScaleX
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
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
    
    public var touchMatrix: CGAffineTransform
    {
        return _touchMatrix
    }
    
    // MARK: - Boundaries Check
    
    public func isInBoundsX(x: CGFloat) -> Bool
    {
        if (isInBoundsLeft(x) && isInBoundsRight(x))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    public func isInBoundsY(y: CGFloat) -> Bool
    {
        if (isInBoundsTop(y) && isInBoundsBottom(y))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    public func isInBounds(#x: CGFloat, y: CGFloat) -> Bool
    {
        if (isInBoundsX(x) && isInBoundsY(y))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    public func isInBoundsLeft(x: CGFloat) -> Bool
    {
        return _contentRect.origin.x <= x ? true : false
    }
    
    public func isInBoundsRight(x: CGFloat) -> Bool
    {
        let normalizedX = CGFloat(Int(x * 100.0)) / 100.0
        return (_contentRect.origin.x + _contentRect.size.width) >= normalizedX ? true : false
    }
    
    public func isInBoundsTop(y: CGFloat) -> Bool
    {
        return _contentRect.origin.y <= y ? true : false
    }
    
    public func isInBoundsBottom(y: CGFloat) -> Bool
    {
        let normalizedY = CGFloat(Int(y * 100.0)) / 100.0
        return (_contentRect.origin.y + _contentRect.size.height) >= normalizedY ? true : false
    }
    
    /// returns the current x-scale factor
    public var scaleX: CGFloat
    {
        return _scaleX
    }
    
    /// returns the current y-scale factor
    public var scaleY: CGFloat
    {
        return _scaleY
    }
    
    /// if the chart is fully zoomed out, return true
    public var isFullyZoomedOut: Bool
    {
        if (isFullyZoomedOutX && isFullyZoomedOutY)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /// Returns true if the chart is fully zoomed out on it's y-axis (vertical).
    public var isFullyZoomedOutY: Bool
    {
        if (_scaleY > _minScaleY || _minScaleY > 1.0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    /// Returns true if the chart is fully zoomed out on it's x-axis (horizontal).
    public var isFullyZoomedOutX: Bool
    {
        if (_scaleX > _minScaleX || _minScaleX > 1.0)
        {
            return false
        }
        else
        {
            return true
        }
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
    
    /// Returns true if both drag offsets (x and y) are zero or smaller.
    public var hasNoDragOffset: Bool
    {
        return _transOffsetX <= 0.0 && _transOffsetY <= 0.0 ? true : false
    }
    
    public var canZoomOutMoreX: Bool
    {
        return (_scaleX > _minScaleX)
    }
    
    public var canZoomInMoreX: Bool
    {
        return (_scaleX < _maxScaleX)
    }
}