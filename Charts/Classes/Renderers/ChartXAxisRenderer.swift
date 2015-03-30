//
//  ChartXAxisRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class ChartXAxisRenderer: ChartAxisRendererBase
{
    internal var _xAxis: ChartXAxis!;
  
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer);
        
        _xAxis = xAxis;
    }
    
    public func computeAxis(#xValAverageLength: Float, xValues: [String])
    {
        var a = "";
        
        var max = Int(round(xValAverageLength + Float(_xAxis.spaceBetweenLabels)));
        
        for (var i = 0; i < max; i++)
        {
            a += "h";
        }
        
        var widthText = a as NSString;
        var heightText = "Q" as NSString;
        
        _xAxis.labelWidth = widthText.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]).width;
        _xAxis.labelHeight = _xAxis.labelFont.lineHeight;
        _xAxis.values = xValues;
    }
    
    public override func renderAxisLabels(#context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled)
        {
            return;
        }
        
        var yoffset = CGFloat(4.0);
        
        if (_xAxis.labelPosition == .Top)
        {
            drawLabels(context: context, pos: viewPortHandler.offsetTop - _xAxis.labelHeight - yoffset);
        }
        else if (_xAxis.labelPosition == .Bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yoffset * 1.5);
        }
        else if (_xAxis.labelPosition == .BottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - _xAxis.labelHeight - yoffset);
        }
        else if (_xAxis.labelPosition == .TopInside)
        {
            drawLabels(context: context, pos: viewPortHandler.offsetTop + yoffset);
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.offsetTop - _xAxis.labelHeight - yoffset);
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yoffset * 1.6);
        }
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    internal override func renderAxisLine(#context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawAxisLineEnabled)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, _xAxis.axisLineColor.CGColor);
        CGContextSetLineWidth(context, _xAxis.axisLineWidth);
        if (_xAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _xAxis.axisLineDashPhase, _xAxis.axisLineDashLengths, UInt(_xAxis.axisLineDashLengths.count));
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }

        if (_xAxis.labelPosition == .Top
                || _xAxis.labelPosition == .TopInside
                || _xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }

        if (_xAxis.labelPosition == .Bottom
                || _xAxis.labelPosition == .BottomInside
                || _xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }
        
        CGContextRestoreGState(context);
    }
    
    /// draws the x-labels on the specified y-position
    internal func drawLabels(#context: CGContext, pos: CGFloat)
    {
        var labelFont = _xAxis.labelFont;
        var labelTextColor = _xAxis.labelTextColor;
        
        var valueToPixelMatrix = transformer.valueToPixelMatrix;
        
        var position = CGPoint(x: 0.0, y: 0.0);
        
        var maxx = self._maxX;
        var minx = self._minX;
        
        if (maxx >= _xAxis.values.count)
        {
            maxx = _xAxis.values.count - 1;
        }
        if (minx < 0)
        {
            minx = 0;
        }
        
        for (var i = minx; i <= maxx; i += _xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i);
            position.y = 0.0;
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix);
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                var label = _xAxis.values[i];
                var labelns = label as NSString;
                
                if (_xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == _xAxis.values.count - 1 && _xAxis.values.count > 1)
                    {
                        
                        var width = labelns.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]).width;
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0;
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        var width = labelns.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]).width;
                        position.x += width / 2.0;
                    }
                }
                
                ChartUtils.drawText(context: context, text: label, point: CGPoint(x: position.x, y: pos), align: .Center, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor]);
            }
        }
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    public override func renderGridLines(#context: CGContext)
    {
        if (!_xAxis.isDrawGridLinesEnabled || !_xAxis.isEnabled)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, _xAxis.gridColor.CGColor);
        CGContextSetLineWidth(context, _xAxis.gridLineWidth);
        if (_xAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _xAxis.gridLineDashPhase, _xAxis.gridLineDashLengths, UInt(_xAxis.gridLineDashLengths.count));
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }
        
        var valueToPixelMatrix = transformer.valueToPixelMatrix;
        
        var position = CGPoint(x: 0.0, y: 0.0);
        
        for (var i = _minX; i <= _maxX; i += _xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i);
            position.y = 0.0;
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix);
            
            if (position.x >= viewPortHandler.offsetLeft
                && position.x <= viewPortHandler.chartWidth)
            {
                _gridLineSegmentsBuffer[0].x = position.x;
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop;
                _gridLineSegmentsBuffer[1].x = position.x;
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom;
                CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2);
            }
        }
        
        CGContextRestoreGState(context);
    }
}