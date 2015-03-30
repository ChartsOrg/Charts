//
//  BarLineChartViewBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

/// Base-class of LineChart, BarChart, ScatterChart and CandleStickChart.
public class BarLineChartViewBase: ChartViewBase
{
    /// the maximum number of entried to which values will be drawn
    internal var _maxVisibleValueCount = 100
    
    private var _pinchZoomEnabled = false
    private var _doubleTapToZoomEnabled = true
    private var _dragEnabled = true
    
    private var _scaleXEnabled = true
    private var _scaleYEnabled = true
    
    /// the color for the background of the chart-drawing area (everything behind the grid lines).
    public var gridBackgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    public var borderColor = UIColor.blackColor()
    public var borderLineWidth: CGFloat = 1.0
    
    /// if set to true, the highlight indicator (lines for linechart, dark bar for barchart) will be drawn upon selecting values.
    public var highlightIndicatorEnabled = true
    
    /// flag indicating if the grid background should be drawn or not
    public var drawGridBackgroundEnabled = true
    
    /// Sets drawing the borders rectangle to true. If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
    public var drawBordersEnabled = false
    
    /// the object representing the labels on the y-axis, this object is prepared
    /// in the pepareYLabels() method
    internal var _leftAxis: ChartYAxis!
    internal var _rightAxis: ChartYAxis!
    
    /// the object representing the labels on the x-axis
    internal var _xAxis: ChartXAxis!

    internal var _leftYAxisRenderer: ChartYAxisRenderer!
    internal var _rightYAxisRenderer: ChartYAxisRenderer!
    
    internal var _leftAxisTransformer: ChartTransformer!
    internal var _rightAxisTransformer: ChartTransformer!
    
    internal var _xAxisRenderer: ChartXAxisRenderer!
    
    private var _tapGestureRecognizer: UITapGestureRecognizer!
    private var _doubleTapGestureRecognizer: UITapGestureRecognizer!
    private var _pinchGestureRecognizer: UIPinchGestureRecognizer!
    private var _panGestureRecognizer: UIPanGestureRecognizer!
    
    /// flag that indicates if a custom viewport offset has been set
    private var _customViewPortEnabled = false
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame);
    }
    
    public required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
    }
    
    internal override func initialize()
    {
        super.initialize();
        
        _leftAxis = ChartYAxis(position: .Left);
        _rightAxis = ChartYAxis(position: .Right);
        
        _xAxis = ChartXAxis();
        
        _leftAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler);
        _rightAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler);
        
        _leftYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer);
        _rightYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer);
        
        _xAxisRenderer = ChartXAxisRenderer(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer);
        
        _tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapGestureRecognized:"));
        _doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("doubleTapGestureRecognized:"));
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        _pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinchGestureRecognized:"));
        _panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panGestureRecognized:"));
        
        self.addGestureRecognizer(_tapGestureRecognizer);
        if (_doubleTapToZoomEnabled)
        {
            self.addGestureRecognizer(_doubleTapGestureRecognizer);
        }
        updateScaleGestureRecognizers();
        if (_dragEnabled)
        {
            self.addGestureRecognizer(_panGestureRecognizer);
        }
    }
    
    public override func drawRect(rect: CGRect)
    {
        super.drawRect(rect);
        
        if (_dataNotSet)
        {
            return;
        }
        
        let context = UIGraphicsGetCurrentContext();
        
        if (xAxis.isAdjustXLabelsEnabled)
        {
            calcModulus();
        }

        // execute all drawing commands
        drawGridBackground(context: context);
        
        if (_leftAxis.isEnabled)
        {
            _leftYAxisRenderer?.computeAxis(yMin: _leftAxis.axisMinimum, yMax: _leftAxis.axisMaximum);
        }
        if (_rightAxis.isEnabled)
        {
            _rightYAxisRenderer?.computeAxis(yMin: _rightAxis.axisMinimum, yMax: _rightAxis.axisMaximum);
        }
        
        _xAxisRenderer?.calcXBounds(_xAxisRenderer.transformer);
        _leftYAxisRenderer?.calcXBounds(_xAxisRenderer.transformer);
        _rightYAxisRenderer?.calcXBounds(_xAxisRenderer.transformer);
        
        _xAxisRenderer?.renderAxisLine(context: context);
        _leftYAxisRenderer?.renderAxisLine(context: context);
        _rightYAxisRenderer?.renderAxisLine(context: context);

        // make sure the graph values and grid cannot be drawn outside the content-rect
        CGContextSaveGState(context);

        CGContextClipToRect(context, _viewPortHandler.contentRect);

        _xAxisRenderer?.renderGridLines(context: context);
        _leftYAxisRenderer?.renderGridLines(context: context);
        _rightYAxisRenderer?.renderGridLines(context: context);
        
        renderer?.drawData(context: context);

        _leftYAxisRenderer?.renderLimitLines(context: context);
        _rightYAxisRenderer?.renderLimitLines(context: context);

        // if highlighting is enabled
        if (highlightEnabled && highlightIndicatorEnabled && valuesToHighlight())
        {
            renderer?.drawHighlighted(context: context, indices: _indicesToHightlight);
        }

        // Removes clipping rectangle
        CGContextRestoreGState(context);
        
        renderer!.drawExtras(context: context);
        
        _xAxisRenderer.renderAxisLabels(context: context);
        _leftYAxisRenderer.renderAxisLabels(context: context);
        _rightYAxisRenderer.renderAxisLabels(context: context);

        renderer!.drawValues(context: context);

        _legendRenderer.renderLegend(context: context);
        // drawLegend();

        drawMarkers(context: context);

        drawDescription(context: context);
    }
    
    internal func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _chartXMin, deltaX: _deltaX, deltaY: CGFloat(_rightAxis.axisRange), chartYMin: _rightAxis.axisMinimum);
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: _chartXMin, deltaX: _deltaX, deltaY: CGFloat(_leftAxis.axisRange), chartYMin: _leftAxis.axisMinimum);
    }
    
    internal func prepareOffsetMatrix()
    {
        _rightAxisTransformer.prepareMatrixOffset(_rightAxis.isInverted);
        _leftAxisTransformer.prepareMatrixOffset(_leftAxis.isInverted);
    }
    
    public override func notifyDataSetChanged()
    {
        if (_dataNotSet)
        {
            return;
        }

        calcMinMax();
        
        _leftAxis?._defaultValueFormatter = _defaultValueFormatter;
        _rightAxis?._defaultValueFormatter = _defaultValueFormatter;
        
        _leftYAxisRenderer?.computeAxis(yMin: _leftAxis.axisMinimum, yMax: _leftAxis.axisMaximum);
        _rightYAxisRenderer?.computeAxis(yMin: _rightAxis.axisMinimum, yMax: _rightAxis.axisMaximum);
        
        _xAxisRenderer?.computeAxis(xValAverageLength: _data.xValAverageLength, xValues: _data.xVals);
        
        _legendRenderer?.computeLegend(_data);
        
        calculateOffsets();
        
        setNeedsDisplay();
    }
    
    internal override func calcMinMax()
    {
        var minLeft = _data.getYMin(.Left);
        var maxLeft = _data.getYMax(.Left);
        var minRight = _data.getYMin(.Right);
        var maxRight = _data.getYMax(.Right);
        
        var leftRange = abs(maxLeft - (_leftAxis.isStartAtZeroEnabled ? 0.0 : minLeft));
        var rightRange = abs(maxRight - (_rightAxis.isStartAtZeroEnabled ? 0.0 : minRight));
        
        // in case all values are equal
        if (leftRange == 0.0)
        {
            maxLeft = maxLeft + 1.0;
        }
        
        if (rightRange == 0.0)
        {
            maxRight = maxRight + 1.0;
        }
        
        var topSpaceLeft = leftRange * Float(_leftAxis.spaceTop);
        var topSpaceRight = rightRange * Float(_rightAxis.spaceTop);
        var bottomSpaceLeft = leftRange * Float(_leftAxis.spaceBottom);
        var bottomSpaceRight = rightRange * Float(_rightAxis.spaceBottom);
        
        _chartXMax = Float(_data.xVals.count - 1);
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin));
        
        _leftAxis.axisMaximum = !isnan(_leftAxis.customAxisMax) ? _leftAxis.customAxisMax : (maxLeft + topSpaceLeft);
        _rightAxis.axisMaximum = !isnan(_rightAxis.customAxisMax) ? _rightAxis.customAxisMax : (maxRight + topSpaceRight);
        _leftAxis.axisMinimum = !isnan(_leftAxis.customAxisMin) ? _leftAxis.customAxisMin : (minLeft - bottomSpaceLeft);
        _rightAxis.axisMinimum = !isnan(_rightAxis.customAxisMin) ? _rightAxis.customAxisMin : (minRight - bottomSpaceRight);
        
        // consider starting at zero (0)
        if (_leftAxis.isStartAtZeroEnabled)
        {
            _leftAxis.axisMinimum = 0.0;
        }
        
        if (_rightAxis.isStartAtZeroEnabled)
        {
            _rightAxis.axisMinimum = 0.0;
        }
        
        _leftAxis.axisRange = abs(_leftAxis.axisMaximum - _leftAxis.axisMinimum);
        _rightAxis.axisRange = abs(_rightAxis.axisMaximum - _rightAxis.axisMinimum);
    }
    
    internal override func calculateOffsets()
    {
        if (!_customViewPortEnabled)
        {
            var offsetLeft = CGFloat(0.0);
            var offsetRight = CGFloat(0.0);
            var offsetTop = CGFloat(0.0);
            var offsetBottom = CGFloat(0.0);
            
            // setup offsets for legend
            if (_legend !== nil && _legend.isEnabled)
            {
                if (_legend.position == .RightOfChart
                    || _legend.position == .RightOfChartCenter)
                {
                    offsetRight += _legend.textWidthMax + _legend.xOffset * 2.0;
                }
                if (_legend.position == .LeftOfChart
                    || _legend.position == .LeftOfChartCenter)
                {
                    offsetLeft += _legend.textWidthMax + _legend.xOffset * 2.0;
                }
                else if (_legend.position == .BelowChartLeft
                    || _legend.position == .BelowChartRight
                    || _legend.position == .BelowChartCenter)
                {
                    
                    offsetBottom += _legend.textHeightMax * 3.0;
                }
            }
            
            // offsets for y-labels
            if (leftAxis.needsOffset)
            {
                offsetLeft += leftAxis.requiredSize().width;
            }
            
            if (rightAxis.needsOffset)
            {
                offsetRight += rightAxis.requiredSize().width;
            }
            
            var xlabelheight = xAxis.labelHeight * 2.0;
        
            if (xAxis.isEnabled)
            {
                // offsets for x-labels
                if (xAxis.labelPosition == .Bottom)
                {
                    offsetBottom += xlabelheight;
                }
                else if (xAxis.labelPosition == .Top)
                {
                    offsetTop += xlabelheight;
                }
                else if (xAxis.labelPosition == .BothSided)
                {
                    offsetBottom += xlabelheight;
                    offsetTop += xlabelheight;
                }
            }
            
            var min = CGFloat(10.0);
            
            _viewPortHandler.restrainViewPort(
                offsetLeft: max(min, offsetLeft),
                offsetTop: max(min, offsetTop),
                offsetRight: max(min, offsetRight),
                offsetBottom: max(min, offsetBottom));
        }
        
        prepareOffsetMatrix();
        prepareValuePxMatrix();
    }
   

    /// calculates the modulus for x-labels and grid
    internal func calcModulus()
    {
        if (_xAxis === nil)
        {
            return;
        }
        
        _xAxis.axisLabelModulus = Int(ceil((CGFloat(_data.xValCount) * _xAxis.labelWidth) / (_viewPortHandler.contentWidth * _viewPortHandler.touchMatrix.a)));
        
        if (_xAxis.axisLabelModulus < 1)
        {
            _xAxis.axisLabelModulus = 1;
        }
    }
    
    public override func getMarkerPosition(#entry: ChartDataEntry, dataSetIndex: Int) -> CGPoint
    {
        var xPos = CGFloat(entry.xIndex);
        
        if (self.isKindOfClass(BarChartView))
        {
            var bd = _data as BarChartData;
            var space = bd.groupSpace;
            var j = _data.getDataSetByIndex(dataSetIndex)!.entryIndex(entry: entry, isEqual: true);
            
            var x = CGFloat(j * (_data.dataSetCount - 1) + dataSetIndex) + space * CGFloat(j) + space / 2.0;
            
            xPos += x;
        }
        
        // position of the marker depends on selected value index and value
        var pt = CGPoint(x: xPos, y: CGFloat(entry.value) * _animator.phaseY);
        
        getTransformer(_data.getDataSetByIndex(dataSetIndex)!.axisDependency).pointValueToPixel(&pt);
        
        return pt;
    }
    
    /// draws the grid background
    internal func drawGridBackground(#context: CGContext)
    {
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            CGContextSaveGState(context);
        }
        
        if (drawGridBackgroundEnabled)
        {
            // draw the grid background
            CGContextSetFillColorWithColor(context, gridBackgroundColor.CGColor);
            CGContextFillRect(context, _viewPortHandler.contentRect);
        }
        
        if (drawBordersEnabled)
        {
            CGContextSetLineWidth(context, borderLineWidth);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextStrokeRect(context, _viewPortHandler.contentRect);
        }
        
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            CGContextRestoreGState(context);
        }
    }
    
    /// Returns the Transformer class that contains all matrices and is
    /// responsible for transforming values into pixels on the screen and
    /// backwards.
    public func getTransformer(which: ChartYAxis.AxisDependency) -> ChartTransformer
    {
        if (which == .Left)
        {
            return _leftAxisTransformer;
        }
        else
        {
            return _rightAxisTransformer;
        }
    }
    
    // MARK: - Scaling and Gestures
    
    private var _gestureStartMatrix = CGAffineTransformIdentity;
    private var _gestureScaleMatrix = CGAffineTransformIdentity;
    private var _gesturePanMatrix = CGAffineTransformIdentity;
    
    private enum GestureScaleAxis
    {
        case Both
        case X
        case Y
    }
    
    private var _isDragging = false;
    private var _isScaling = false;
    private var _gestureScaleAxis = GestureScaleAxis.Both;
    private var _closestDataSetToTouch: ChartDataSet!;
    
    /// the last highlighted object
    private var _lastHighlighted: ChartHighlight!;
    
    @objc private func tapGestureRecognized(recognizer: UITapGestureRecognizer)
    {
        if (_dataNotSet)
        {
            return;
        }
        
        if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            var h = getHighlightByTouchPoint(recognizer.locationInView(self));
            
            if (h === nil || h!.isEqual(_lastHighlighted))
            {
                self.highlightValue(highlight: nil, callDelegate: true);
                _lastHighlighted = nil;
            }
            else
            {
                _lastHighlighted = h;
                self.highlightValue(highlight: h, callDelegate: true);
            }
        }
    }
    
    @objc private func doubleTapGestureRecognized(recognizer: UITapGestureRecognizer)
    {
        if (_dataNotSet)
        {
            return;
        }
        
        if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            if (!_dataNotSet && _doubleTapToZoomEnabled)
            {
                var location = recognizer.locationInView(self);
                location.x = location.x - _viewPortHandler.offsetLeft;
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop);
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - _viewPortHandler.offsetBottom);
                }
                
                self.zoom(1.4, scaleY: 1.4, x: location.x, y: location.y);
            }
        }
    }
    
    @objc private func pinchGestureRecognized(recognizer: UIPinchGestureRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerState.Began)
        {
            if (!_dataNotSet && (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled))
            {
                if (!_isDragging)
                {
                    _gestureStartMatrix = _viewPortHandler.touchMatrix;
                }
                _isScaling = true;
                
                if (_pinchZoomEnabled)
                {
                    _gestureScaleAxis = .Both;
                }
                else
                {
                    var x = abs(recognizer.locationInView(self).x - recognizer.locationOfTouch(1, inView: self).x);
                    var y = abs(recognizer.locationInView(self).y - recognizer.locationOfTouch(1, inView: self).y);
                    
                    if (x > y)
                    {
                        _gestureScaleAxis = .X;
                    }
                    else
                    {
                        _gestureScaleAxis = .Y;
                    }
                }
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            if (_isScaling)
            {
                _isScaling = false;
                
                var location = recognizer.locationInView(self);
                location.x = location.x - _viewPortHandler.offsetLeft;
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop);
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - _viewPortHandler.offsetBottom);
                }
                
                _gestureScaleMatrix = CGAffineTransformMakeTranslation(location.x, location.y);
                _gestureScaleMatrix = CGAffineTransformScale(_gestureScaleMatrix,
                    (_gestureScaleAxis == .Both || _gestureScaleAxis == .X) && _scaleXEnabled ? recognizer.scale : 1.0,
                    (_gestureScaleAxis == .Both || _gestureScaleAxis == .Y) && _scaleYEnabled ? recognizer.scale : 1.0);
                _gestureScaleMatrix = CGAffineTransformTranslate(_gestureScaleMatrix,
                    -location.x, -location.y);
                
                var matrix = CGAffineTransformConcat(_gestureStartMatrix, _gestureScaleMatrix);
                if (_isDragging)
                {
                    matrix = CGAffineTransformConcat(matrix, _gesturePanMatrix);
                }
                
                _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
                
                // Save the matrix changes to the _gestureStartMatrix
                
                _gestureStartMatrix = CGAffineTransformConcat(_gestureStartMatrix, _gestureScaleMatrix);
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Cancelled)
        {
            if (_isScaling)
            {
                _isScaling = false;
                
                _viewPortHandler.refresh(newMatrix: _gestureStartMatrix, chart: self, invalidate: true);
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Changed)
        {
            if (_isScaling)
            {
                var location = recognizer.locationInView(self);
                location.x = location.x - _viewPortHandler.offsetLeft;
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop);
                }
                else
                {
                    location.y = -(_viewPortHandler.chartHeight - location.y - _viewPortHandler.offsetBottom);
                }
                
                _gestureScaleMatrix = CGAffineTransformMakeTranslation(location.x, location.y);
                _gestureScaleMatrix = CGAffineTransformScale(_gestureScaleMatrix,
                    (_gestureScaleAxis == .Both || _gestureScaleAxis == .X) && _scaleXEnabled ? recognizer.scale : 1.0,
                    (_gestureScaleAxis == .Both || _gestureScaleAxis == .Y) && _scaleYEnabled ? recognizer.scale : 1.0);
                _gestureScaleMatrix = CGAffineTransformTranslate(_gestureScaleMatrix,
                    -location.x, -location.y);
                
                var matrix = CGAffineTransformConcat(_gestureStartMatrix, _gestureScaleMatrix);
                if (_isDragging)
                {
                    matrix = CGAffineTransformConcat(matrix, _gesturePanMatrix);
                }
                
                _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
            }
        }
    }

    @objc private func panGestureRecognized(recognizer: UIPanGestureRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerState.Began)
        {
            if (!_dataNotSet && _dragEnabled && !self.hasNoDragOffset || !self.isFullyZoomedOut)
            {
                if (!_isScaling)
                {
                    _gestureStartMatrix = _viewPortHandler.touchMatrix;
                }
                _isDragging = true;
                
                _closestDataSetToTouch = getDataSetByTouchPoint(recognizer.locationOfTouch(0, inView: self));
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            if (_isDragging)
            {
                _isDragging = false;
                
                var translation = recognizer.translationInView(self);
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil
                    && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    translation.y = -translation.y;
                }
                
                _gesturePanMatrix = CGAffineTransformMakeTranslation(translation.x, translation.y);
                
                var matrix = _isScaling ? CGAffineTransformConcat(_gestureStartMatrix, _gestureScaleMatrix) : _gestureStartMatrix;
                matrix = CGAffineTransformConcat(matrix, _gesturePanMatrix);
                
                _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
                
                // Save the matrix changes to the _gestureStartMatrix
                
                if (_isScaling)
                {
                    translation = CGPointApplyAffineTransform(translation, _gestureScaleMatrix);
                    _gesturePanMatrix = CGAffineTransformMakeTranslation(translation.x, translation.y);
                }
                
                _gestureStartMatrix = CGAffineTransformConcat(_gestureStartMatrix, _gesturePanMatrix);
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Cancelled)
        {
            if (_isDragging)
            {
                _isDragging = false;
                
                _viewPortHandler.refresh(newMatrix: _gestureStartMatrix, chart: self, invalidate: true);
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.Changed)
        {
            if (_isDragging)
            {
                var translation = recognizer.translationInView(self);
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil
                    && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    translation.y = -translation.y;
                }
                
                _gesturePanMatrix = CGAffineTransformMakeTranslation(translation.x, translation.y);
                
                var matrix = _isScaling ? CGAffineTransformConcat(_gestureStartMatrix, _gestureScaleMatrix) : _gestureStartMatrix;
                matrix = CGAffineTransformConcat(matrix, _gesturePanMatrix);
                
                _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
            }
        }
    }
    
    /// Zooms in by 1.4f, into the charts center. center.
    public func zoomIn()
    {
        var matrix = _viewPortHandler.zoomIn(x: self.bounds.size.width / 2.0, y: -(self.bounds.size.height / 2.0));
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
    }

    /// Zooms out by 0.7f, from the charts center. center.
    public func zoomOut()
    {
        var matrix = _viewPortHandler.zoomOut(x: self.bounds.size.width / 2.0, y: -(self.bounds.size.height / 2.0));
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
    }

    /// Zooms in or out by the given scale factor. x and y are the coordinates
    /// (in pixels) of the zoom center.
    /// 
    /// :param: scaleX if < 1f --> zoom out, if > 1f --> zoom in
    /// :param: scaleY if < 1f --> zoom out, if > 1f --> zoom in
    /// :param: x
    /// :param: y
    public func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat)
    {
        var matrix = _viewPortHandler.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: -y);
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
    }

    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    public func fitScreen()
    {
        var matrix = _viewPortHandler.fitScreen();
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true);
    }
    
    /// Sets the minimum scale value to which can be zoomed out. 1f = fitScreen
    public func setScaleMinima(scaleX: CGFloat, scaleY: CGFloat)
    {
        _viewPortHandler.setMinimumScaleX(scaleX);
        _viewPortHandler.setMinimumScaleY(scaleY);
    }
    
    /// Sets the size of the area (range on the x-axis) that should be maximum
    /// visible at once. If this is e.g. set to 10, no more than 10 values on the
    /// x-axis can be viewed at once without scrolling.
    public func setVisibleXRange(xRange: CGFloat)
    {
        var xScale = _deltaX / (xRange + 0.01);
        _viewPortHandler.setMinimumScaleX(xScale);
    }

    /// Sets the size of the area (range on the y-axis) that should be maximum visible at once.
    /// 
    /// :param: yRange
    /// :param: axis - the axis for which this limit should apply
    public func setVisibleYRange(yRange: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        var yScale = getDeltaY(axis) / yRange;
        _viewPortHandler.setMinimumScaleY(yScale);
    }

    /// Moves the left side of the current viewport to the specified x-index.
    public func moveViewToX(xIndex: Int)
    {
        var pt = CGPoint(x: CGFloat(xIndex), y: 0.0);

        getTransformer(.Left).pointValueToPixel(&pt);
        _viewPortHandler.centerViewPort(pt: pt, chart: self);
    }

    /// Centers the viewport to the specified y-value on the y-axis.
    /// 
    /// :param: yValue
    /// :param: axis - which axis should be used as a reference for the y-axis
    public func moveViewToY(yValue: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        var valsInView = getDeltaY(axis) / _viewPortHandler.scaleY;

        var pt = CGPoint(x: 0.0, y: yValue + valsInView / 2.0);

        getTransformer(axis).pointValueToPixel(&pt);
        _viewPortHandler.centerViewPort(pt: pt, chart: self);
    }

    /// This will move the left side of the current viewport to the specified
    /// x-index on the x-axis, and center the viewport to the specified y-value
    /// on the y-axis.
    /// 
    /// :param: xIndex
    /// :param: yValue
    /// :param: axis - which axis should be used as a reference for the y-axis
    public func moveViewTo(xIndex: Int, yValue: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        var valsInView = getDeltaY(axis) / _viewPortHandler.scaleY;
        
        var pt = CGPoint(x: CGFloat(xIndex), y: yValue + valsInView / 2.0);
        
        getTransformer(axis).pointValueToPixel(&pt);
        _viewPortHandler.centerViewPort(pt: pt, chart: self);
    }

    /// Sets custom offsets for the current ViewPort (the offsets on the sides of the actual chart window). Setting this will prevent the chart from automatically calculating it's offsets. Use resetViewPortOffsets() to undo this.
    public func setViewPortOffsets(#left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        _customViewPortEnabled = true;
        
        if (NSThread.isMainThread())
        {
            self._viewPortHandler.restrainViewPort(offsetLeft: left, offsetTop: top, offsetRight: right, offsetBottom: bottom);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                self._viewPortHandler.restrainViewPort(offsetLeft: left, offsetTop: top, offsetRight: right, offsetBottom: bottom);
            });
        }
    }

    /// Resets all custom offsets set via setViewPortOffsets(...) method. Allows the chart to again calculate all offsets automatically.
    public func resetViewPortOffsets()
    {
        _customViewPortEnabled = false;
        calculateOffsets();
    }

    // MARK: - Accessors

    /// Returns the delta-y value (y-value range) of the specified axis.
    public func getDeltaY(axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        if (axis == .Left)
        {
            return CGFloat(leftAxis.axisRange);
        }
        else
        {
            return CGFloat(rightAxis.axisRange);
        }
    }

    /// Returns the position (in pixels) the provided Entry has inside the chart view
    public func getPosition(e: ChartDataEntry, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value));

        getTransformer(axis).pointValueToPixel(&vals);

        return vals;
    }

    /// the number of maximum visible drawn values on the chart
    /// only active when setDrawValues() is enabled
    public var maxVisibleValueCount: Int
    {
        get
        {
            return _maxVisibleValueCount;
        }
        set
        {
            _maxVisibleValueCount = newValue;
        }
    }

    /// If set to true, the highlight indicators (cross of two lines for
    /// LineChart and ScatterChart, dark bar overlay for BarChart) that give
    /// visual indication that an Entry has been selected will be drawn upon
    /// selecting values. This does not depend on the MarkerView. 
    /// :default: true
    public var isHighlightIndicatorEnabled: Bool
    {
        return highlightIndicatorEnabled;
    }

    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    public var dragEnabled: Bool
    {
        get
        {
            return _dragEnabled;
        }
        set
        {
            if (_dragEnabled != newValue)
            {
                _dragEnabled = newValue;
                if (_dragEnabled)
                {
                    self.addGestureRecognizer(_panGestureRecognizer);
                }
                else
                {
                    if (self.gestureRecognizers != nil)
                    {
                        for (var i = 0; i < self.gestureRecognizers!.count; i++)
                        {
                            if (self.gestureRecognizers?[i] === _panGestureRecognizer)
                            {
                                self.gestureRecognizers!.removeAtIndex(i);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    public var isDragEnabled: Bool
    {
        return dragEnabled;
    }
    
    /// is scaling enabled? (zooming in and out by gesture) for the chart (this does not affect dragging).
    public func setScaleEnabled(enabled: Bool)
    {
        if (_scaleXEnabled != enabled || _scaleYEnabled != enabled)
        {
            _scaleXEnabled = enabled;
            _scaleYEnabled = enabled;
            updateScaleGestureRecognizers();
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
                _scaleXEnabled = newValue;
                updateScaleGestureRecognizers();
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
                _scaleYEnabled = newValue;
                updateScaleGestureRecognizers();
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
            return _doubleTapToZoomEnabled;
        }
        set
        {
            if (_doubleTapToZoomEnabled != newValue)
            {
                _doubleTapToZoomEnabled = newValue;
                if (_doubleTapToZoomEnabled)
                {
                    self.addGestureRecognizer(_doubleTapGestureRecognizer);
                }
                else
                {
                    if (self.gestureRecognizers != nil)
                    {
                        for (var i = 0; i < self.gestureRecognizers!.count; i++)
                        {
                            if (self.gestureRecognizers?[i] === _doubleTapGestureRecognizer)
                            {
                                self.gestureRecognizers!.removeAtIndex(i);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// :returns: true if zooming via double-tap is enabled false if not.
    /// :default: true
    public var isDoubleTapToZoomEnabled: Bool
    {
        return doubleTapToZoomEnabled;
    }
    
    /// :returns: true if drawing the grid background is enabled, false if not.
    /// :default: true
    public var isDrawGridBackgroundEnabled: Bool
    {
        return drawGridBackgroundEnabled;
    }
    
    /// :returns: true if drawing the borders rectangle is enabled, false if not.
    /// :default: false
    public var isDrawBordersEnabled: Bool
    {
        return drawBordersEnabled;
    }

    /// Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the Line-, Scatter-, or CandleStick-Chart.
    public func getHighlightByTouchPoint(var pt: CGPoint) -> ChartHighlight!
    {
        if (_dataNotSet || _data === nil)
        {
            println("Can't select by touch. No data set.");
            return nil;
        }

        var valPt = CGPoint();
        valPt.x = pt.x;
        valPt.y = 0.0;

        // take any transformer to determine the x-axis value
        _leftAxisTransformer.pixelToValue(&valPt);

        var xTouchVal = valPt.x;
        var base = floor(xTouchVal);

        var touchOffset = _deltaX * 0.025;

        // touch out of chart
        if (xTouchVal < -touchOffset || xTouchVal > _deltaX + touchOffset)
        {
            return nil;
        }

        if (base < 0.0)
        {
            base = 0.0;
        }
        
        if (base >= _deltaX)
        {
            base = _deltaX - 1.0;
        }

        var xIndex = Int(base);

        // check if we are more than half of a x-value or not
        if (xTouchVal - base > 0.5)
        {
            xIndex = Int(base + 1.0);
        }

        var valsAtIndex = getYValsAtIndex(xIndex);

        var leftdist = ChartUtils.getMinimumDistance(valsAtIndex, val: Float(pt.y), axis: .Left);
        var rightdist = ChartUtils.getMinimumDistance(valsAtIndex, val: Float(pt.y), axis: .Right);

        if (_data!.getFirstRight() === nil)
        {
            rightdist = FLT_MAX;
        }
        if (_data!.getFirstLeft() === nil)
        {
            leftdist = FLT_MAX;
        }

        var axis: ChartYAxis.AxisDependency = leftdist < rightdist ? .Left : .Right;

        var dataSetIndex = ChartUtils.closestDataSetIndex(valsAtIndex, value: Float(pt.y), axis: axis);

        if (dataSetIndex == -1)
        {
            return nil;
        }

        return ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex);
    }

    /// Returns an array of SelInfo objects for the given x-index. The SelInfo
    /// objects give information about the value at the selected index and the
    /// DataSet it belongs to. 
    public func getYValsAtIndex(xIndex: Int) -> [ChartSelInfo]
    {
        var vals = [ChartSelInfo]();

        var pt = CGPoint();

        for (var i = 0, count = _data.dataSetCount; i < count; i++)
        {
            var dataSet = _data.getDataSetByIndex(i);
            if (dataSet === nil)
            {
                continue;
            }

            // extract all y-values from all DataSets at the given x-index
            var yVal = dataSet!.yValForXIndex(xIndex);
            pt.y = CGFloat(yVal);

            getTransformer(dataSet!.axisDependency).pointValueToPixel(&pt);

            if (!isnan(pt.y))
            {
                vals.append(ChartSelInfo(value: Float(pt.y), dataSetIndex: i, dataSet: dataSet!));
            }
        }

        return vals;
    }

    /// Returns the x and y values in the chart at the given touch point
    /// (encapsulated in a PointD). This method transforms pixel coordinates to
    /// coordinates / values in the chart. This is the opposite method to
    /// getPixelsForValues(...).
    public func getValueByTouchPoint(var #pt: CGPoint, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        getTransformer(axis).pixelToValue(&pt);

        return pt;
    }

    /// Transforms the given chart values into pixels. This is the opposite
    /// method to getValueByTouchPoint(...).
    public func getPixelForValue(x: Float, y: Float, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var pt = CGPoint(x: CGFloat(x), y: CGFloat(y));
        
        getTransformer(axis).pointValueToPixel(&pt);
        
        return pt;
    }

    /// returns the y-value at the given touch position (must not necessarily be
    /// a value contained in one of the datasets)
    public func getYValueByTouchPoint(#pt: CGPoint, axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        return getValueByTouchPoint(pt: pt, axis: axis).y;
    }
    
    /// returns the Entry object displayed at the touched position of the chart
    public func getEntryByTouchPoint(pt: CGPoint) -> ChartDataEntry!
    {
        var h = getHighlightByTouchPoint(pt);
        if (h !== nil)
        {
            return _data!.getEntryForHighlight(h!);
        }
        return nil;
    }
    
    ///returns the DataSet object displayed at the touched position of the chart
    public func getDataSetByTouchPoint(pt: CGPoint) -> BarLineScatterCandleChartDataSet!
    {
        var h = getHighlightByTouchPoint(pt);
        if (h !== nil)
        {
            return _data.getDataSetByIndex(h.dataSetIndex) as BarLineScatterCandleChartDataSet!;
        }
        return nil;
    }
    
    /// Returns the lowest x-index (value on the x-axis) that is still visible on he chart.
    public var lowestVisibleXIndex: Int
    {
        var pt = CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom);
        getTransformer(.Left).pixelToValue(&pt);
        return (pt.x <= 0.0) ? 0 : Int(pt.x + 1.0);
    }

    /// Returns the highest x-index (value on the x-axis) that is still visible on the chart.
    public var highestVisibleXIndex: Int
    {
        var pt = CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom);
        getTransformer(.Left).pixelToValue(&pt);
        return (Int(pt.x) >= _data.xValCount) ? _data.xValCount - 1 : Int(pt.x);
    }

    /// returns the current x-scale factor
    public var scaleX: CGFloat { return _viewPortHandler.scaleX; }

    /// returns the current y-scale factor
    public var scaleY: CGFloat { return _viewPortHandler.scaleY; }

    /// if the chart is fully zoomed out, return true
    public var isFullyZoomedOut: Bool { return _viewPortHandler.isFullyZoomedOut; }

    /// Returns the left y-axis object. In the horizontal bar-chart, this is the
    /// top axis.
    public var leftAxis: ChartYAxis
    {
        return _leftAxis;
    }

    /// Returns the right y-axis object. In the horizontal bar-chart, this is the
    /// bottom axis.
    public var rightAxis: ChartYAxis { return _rightAxis; }

    /// Returns the y-axis object to the corresponding AxisDependency. In the
    /// horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
    public func getAxis(axis: ChartYAxis.AxisDependency) -> ChartYAxis
    {
        if (axis == .Left)
        {
            return _leftAxis;
        }
        else
        {
            return _rightAxis;
        }
    }

    /// Returns the object representing all x-labels, this method can be used to
    /// acquire the XAxis object and modify it (e.g. change the position of the
    /// labels)
    public var xAxis: ChartXAxis
    {
        return _xAxis;
    }
    
    /// flag that indicates if pinch-zoom is enabled. if true, both x and y axis can be scaled with 2 fingers, if false, x and y axis can be scaled separately
    public var pinchZoomEnabled: Bool
    {
        get
        {
            return _pinchZoomEnabled;
        }
        set
        {
            if (_pinchZoomEnabled != newValue)
            {
                _pinchZoomEnabled = newValue;
                updateScaleGestureRecognizers();
            }
        }
    }
    
    private func updateScaleGestureRecognizers()
    {
        if (self.gestureRecognizers != nil)
        {
            for (var i = 0; i < self.gestureRecognizers!.count; i++)
            {
                if (self.gestureRecognizers![i] === _pinchGestureRecognizer)
                {
                    self.gestureRecognizers!.removeAtIndex(i);
                    break;
                }
            }
        }
        
        if (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled)
        {
            self.addGestureRecognizer(_pinchGestureRecognizer);
        }
    }

    /// returns true if pinch-zoom is enabled, false if not
    /// :default: false
    public var isPinchZoomEnabled: Bool { return pinchZoomEnabled; }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the x-axis.
    public func setDragOffsetX(offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetX(offset);
    }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the y-axis.
    public func setDragOffsetY(offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetY(offset);
    }

    /// :returns: true if both drag offsets (x and y) are zero or smaller.
    public var hasNoDragOffset: Bool { return _viewPortHandler.hasNoDragOffset; }

    public var xAxisRenderer: ChartXAxisRenderer { return _xAxisRenderer; }
    
    public var leftYAxisRenderer: ChartYAxisRenderer { return _leftYAxisRenderer; }

    public var rightYAxisRenderer: ChartYAxisRenderer { return _rightYAxisRenderer; }
    
    public override var chartYMax: Float
    {
        return max(leftAxis.axisMaximum, rightAxis.axisMaximum);
    }

    public override var chartYMin: Float
    {
        return min(leftAxis.axisMinimum, rightAxis.axisMinimum);
    }
    
    /// Returns true if either the left or the right or both axes are inverted.
    public var isAnyAxisInverted: Bool
    {
        return _leftAxis.isInverted || _rightAxis.isInverted;
    }
}

/// Default formatter that calculates the position of the filled line.
internal class BarLineChartFillFormatter: NSObject, ChartFillFormatter
{
    private weak var _chart: BarLineChartViewBase!;
    
    internal init(chart: BarLineChartViewBase)
    {
        _chart = chart;
    }
    
    internal func getFillLinePosition(#dataSet: LineChartDataSet, data: LineChartData, chartMaxY: Float, chartMinY: Float) -> CGFloat
    {
        var fillMin = CGFloat(0.0);
        
        if (dataSet.yMax > 0.0 && dataSet.yMin < 0.0)
        {
            fillMin = 0.0;
        }
        else
        {
            if (!_chart.getAxis(dataSet.axisDependency).isStartAtZeroEnabled)
            {
                var max: Float, min: Float;
                
                if (data.yMax > 0.0)
                {
                    max = 0.0;
                }
                else
                {
                    max = chartMaxY;
                }
                
                if (data.yMin < 0.0)
                {
                    min = 0.0;
                }
                else
                {
                    min = chartMinY;
                }
                
                fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max);
            }
            else
            {
                fillMin = 0.0;
            }
        }
        
        return fillMin;
    }
}