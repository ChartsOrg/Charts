//
//  BarLineChartViewBase.swift
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

#if !os(OSX)
    import UIKit
#endif

/// Base-class of LineChart, BarChart, ScatterChart and CandleStickChart.
public class BarLineChartViewBase: ChartViewBase, BarLineScatterCandleBubbleChartDataProvider, NSUIGestureRecognizerDelegate
{
    /// the maximum number of entries to which values will be drawn
    /// (entry numbers greater than this value will cause value-labels to disappear)
    internal var _maxVisibleCount = 100
    
    /// flag that indicates if auto scaling on the y axis is enabled
    private var _autoScaleMinMaxEnabled = false
    
    private var _pinchZoomEnabled = false
    private var _doubleTapToZoomEnabled = true
    private var _dragEnabled = true
    
    private var _scaleXEnabled = true
    private var _scaleYEnabled = true
    
    /// the color for the background of the chart-drawing area (everything behind the grid lines).
    public var gridBackgroundColor = NSUIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    public var borderColor = NSUIColor.blackColor()
    public var borderLineWidth: CGFloat = 1.0
    
    /// flag indicating if the grid background should be drawn or not
    public var drawGridBackgroundEnabled = false
    
    /// Sets drawing the borders rectangle to true. If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
    public var drawBordersEnabled = false

    /// Sets the minimum offset (padding) around the chart, defaults to 10
    public var minOffset = CGFloat(10.0)
    
    /// Sets whether the chart should keep its position (zoom / scroll) after a rotation (orientation change)
    /// **default**: false
    public var keepPositionOnRotation: Bool = false
    
    /// the object representing the left y-axis
    internal var _leftAxis: YAxis!
    
    /// the object representing the right y-axis
    internal var _rightAxis: YAxis!

    internal var _leftYAxisRenderer: YAxisRenderer!
    internal var _rightYAxisRenderer: YAxisRenderer!
    
    internal var _leftAxisTransformer: Transformer!
    internal var _rightAxisTransformer: Transformer!
    
    internal var _xAxisRenderer: XAxisRenderer!
    
    internal var _tapGestureRecognizer: NSUITapGestureRecognizer!
    internal var _doubleTapGestureRecognizer: NSUITapGestureRecognizer!
    #if !os(tvOS)
    internal var _pinchGestureRecognizer: NSUIPinchGestureRecognizer!
    #endif
    internal var _panGestureRecognizer: NSUIPanGestureRecognizer!
    
    /// flag that indicates if a custom viewport offset has been set
    private var _customViewPortEnabled = false
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        stopDeceleration()
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxis = YAxis(position: .Left)
        _rightAxis = YAxis(position: .Right)
        
        _leftAxisTransformer = Transformer(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = Transformer(viewPortHandler: _viewPortHandler)
        
        _leftYAxisRenderer = YAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _rightYAxisRenderer = YAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        
        _xAxisRenderer = XAxisRenderer(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer)
        
        self.highlighter = ChartHighlighter(chart: self)
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        _doubleTapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.nsuiNumberOfTapsRequired = 2
        _panGestureRecognizer = NSUIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        
        _panGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(_tapGestureRecognizer)
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
        self.addGestureRecognizer(_panGestureRecognizer)
        
        _doubleTapGestureRecognizer.enabled = _doubleTapToZoomEnabled
        _panGestureRecognizer.enabled = _dragEnabled

        #if !os(tvOS)
            _pinchGestureRecognizer = NSUIPinchGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.pinchGestureRecognized(_:)))
            _pinchGestureRecognizer.delegate = self
            self.addGestureRecognizer(_pinchGestureRecognizer)
            _pinchGestureRecognizer.enabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
        #endif
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        // Saving current position of chart.
        var oldPoint: CGPoint?
        if (keepPositionOnRotation && (keyPath == "frame" || keyPath == "bounds"))
        {
            oldPoint = viewPortHandler.contentRect.origin
            getTransformer(.Left).pixelToValues(&oldPoint!)
        }
        
        // Superclass transforms chart.
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        
        // Restoring old position of chart
        if var newPoint = oldPoint where keepPositionOnRotation
        {
            getTransformer(.Left).pointValueToPixel(&newPoint)
            viewPortHandler.centerViewPort(pt: newPoint, chart: self)
        }
        else
        {
            viewPortHandler.refresh(newMatrix: viewPortHandler.touchMatrix, chart: self, invalidate: true)
        }
    }
    
    public override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        
        if _data === nil
        {
            return
        }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }

        // execute all drawing commands
        drawGridBackground(context: context)
        
        if _leftAxis.isEnabled
        {
            _leftYAxisRenderer?.computeAxis(min: _leftAxis._axisMinimum, max: _leftAxis._axisMaximum, inverted: _leftAxis.isInverted)
        }
        if _rightAxis.isEnabled
        {
            _rightYAxisRenderer?.computeAxis(min: _rightAxis._axisMinimum, max: _rightAxis._axisMaximum, inverted: _rightAxis.isInverted)
        }
        if _xAxis.isEnabled
        {
            _xAxisRenderer?.computeAxis(min: _xAxis._axisMinimum, max: _xAxis._axisMaximum, inverted: false)
        }
        
        _xAxisRenderer?.renderAxisLine(context: context)
        _leftYAxisRenderer?.renderAxisLine(context: context)
        _rightYAxisRenderer?.renderAxisLine(context: context)

        if _autoScaleMinMaxEnabled
        {
            autoScale()
        }
        
        // The renderers are responsible for clipping, to account for line-width center etc.
        _xAxisRenderer?.renderGridLines(context: context)
        _leftYAxisRenderer?.renderGridLines(context: context)
        _rightYAxisRenderer?.renderGridLines(context: context)
        
        if _xAxis.isDrawLimitLinesBehindDataEnabled
        {
            _xAxisRenderer?.renderLimitLines(context: context)
        }
        if _leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            _leftYAxisRenderer?.renderLimitLines(context: context)
        }
        if _rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            _rightYAxisRenderer?.renderLimitLines(context: context)
        }
        
        // make sure the data cannot be drawn outside the content-rect
        CGContextSaveGState(context)
        CGContextClipToRect(context, _viewPortHandler.contentRect)
        renderer?.drawData(context: context)
        
        // if highlighting is enabled
        if (valuesToHighlight())
        {
            renderer?.drawHighlighted(context: context, indices: _indicesToHighlight)
        }
        
        CGContextRestoreGState(context)
        
        renderer!.drawExtras(context: context)
        
        if !_xAxis.isDrawLimitLinesBehindDataEnabled
        {
            _xAxisRenderer?.renderLimitLines(context: context)
        }
        if !_leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            _leftYAxisRenderer?.renderLimitLines(context: context)
        }
        if !_rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            _rightYAxisRenderer?.renderLimitLines(context: context)
        }
        
        _xAxisRenderer.renderAxisLabels(context: context)
        _leftYAxisRenderer.renderAxisLabels(context: context)
        _rightYAxisRenderer.renderAxisLabels(context: context)

        renderer!.drawValues(context: context)

        _legendRenderer.renderLegend(context: context)

        drawMarkers(context: context)

        drawDescription(context: context)
    }
    
    private var _autoScaleLastLowestVisibleX: Double?
    private var _autoScaleLastHighestVisibleX: Double?
    
    /// Performs auto scaling of the axis by recalculating the minimum and maximum y-values based on the entries currently in view.
    internal func autoScale()
    {
        guard let data = _data
            else { return }
        
        data.calcMinMaxY(fromX: self.lowestVisibleX, toX: self.highestVisibleX)
        
        _xAxis.calculate(min: data.xMin, max: data.xMax)
        
        // calculate axis range (min / max) according to provided data
        _leftAxis.calculate(min: data.getYMin(.Left), max: data.getYMax(.Left))
        _rightAxis.calculate(min: data.getYMin(.Right), max: data.getYMax(.Right))
        
        calculateOffsets();
    }
    
    internal func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(_rightAxis.axisRange), chartYMin: _rightAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(_leftAxis.axisRange), chartYMin: _leftAxis._axisMinimum)
    }
    
    internal func prepareOffsetMatrix()
    {
        _rightAxisTransformer.prepareMatrixOffset(_rightAxis.isInverted)
        _leftAxisTransformer.prepareMatrixOffset(_leftAxis.isInverted)
    }
    
    public override func notifyDataSetChanged()
    {
        renderer?.initBuffers()
        
        calcMinMax()
        
        _leftYAxisRenderer?.computeAxis(min: _leftAxis._axisMinimum, max: _leftAxis._axisMaximum, inverted: _leftAxis.isInverted)
        _rightYAxisRenderer?.computeAxis(min: _rightAxis._axisMinimum, max: _rightAxis._axisMaximum, inverted: _rightAxis.isInverted)
        
        if let data = _data
        {
            _xAxisRenderer?.computeAxis(
                min: _xAxis._axisMinimum,
                max: _xAxis._axisMaximum,
                inverted: false)

            if (_legend !== nil)
            {
                _legendRenderer?.computeLegend(data)
            }
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }
    
    internal override func calcMinMax()
    {
        // calculate / set x-axis range
        _xAxis.calculate(min: _data?.xMin ?? 0.0, max: _data?.xMax ?? 0.0)
        
        // calculate axis range (min / max) according to provided data
        _leftAxis.calculate(min: _data?.getYMin(.Left) ?? 0.0, max: _data?.getYMax(.Left) ?? 0.0)
        _rightAxis.calculate(min: _data?.getYMin(.Right) ?? 0.0, max: _data?.getYMax(.Right) ?? 0.0)
    }
    
    internal func calculateLegendOffsets(inout offsetLeft offsetLeft: CGFloat, inout offsetTop: CGFloat, inout offsetRight: CGFloat, inout offsetBottom: CGFloat)
    {
        // setup offsets for legend
        if _legend !== nil && _legend.isEnabled && !_legend.drawInside
        {
            switch _legend.orientation
            {
            case .Vertical:
                
                switch _legend.horizontalAlignment
                {
                case .Left:
                    offsetLeft += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset
                    
                case .Right:
                    offsetRight += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset
                    
                case .Center:
                    
                    switch _legend.verticalAlignment
                    {
                    case .Top:
                        offsetTop += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                        if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
                        {
                            offsetTop += xAxis.labelRotatedHeight
                        }
                        
                    case .Bottom:
                        offsetBottom += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                        if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
                        {
                            offsetBottom += xAxis.labelRotatedHeight
                        }
                        
                    default:
                        break;
                    }
                }
                
            case .Horizontal:
                
                switch _legend.verticalAlignment
                {
                case .Top:
                    offsetTop += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                    if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
                    {
                        offsetTop += xAxis.labelRotatedHeight
                    }
                    
                case .Bottom:
                    offsetBottom += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                    if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
                    {
                        offsetBottom += xAxis.labelRotatedHeight
                    }
                    
                default:
                    break;
                }
            }
        }
    }
    
    internal override func calculateOffsets()
    {
        if (!_customViewPortEnabled)
        {
            var offsetLeft = CGFloat(0.0)
            var offsetRight = CGFloat(0.0)
            var offsetTop = CGFloat(0.0)
            var offsetBottom = CGFloat(0.0)
            
            calculateLegendOffsets(offsetLeft: &offsetLeft,
                                   offsetTop: &offsetTop,
                                   offsetRight: &offsetRight,
                                   offsetBottom: &offsetBottom)
            
            // offsets for y-labels
            if (leftAxis.needsOffset)
            {
                offsetLeft += leftAxis.requiredSize().width
            }
            
            if (rightAxis.needsOffset)
            {
                offsetRight += rightAxis.requiredSize().width
            }

            if (xAxis.isEnabled && xAxis.isDrawLabelsEnabled)
            {
                let xlabelheight = xAxis.labelRotatedHeight + xAxis.yOffset
                
                // offsets for x-labels
                if (xAxis.labelPosition == .Bottom)
                {
                    offsetBottom += xlabelheight
                }
                else if (xAxis.labelPosition == .Top)
                {
                    offsetTop += xlabelheight
                }
                else if (xAxis.labelPosition == .BothSided)
                {
                    offsetBottom += xlabelheight
                    offsetTop += xlabelheight
                }
            }
            
            offsetTop += self.extraTopOffset
            offsetRight += self.extraRightOffset
            offsetBottom += self.extraBottomOffset
            offsetLeft += self.extraLeftOffset

            _viewPortHandler.restrainViewPort(
                offsetLeft: max(self.minOffset, offsetLeft),
                offsetTop: max(self.minOffset, offsetTop),
                offsetRight: max(self.minOffset, offsetRight),
                offsetBottom: max(self.minOffset, offsetBottom))
        }
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    /// draws the grid background
    internal func drawGridBackground(context context: CGContext)
    {
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            CGContextSaveGState(context)
        }
        
        if (drawGridBackgroundEnabled)
        {
            // draw the grid background
            CGContextSetFillColorWithColor(context, gridBackgroundColor.CGColor)
            CGContextFillRect(context, _viewPortHandler.contentRect)
        }
        
        if (drawBordersEnabled)
        {
            CGContextSetLineWidth(context, borderLineWidth)
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextStrokeRect(context, _viewPortHandler.contentRect)
        }
        
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            CGContextRestoreGState(context)
        }
    }
    
    // MARK: - Gestures
    
    private enum GestureScaleAxis
    {
        case Both
        case X
        case Y
    }
    
    private var _isDragging = false
    private var _isScaling = false
    private var _gestureScaleAxis = GestureScaleAxis.Both
    private var _closestDataSetToTouch: IChartDataSet!
    private var _panGestureReachedEdge: Bool = false
    private weak var _outerScrollView: NSUIScrollView?
    
    private var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    private var _decelerationLastTime: NSTimeInterval = 0.0
    private var _decelerationDisplayLink: NSUIDisplayLink!
    private var _decelerationVelocity = CGPoint()
    
    @objc private func tapGestureRecognized(recognizer: NSUITapGestureRecognizer)
    {
        if _data === nil
        {
            return
        }
        
        if (recognizer.state == NSUIGestureRecognizerState.Ended)
        {
            if !self.isHighLightPerTapEnabled { return }
            
            let h = getHighlightByTouchPoint(recognizer.locationInView(self))
            
            if (h === nil || h!.isEqual(self.lastHighlighted))
            {
                self.highlightValue(highlight: nil, callDelegate: true)
                self.lastHighlighted = nil
            }
            else
            {
                self.highlightValue(highlight: h, callDelegate: true)
                self.lastHighlighted = h
            }
        }
    }
    
    @objc private func doubleTapGestureRecognized(recognizer: NSUITapGestureRecognizer)
    {
        if _data === nil
        {
            return
        }
        
        if (recognizer.state == NSUIGestureRecognizerState.Ended)
        {
            if _data !== nil && _doubleTapToZoomEnabled && data?.entryCount > 0
            {
                var location = recognizer.locationInView(self)
                location.x = location.x - _viewPortHandler.offsetLeft
                
                if isTouchInverted()
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop)
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - _viewPortHandler.offsetBottom)
                }
                
                self.zoom(scaleX: isScaleXEnabled ? 1.4 : 1.0, scaleY: isScaleYEnabled ? 1.4 : 1.0, x: location.x, y: location.y)
            }
        }
    }
    
    #if !os(tvOS)
    @objc private func pinchGestureRecognized(recognizer: NSUIPinchGestureRecognizer)
    {
        if (recognizer.state == NSUIGestureRecognizerState.Began)
        {
            stopDeceleration()
            
            if _data !== nil &&
                (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled)
            {
                _isScaling = true
                
                if _pinchZoomEnabled
                {
                    _gestureScaleAxis = .Both
                }
                else
                {
                    let x = abs(recognizer.locationInView(self).x - recognizer.nsuiLocationOfTouch(1, inView: self).x)
                    let y = abs(recognizer.locationInView(self).y - recognizer.nsuiLocationOfTouch(1, inView: self).y)
                    
                    if _scaleXEnabled != _scaleYEnabled
                    {
                        _gestureScaleAxis = _scaleXEnabled ? .X : .Y
                    }
                    else
                    {
                        _gestureScaleAxis = x > y ? .X : .Y
                    }
                }
            }
        }
        else if (recognizer.state == NSUIGestureRecognizerState.Ended ||
            recognizer.state == NSUIGestureRecognizerState.Cancelled)
        {
            if (_isScaling)
            {
                _isScaling = false
                
                // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
                calculateOffsets()
                setNeedsDisplay()
            }
        }
        else if (recognizer.state == NSUIGestureRecognizerState.Changed)
        {
            let isZoomingOut = (recognizer.nsuiScale < 1)
            var canZoomMoreX = isZoomingOut ? _viewPortHandler.canZoomOutMoreX : _viewPortHandler.canZoomInMoreX
            var canZoomMoreY = isZoomingOut ? _viewPortHandler.canZoomOutMoreY : _viewPortHandler.canZoomInMoreY
            
            if (_isScaling)
            {
                canZoomMoreX = canZoomMoreX && _scaleXEnabled && (_gestureScaleAxis == .Both || _gestureScaleAxis == .X);
                canZoomMoreY = canZoomMoreY && _scaleYEnabled && (_gestureScaleAxis == .Both || _gestureScaleAxis == .Y);
                if canZoomMoreX || canZoomMoreY
                {
                    var location = recognizer.locationInView(self)
                    location.x = location.x - _viewPortHandler.offsetLeft
                    
                    if isTouchInverted()
                    {
                        location.y = -(location.y - _viewPortHandler.offsetTop)
                    }
                    else
                    {
                        location.y = -(_viewPortHandler.chartHeight - location.y - _viewPortHandler.offsetBottom)
                    }
                    
                    let scaleX = canZoomMoreX ? recognizer.nsuiScale : 1.0
                    let scaleY = canZoomMoreY ? recognizer.nsuiScale : 1.0
                    
                    var matrix = CGAffineTransformMakeTranslation(location.x, location.y)
                    matrix = CGAffineTransformScale(matrix, scaleX, scaleY)
                    matrix = CGAffineTransformTranslate(matrix,
                        -location.x, -location.y)
                    
                    matrix = CGAffineTransformConcat(_viewPortHandler.touchMatrix, matrix)
                    
                    _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
                    
                    if (delegate !== nil)
                    {
                        delegate?.chartScaled?(self, scaleX: scaleX, scaleY: scaleY)
                    }
                }
                
                recognizer.nsuiScale = 1.0
            }
        }
    }
    #endif
    
    @objc private func panGestureRecognized(recognizer: NSUIPanGestureRecognizer)
    {
        if (recognizer.state == NSUIGestureRecognizerState.Began && recognizer.nsuiNumberOfTouches() > 0)
        {
            stopDeceleration()
            
            if _data === nil
            { // If we have no data, we have nothing to pan and no data to highlight
                return;
            }
            
            // If drag is enabled and we are in a position where there's something to drag:
            //  * If we're zoomed in, then obviously we have something to drag.
            //  * If we have a drag offset - we always have something to drag
            if self.isDragEnabled &&
                (!self.hasNoDragOffset || !self.isFullyZoomedOut)
            {
                _isDragging = true
                
                _closestDataSetToTouch = getDataSetByTouchPoint(recognizer.nsuiLocationOfTouch(0, inView: self))
                
                let translation = recognizer.translationInView(self)
                let didUserDrag = (self is HorizontalBarChartView) ? translation.y != 0.0 : translation.x != 0.0
                
                // Check to see if user dragged at all and if so, can the chart be dragged by the given amount
                if (didUserDrag && !performPanChange(translation: translation))
                {
                    if (_outerScrollView !== nil)
                    {
                        // We can stop dragging right now, and let the scroll view take control
                        _outerScrollView = nil
                        _isDragging = false
                    }
                }
                else
                {
                    if (_outerScrollView !== nil)
                    {
                        // Prevent the parent scroll view from scrolling
                        _outerScrollView?.scrollEnabled = false
                    }
                }
                
                _lastPanPoint = recognizer.translationInView(self)
            }
            else if self.isHighlightPerDragEnabled
            {
                // We will only handle highlights on NSUIGestureRecognizerState.Changed
                
                _isDragging = false
            }
        }
        else if (recognizer.state == NSUIGestureRecognizerState.Changed)
        {
            if (_isDragging)
            {
                let originalTranslation = recognizer.translationInView(self)
                let translation = CGPoint(x: originalTranslation.x - _lastPanPoint.x, y: originalTranslation.y - _lastPanPoint.y)
                
                performPanChange(translation: translation)
                
                _lastPanPoint = originalTranslation
            }
            else if (isHighlightPerDragEnabled)
            {
                let h = getHighlightByTouchPoint(recognizer.locationInView(self))
                
                let lastHighlighted = self.lastHighlighted
                
                if ((h === nil && lastHighlighted !== nil) ||
                    (h !== nil && lastHighlighted === nil) ||
                    (h !== nil && lastHighlighted !== nil && !h!.isEqual(lastHighlighted)))
                {
                    self.lastHighlighted = h
                    self.highlightValue(highlight: h, callDelegate: true)
                }
            }
        }
        else if (recognizer.state == NSUIGestureRecognizerState.Ended || recognizer.state == NSUIGestureRecognizerState.Cancelled)
        {
            if (_isDragging)
            {
                if (recognizer.state == NSUIGestureRecognizerState.Ended && isDragDecelerationEnabled)
                {
                    stopDeceleration()
                    
                    _decelerationLastTime = CACurrentMediaTime()
                    _decelerationVelocity = recognizer.velocityInView(self)
                    
                    _decelerationDisplayLink = NSUIDisplayLink(target: self, selector: #selector(BarLineChartViewBase.decelerationLoop))
                    _decelerationDisplayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
                }
                
                _isDragging = false
            }
            
            if (_outerScrollView !== nil)
            {
                _outerScrollView?.scrollEnabled = true
                _outerScrollView = nil
            }
        }
    }
    
    private func performPanChange(translation translation: CGPoint) -> Bool
    {
        var translation = translation
        
        if isTouchInverted()
        {
            if (self is HorizontalBarChartView)
            {
                translation.x = -translation.x
            }
            else
            {
                translation.y = -translation.y
            }
        }
        
        let originalMatrix = _viewPortHandler.touchMatrix
        
        var matrix = CGAffineTransformMakeTranslation(translation.x, translation.y)
        matrix = CGAffineTransformConcat(originalMatrix, matrix)
        
        matrix = _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        if (delegate !== nil)
        {
            delegate?.chartTranslated?(self, dX: translation.x, dY: translation.y)
        }
        
        // Did we managed to actually drag or did we reach the edge?
        return matrix.tx != originalMatrix.tx || matrix.ty != originalMatrix.ty
    }
    
    private func isTouchInverted() -> Bool
    {
        return isAnyAxisInverted &&
            _closestDataSetToTouch !== nil &&
            getAxis(_closestDataSetToTouch.axisDependency).isInverted
    }
    
    public func stopDeceleration()
    {
        if (_decelerationDisplayLink !== nil)
        {
            _decelerationDisplayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            _decelerationDisplayLink = nil
        }
    }
    
    @objc private func decelerationLoop()
    {
        let currentTime = CACurrentMediaTime()
        
        _decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        _decelerationVelocity.y *= self.dragDecelerationFrictionCoef
        
        let timeInterval = CGFloat(currentTime - _decelerationLastTime)
        
        let distance = CGPoint(
            x: _decelerationVelocity.x * timeInterval,
            y: _decelerationVelocity.y * timeInterval
        )
        
        if (!performPanChange(translation: distance))
        {
            // We reached the edge, stop
            _decelerationVelocity.x = 0.0
            _decelerationVelocity.y = 0.0
        }
        
        _decelerationLastTime = currentTime
        
        if (abs(_decelerationVelocity.x) < 0.001 && abs(_decelerationVelocity.y) < 0.001)
        {
            stopDeceleration()
            
            // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
            calculateOffsets()
            setNeedsDisplay()
        }
    }
    
    private func nsuiGestureRecognizerShouldBegin(gestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        if (gestureRecognizer == _panGestureRecognizer)
        {
            if _data === nil || !_dragEnabled ||
                (self.hasNoDragOffset && self.isFullyZoomedOut && !self.isHighlightPerDragEnabled)
            {
                return false
            }
        }
        else
        {
            #if !os(tvOS)
                if (gestureRecognizer == _pinchGestureRecognizer)
                {
                    if _data === nil || (!_pinchZoomEnabled && !_scaleXEnabled && !_scaleYEnabled)
                    {
                        return false
                    }
                }
            #endif
        }
        
        return true
    }
    
    #if !os(OSX)
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (!super.gestureRecognizerShouldBegin(gestureRecognizer))
        {
            return false
        }
        
        return nsuiGestureRecognizerShouldBegin(gestureRecognizer)
    }
    #endif
    
    #if os(OSX)
    public func gestureRecognizerShouldBegin(gestureRecognizer: NSGestureRecognizer) -> Bool
    {
        return nsuiGestureRecognizerShouldBegin(gestureRecognizer)
    }
    #endif
    
    public func gestureRecognizer(gestureRecognizer: NSUIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: NSUIGestureRecognizer) -> Bool
    {
        #if !os(tvOS)
        if ((gestureRecognizer.isKindOfClass(NSUIPinchGestureRecognizer) &&
            otherGestureRecognizer.isKindOfClass(NSUIPanGestureRecognizer)) ||
            (gestureRecognizer.isKindOfClass(NSUIPanGestureRecognizer) &&
                otherGestureRecognizer.isKindOfClass(NSUIPinchGestureRecognizer)))
        {
            return true
        }
        #endif
        
        if (gestureRecognizer.isKindOfClass(NSUIPanGestureRecognizer) &&
            otherGestureRecognizer.isKindOfClass(NSUIPanGestureRecognizer) && (
                gestureRecognizer == _panGestureRecognizer
            ))
        {
            var scrollView = self.superview
            while (scrollView !== nil && !scrollView!.isKindOfClass(NSUIScrollView))
            {
                scrollView = scrollView?.superview
            }
            
            // If there is two scrollview together, we pick the superview of the inner scrollview.
            // In the case of UITableViewWrepperView, the superview will be UITableView
            if let superViewOfScrollView = scrollView?.superview where superViewOfScrollView.isKindOfClass(NSUIScrollView)
            {
                scrollView = superViewOfScrollView
            }

            var foundScrollView = scrollView as? NSUIScrollView
            
            if (foundScrollView !== nil && !foundScrollView!.scrollEnabled)
            {
                foundScrollView = nil
            }
            
            var scrollViewPanGestureRecognizer: NSUIGestureRecognizer!
            
            if (foundScrollView !== nil)
            {
                for scrollRecognizer in foundScrollView!.nsuiGestureRecognizers!
                {
                    if (scrollRecognizer.isKindOfClass(NSUIPanGestureRecognizer))
                    {
                        scrollViewPanGestureRecognizer = scrollRecognizer as! NSUIPanGestureRecognizer
                        break
                    }
                }
            }
            
            if (otherGestureRecognizer === scrollViewPanGestureRecognizer)
            {
                _outerScrollView = foundScrollView
                
                return true
            }
        }
        
        return false
    }
    
    /// MARK: Viewport modifiers
    
    /// Zooms in by 1.4, into the charts center. center.
    public func zoomIn()
    {
        let center = _viewPortHandler.contentCenter
        
        let matrix = _viewPortHandler.zoomIn(x: center.x, y: -center.y)
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }

    /// Zooms out by 0.7, from the charts center. center.
    public func zoomOut()
    {
        let center = _viewPortHandler.contentCenter
        
        let matrix = _viewPortHandler.zoomOut(x: center.x, y: -center.y)
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)

        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }

    /// Zooms in or out by the given scale factor. x and y are the coordinates
    /// (in pixels) of the zoom center.
    ///
    /// - parameter scaleX: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter scaleY: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter x:
    /// - parameter y:
    public func zoom(
        scaleX scaleX: CGFloat,
               scaleY: CGFloat,
               x: CGFloat,
               y: CGFloat)
    {
        let matrix = _viewPortHandler.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: -y)
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }
    
    /// Zooms in or out by the given scale factor.
    /// x and y are the values (**not pixels**) of the zoom center.
    ///
    /// - parameter scaleX: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter scaleY: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis:
    public func zoom(
        scaleX scaleX: CGFloat,
               scaleY: CGFloat,
               xValue: Double,
               yValue: Double,
               axis: YAxis.AxisDependency)
    {
        let job = ZoomViewJob(
            viewPortHandler: viewPortHandler,
            scaleX: scaleX,
            scaleY: scaleY,
            xValue: xValue,
            yValue: yValue,
            transformer: getTransformer(axis),
            axis: axis,
            view: self)
        addViewportJob(job)
    }
    
    /// Zooms to the center of the chart with the given scale factor.
    ///
    /// - parameter scaleX: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter scaleY: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis:
    public func zoomToCenter(
        scaleX scaleX: CGFloat,
               scaleY: CGFloat)
    {
        let center = centerOffsets
        let matrix = viewPortHandler.zoom(
            scaleX: scaleX,
            scaleY: scaleY,
            x: center.x,
            y: -center.y)
        viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
    }
    
    /// Zooms by the specified scale factor to the specified values on the specified axis.
    ///
    /// - parameter scaleX:
    /// - parameter scaleY:
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func zoomAndCenterViewAnimated(
        scaleX scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let origin = valueForTouchPoint(
            pt: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let job = AnimatedZoomViewJob(
            viewPortHandler: viewPortHandler,
            transformer: getTransformer(axis),
            view: self,
            yAxis: getAxis(axis),
            xAxisRange: _xAxis.axisRange,
            scaleX: scaleX,
            scaleY: scaleY,
            xOrigin: viewPortHandler.scaleX,
            yOrigin: viewPortHandler.scaleY,
            zoomCenterX: CGFloat(xValue),
            zoomCenterY: CGFloat(yValue),
            zoomOriginX: origin.x,
            zoomOriginY: origin.y,
            duration: duration,
            easing: easing)
            
        addViewportJob(job)
    }
    
    /// Zooms by the specified scale factor to the specified values on the specified axis.
    ///
    /// - parameter scaleX:
    /// - parameter scaleY:
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func zoomAndCenterViewAnimated(
        scaleX scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easingOption: ChartEasingOption)
    {
        zoomAndCenterViewAnimated(scaleX: scaleX, scaleY: scaleY, xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Zooms by the specified scale factor to the specified values on the specified axis.
    ///
    /// - parameter scaleX:
    /// - parameter scaleY:
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func zoomAndCenterViewAnimated(
        scaleX scaleX: CGFloat,
        scaleY: CGFloat,
        xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval)
    {
        zoomAndCenterViewAnimated(scaleX: scaleX, scaleY: scaleY, xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .EaseInOutSine)
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    public func fitScreen()
    {
        let matrix = _viewPortHandler.fitScreen()
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        calculateOffsets()
        setNeedsDisplay()
    }
    
    /// Sets the minimum scale value to which can be zoomed out. 1 = fitScreen
    public func setScaleMinima(scaleX: CGFloat, scaleY: CGFloat)
    {
        _viewPortHandler.setMinimumScaleX(scaleX)
        _viewPortHandler.setMinimumScaleY(scaleY)
    }
    
    public var visibleXRange: Double
    {
        return abs(highestVisibleX - lowestVisibleX)
    }
    
    /// Sets the size of the area (range on the x-axis) that should be maximum visible at once (no further zooming out allowed).
    ///
    /// If this is e.g. set to 10, no more than a range of 10 values on the x-axis can be viewed at once without scrolling.
    ///
    /// If you call this method, chart must have data or it has no effect.
    public func setVisibleXRangeMaximum(maxXRange: Double)
    {
        let xScale = _xAxis.axisRange / maxXRange
        _viewPortHandler.setMinimumScaleX(CGFloat(xScale))
    }
    
    /// Sets the size of the area (range on the x-axis) that should be minimum visible at once (no further zooming in allowed).
    ///
    /// If this is e.g. set to 10, no less than a range of 10 values on the x-axis can be viewed at once without scrolling.
    ///
    /// If you call this method, chart must have data or it has no effect.
    public func setVisibleXRangeMinimum(minXRange: Double)
    {
        let xScale = _xAxis.axisRange / minXRange
        _viewPortHandler.setMaximumScaleX(CGFloat(xScale))
    }

    /// Limits the maximum and minimum value count that can be visible by pinching and zooming.
    ///
    /// e.g. minRange=10, maxRange=100 no less than 10 values and no more that 100 values can be viewed
    /// at once without scrolling.
    ///
    /// If you call this method, chart must have data or it has no effect.
    public func setVisibleXRange(minXRange minXRange: Double, maxXRange: Double)
    {
        let minScale = _xAxis.axisRange / maxXRange
        let maxScale = _xAxis.axisRange / minXRange
        _viewPortHandler.setMinMaxScaleX(
            minScaleX: CGFloat(minScale),
            maxScaleX: CGFloat(maxScale))
    }
    
    /// Sets the size of the area (range on the y-axis) that should be maximum visible at once.
    ///
    /// - parameter yRange:
    /// - parameter axis: - the axis for which this limit should apply
    public func setVisibleYRangeMaximum(maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis) / maxYRange
        _viewPortHandler.setMinimumScaleY(CGFloat(yScale))
    }
    
    /// Sets the size of the area (range on the y-axis) that should be minimum visible at once, no further zooming in possible.
    ///
    /// - parameter yRange:
    /// - parameter axis: - the axis for which this limit should apply
    public func setVisibleYRangeMinimum(minYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis) / minYRange
        _viewPortHandler.setMaximumScaleY(CGFloat(yScale))
    }

    /// Limits the maximum and minimum y range that can be visible by pinching and zooming.
    ///
    /// - parameter minYRange:
    /// - parameter maxYRange:
    /// - parameter axis:
    public func setVisibleYRange(minYRange minYRange: Double, maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let minScale = getAxisRange(axis) / minYRange
        let maxScale = getAxisRange(axis) / maxYRange
        _viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }
    
    /// Moves the left side of the current viewport to the specified x-value.
    /// This also refreshes the chart by calling setNeedsDisplay().
    public func moveViewToX(xValue: Double)
    {
        let job = MoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: 0.0,
            transformer: getTransformer(.Left),
            view: self)
        
        addViewportJob(job)
    }

    /// Centers the viewport to the specified y-value on the y-axis.
    /// This also refreshes the chart by calling setNeedsDisplay().
    /// 
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    public func moveViewToY(yValue: Double, axis: YAxis.AxisDependency)
    {
        let yInView = getAxisRange(axis) / Double(_viewPortHandler.scaleY)
        
        let job = MoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: 0.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(axis),
            view: self)
        
        addViewportJob(job)
    }

    /// This will move the left side of the current viewport to the specified x-value on the x-axis, and center the viewport to the specified y-value on the y-axis.
    /// This also refreshes the chart by calling setNeedsDisplay().
    /// 
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    public func moveViewTo(xValue xValue: Double, yValue: Double, axis: YAxis.AxisDependency)
    {
        let yInView = getAxisRange(axis) / Double(_viewPortHandler.scaleY)
        
        let job = MoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(axis),
            view: self)
        
        addViewportJob(job)
    }
    
    /// This will move the left side of the current viewport to the specified x-position and center the viewport to the specified y-position animated.
    /// This also refreshes the chart by calling setNeedsDisplay().
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func moveViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let bounds = valueForTouchPoint(
            pt: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let yInView = getAxisRange(axis) / Double(_viewPortHandler.scaleY)
        
        let job = AnimatedMoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(axis),
            view: self,
            xOrigin: bounds.x,
            yOrigin: bounds.y,
            duration: duration,
            easing: easing)
        
        addViewportJob(job)
    }
    
    /// This will move the left side of the current viewport to the specified x-position and center the viewport to the specified y-position animated.
    /// This also refreshes the chart by calling setNeedsDisplay().
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func moveViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easingOption: ChartEasingOption)
    {
        moveViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// This will move the left side of the current viewport to the specified x-position and center the viewport to the specified y-position animated.
    /// This also refreshes the chart by calling setNeedsDisplay().
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func moveViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval)
    {
        moveViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .EaseInOutSine)
    }
    
    /// This will move the center of the current viewport to the specified x-value and y-value.
    /// This also refreshes the chart by calling setNeedsDisplay().
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    public func centerViewTo(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency)
    {
        let yInView = getAxisRange(axis) / Double(_viewPortHandler.scaleY)
        let xInView = xAxis.axisRange / Double(_viewPortHandler.scaleX)
        
        let job = MoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: xValue - xInView / 2.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(axis),
            view: self)
        
        addViewportJob(job)
    }
    
    /// This will move the center of the current viewport to the specified x-value and y-value animated.
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func centerViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        let bounds = valueForTouchPoint(
            pt: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop),
            axis: axis)
        
        let yInView = getAxisRange(axis) / Double(_viewPortHandler.scaleY)
        let xInView = xAxis.axisRange / Double(_viewPortHandler.scaleX)
        
        let job = AnimatedMoveViewJob(
            viewPortHandler: viewPortHandler,
            xValue: xValue - xInView / 2.0,
            yValue: yValue + yInView / 2.0,
            transformer: getTransformer(axis),
            view: self,
            xOrigin: bounds.x,
            yOrigin: bounds.y,
            duration: duration,
            easing: easing)
        
        addViewportJob(job)
    }
    
    /// This will move the center of the current viewport to the specified x-value and y-value animated.
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func centerViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval,
        easingOption: ChartEasingOption)
    {
        centerViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// This will move the center of the current viewport to the specified x-value and y-value animated.
    ///
    /// - parameter xValue:
    /// - parameter yValue:
    /// - parameter axis: which axis should be used as a reference for the y-axis
    /// - parameter duration: the duration of the animation in seconds
    /// - parameter easing:
    public func centerViewToAnimated(
        xValue xValue: Double,
        yValue: Double,
        axis: YAxis.AxisDependency,
        duration: NSTimeInterval)
    {
        centerViewToAnimated(xValue: xValue, yValue: yValue, axis: axis, duration: duration, easingOption: .EaseInOutSine)
    }

    /// Sets custom offsets for the current `ChartViewPort` (the offsets on the sides of the actual chart window). Setting this will prevent the chart from automatically calculating it's offsets. Use `resetViewPortOffsets()` to undo this.
    /// ONLY USE THIS WHEN YOU KNOW WHAT YOU ARE DOING, else use `setExtraOffsets(...)`.
    public func setViewPortOffsets(left left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        _customViewPortEnabled = true
        
        if (NSThread.isMainThread())
        {
            self._viewPortHandler.restrainViewPort(offsetLeft: left, offsetTop: top, offsetRight: right, offsetBottom: bottom)
            prepareOffsetMatrix()
            prepareValuePxMatrix()
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                self.setViewPortOffsets(left: left, top: top, right: right, bottom: bottom)
            })
        }
    }

    /// Resets all custom offsets set via `setViewPortOffsets(...)` method. Allows the chart to again calculate all offsets automatically.
    public func resetViewPortOffsets()
    {
        _customViewPortEnabled = false
        calculateOffsets()
    }

    // MARK: - Accessors
    
    /// - returns: The range of the specified axis.
    public func getAxisRange(axis: YAxis.AxisDependency) -> Double
    {
        if (axis == .Left)
        {
            return leftAxis.axisRange
        }
        else
        {
            return rightAxis.axisRange
        }
    }

    /// - returns: The position (in pixels) the provided Entry has inside the chart view
    public func getPosition(e: ChartDataEntry, axis: YAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y))

        getTransformer(axis).pointValueToPixel(&vals)

        return vals
    }

    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    public var dragEnabled: Bool
    {
        get
        {
            return _dragEnabled
        }
        set
        {
            if (_dragEnabled != newValue)
            {
                _dragEnabled = newValue
            }
        }
    }
    
    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    public var isDragEnabled: Bool
    {
        return dragEnabled
    }
    
    /// is scaling enabled? (zooming in and out by gesture) for the chart (this does not affect dragging).
    public func setScaleEnabled(enabled: Bool)
    {
        if (_scaleXEnabled != enabled || _scaleYEnabled != enabled)
        {
            _scaleXEnabled = enabled
            _scaleYEnabled = enabled
            #if !os(tvOS)
                _pinchGestureRecognizer.enabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
            #endif
        }
    }
    
    public var scaleXEnabled: Bool
    {
        get
        {
            return _scaleXEnabled
        }
        set
        {
            if (_scaleXEnabled != newValue)
            {
                _scaleXEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.enabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }
    
    public var scaleYEnabled: Bool
    {
        get
        {
            return _scaleYEnabled
        }
        set
        {
            if (_scaleYEnabled != newValue)
            {
                _scaleYEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.enabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }
    
    public var isScaleXEnabled: Bool { return scaleXEnabled; }
    public var isScaleYEnabled: Bool { return scaleYEnabled; }
    
    /// flag that indicates if double tap zoom is enabled or not
    public var doubleTapToZoomEnabled: Bool
    {
        get
        {
            return _doubleTapToZoomEnabled
        }
        set
        {
            if (_doubleTapToZoomEnabled != newValue)
            {
                _doubleTapToZoomEnabled = newValue
                _doubleTapGestureRecognizer.enabled = _doubleTapToZoomEnabled
            }
        }
    }
    
    /// **default**: true
    /// - returns: `true` if zooming via double-tap is enabled `false` ifnot.
    public var isDoubleTapToZoomEnabled: Bool
    {
        return doubleTapToZoomEnabled
    }
    
    /// flag that indicates if highlighting per dragging over a fully zoomed out chart is enabled
    public var highlightPerDragEnabled = true
    
    /// If set to true, highlighting per dragging over a fully zoomed out chart is enabled
    /// You might want to disable this when using inside a `NSUIScrollView`
    /// 
    /// **default**: true
    public var isHighlightPerDragEnabled: Bool
    {
        return highlightPerDragEnabled
    }
    
    /// **default**: true
    /// - returns: `true` if drawing the grid background is enabled, `false` ifnot.
    public var isDrawGridBackgroundEnabled: Bool
    {
        return drawGridBackgroundEnabled
    }
    
    /// **default**: false
    /// - returns: `true` if drawing the borders rectangle is enabled, `false` ifnot.
    public var isDrawBordersEnabled: Bool
    {
        return drawBordersEnabled
    }

    /// - returns: The x and y values in the chart at the given touch point
    /// (encapsulated in a `CGPoint`). This method transforms pixel coordinates to
    /// coordinates / values in the chart. This is the opposite method to
    /// `getPixelsForValues(...)`.
    public func valueForTouchPoint(pt pt: CGPoint, axis: YAxis.AxisDependency) -> CGPoint
    {
        return getTransformer(axis).valueForTouchPoint(pt)
    }

    /// Transforms the given chart values into pixels. This is the opposite
    /// method to `valueForTouchPoint(...)`.
    public func pixelForValues(x x: Double, y: Double, axis: YAxis.AxisDependency) -> CGPoint
    {
        return getTransformer(axis).pixelForValues(x: x, y: y)
    }
    
    /// - returns: The Entry object displayed at the touched position of the chart
    public func getEntryByTouchPoint(pt: CGPoint) -> ChartDataEntry!
    {
        let h = getHighlightByTouchPoint(pt)
        if (h !== nil)
        {
            return _data!.entryForHighlight(h!)
        }
        return nil
    }
    
    /// - returns: The DataSet object displayed at the touched position of the chart
    public func getDataSetByTouchPoint(pt: CGPoint) -> IBarLineScatterCandleBubbleChartDataSet!
    {
        let h = getHighlightByTouchPoint(pt)
        if (h !== nil)
        {
            return _data?.getDataSetByIndex(h!.dataSetIndex) as! IBarLineScatterCandleBubbleChartDataSet!
        }
        return nil
    }

    /// - returns: The current x-scale factor
    public var scaleX: CGFloat
    {
        if (_viewPortHandler === nil)
        {
            return 1.0
        }
        return _viewPortHandler.scaleX
    }

    /// - returns: The current y-scale factor
    public var scaleY: CGFloat
    {
        if (_viewPortHandler === nil)
        {
            return 1.0
        }
        return _viewPortHandler.scaleY
    }

    /// if the chart is fully zoomed out, return true
    public var isFullyZoomedOut: Bool { return _viewPortHandler.isFullyZoomedOut; }

    /// - returns: The left y-axis object. In the horizontal bar-chart, this is the
    /// top axis.
    public var leftAxis: YAxis
    {
        return _leftAxis
    }

    /// - returns: The right y-axis object. In the horizontal bar-chart, this is the
    /// bottom axis.
    public var rightAxis: YAxis { return _rightAxis; }

    /// - returns: The y-axis object to the corresponding AxisDependency. In the
    /// horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
    public func getAxis(axis: YAxis.AxisDependency) -> YAxis
    {
        if (axis == .Left)
        {
            return _leftAxis
        }
        else
        {
            return _rightAxis
        }
    }
    
    /// flag that indicates if pinch-zoom is enabled. if true, both x and y axis can be scaled simultaneously with 2 fingers, if false, x and y axis can be scaled separately
    public var pinchZoomEnabled: Bool
    {
        get
        {
            return _pinchZoomEnabled
        }
        set
        {
            if (_pinchZoomEnabled != newValue)
            {
                _pinchZoomEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.enabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }

    /// **default**: false
    /// - returns: `true` if pinch-zoom is enabled, `false` ifnot
    public var isPinchZoomEnabled: Bool { return pinchZoomEnabled; }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the x-axis.
    public func setDragOffsetX(offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetX(offset)
    }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the y-axis.
    public func setDragOffsetY(offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetY(offset)
    }

    /// - returns: `true` if both drag offsets (x and y) are zero or smaller.
    public var hasNoDragOffset: Bool { return _viewPortHandler.hasNoDragOffset; }

    /// The X axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of XAxisRenderer
    /// - returns: The current set X axis renderer
    public var xAxisRenderer: XAxisRenderer
    {
        get { return _xAxisRenderer }
        set { _xAxisRenderer = newValue }
    }
    
    /// The left Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of YAxisRenderer
    /// - returns: The current set left Y axis renderer
    public var leftYAxisRenderer: YAxisRenderer
    {
        get { return _leftYAxisRenderer }
        set { _leftYAxisRenderer = newValue }
    }
    
    /// The right Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of YAxisRenderer
    /// - returns: The current set right Y axis renderer
    public var rightYAxisRenderer: YAxisRenderer
    {
        get { return _rightYAxisRenderer }
        set { _rightYAxisRenderer = newValue }
    }
    
    public override var chartYMax: Double
    {
        return max(leftAxis._axisMaximum, rightAxis._axisMaximum)
    }

    public override var chartYMin: Double
    {
        return min(leftAxis._axisMinimum, rightAxis._axisMinimum)
    }
    
    /// - returns: `true` if either the left or the right or both axes are inverted.
    public var isAnyAxisInverted: Bool
    {
        return _leftAxis.isInverted || _rightAxis.isInverted
    }
    
    /// flag that indicates if auto scaling on the y axis is enabled.
    /// if yes, the y axis automatically adjusts to the min and max y values of the current x axis range whenever the viewport changes
    public var autoScaleMinMaxEnabled: Bool
    {
        get { return _autoScaleMinMaxEnabled; }
        set { _autoScaleMinMaxEnabled = newValue; }
    }
    
    /// **default**: false
    /// - returns: `true` if auto scaling on the y axis is enabled.
    public var isAutoScaleMinMaxEnabled : Bool { return autoScaleMinMaxEnabled; }
    
    /// Sets a minimum width to the specified y axis.
    public func setYAxisMinWidth(which: YAxis.AxisDependency, width: CGFloat)
    {
        if (which == .Left)
        {
            _leftAxis.minWidth = width
        }
        else
        {
            _rightAxis.minWidth = width
        }
    }
    
    /// **default**: 0.0
    /// - returns: The (custom) minimum width of the specified Y axis.
    public func getYAxisMinWidth(which: YAxis.AxisDependency) -> CGFloat
    {
        if (which == .Left)
        {
            return _leftAxis.minWidth
        }
        else
        {
            return _rightAxis.minWidth
        }
    }
    /// Sets a maximum width to the specified y axis.
    /// Zero (0.0) means there's no maximum width
    public func setYAxisMaxWidth(which: YAxis.AxisDependency, width: CGFloat)
    {
        if (which == .Left)
        {
            _leftAxis.maxWidth = width
        }
        else
        {
            _rightAxis.maxWidth = width
        }
    }
    
    /// Zero (0.0) means there's no maximum width
    ///
    /// **default**: 0.0 (no maximum specified)
    /// - returns: The (custom) maximum width of the specified Y axis.
    public func getYAxisMaxWidth(which: YAxis.AxisDependency) -> CGFloat
    {
        if (which == .Left)
        {
            return _leftAxis.maxWidth
        }
        else
        {
            return _rightAxis.maxWidth
        }
    }

    /// - returns the width of the specified y axis.
    public func getYAxisWidth(which: YAxis.AxisDependency) -> CGFloat
    {
        if (which == .Left)
        {
            return _leftAxis.requiredSize().width
        }
        else
        {
            return _rightAxis.requiredSize().width
        }
    }
    
    // MARK: - BarLineScatterCandleBubbleChartDataProvider
    
    /// - returns: The Transformer class that contains all matrices and is
    /// responsible for transforming values into pixels on the screen and
    /// backwards.
    public func getTransformer(which: YAxis.AxisDependency) -> Transformer
    {
        if (which == .Left)
        {
            return _leftAxisTransformer
        }
        else
        {
            return _rightAxisTransformer
        }
    }
    
    /// the number of maximum visible drawn values on the chart only active when `drawValuesEnabled` is enabled
    public override var maxVisibleCount: Int
    {
        get
        {
            return _maxVisibleCount
        }
        set
        {
            _maxVisibleCount = newValue
        }
    }
    
    public func isInverted(axis: YAxis.AxisDependency) -> Bool
    {
        return getAxis(axis).isInverted
    }
    
    /// - returns: The lowest x-index (value on the x-axis) that is still visible on he chart.
    public var lowestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom)
        
        getTransformer(.Left).pixelToValues(&pt)
        
        return max(xAxis._axisMinimum, Double(pt.x))
    }
    
    /// - returns: The highest x-index (value on the x-axis) that is still visible on the chart.
    public var highestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentRight,
            y: viewPortHandler.contentBottom)
        
        getTransformer(.Left).pixelToValues(&pt)

        return min(xAxis._axisMaximum, Double(pt.x))
    }
}