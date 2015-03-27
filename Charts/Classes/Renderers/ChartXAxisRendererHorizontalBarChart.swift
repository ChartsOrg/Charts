//
//  ChartXAxisRendererHorizontalBarChart.swift
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

public class ChartXAxisRendererHorizontalBarChart: ChartXAxisRendererBarChart
{
    public override init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer, chart: chart);
    }
    
    public override func computeAxis(#xValAverageLength: Float, xValues: [String])
    {
        _xAxis.values = xValues;
       
        var longest = _xAxis.getLongestLabel() as NSString;
        var longestSize = longest.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]);
        _xAxis.labelWidth = floor(longestSize.width + _xAxis.xOffset * 3.5);
        _xAxis.labelHeight = longestSize.height;
    }

    public override func renderAxisLabels(#context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled || _chart.data === nil)
        {
            return;
        }
        
        var xoffset = _xAxis.xOffset;
        
        if (_xAxis.labelPosition == .Top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, align: .Left);
        }
        else if (_xAxis.labelPosition == .Bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, align: .Right);
        }
        else if (_xAxis.labelPosition == .BottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, align: .Left);
        }
        else if (_xAxis.labelPosition == .TopInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, align: .Right);
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentLeft, align: .Left);
            drawLabels(context: context, pos: viewPortHandler.contentRight, align: .Left);
        }
    }

    /// draws the x-labels on the specified y-position
    internal func drawLabels(#context: CGContext, pos: CGFloat, align: NSTextAlignment)
    {
        var labelFont = _xAxis.labelFont;
        var labelTextColor = _xAxis.labelTextColor;
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0);
        
        var bd = _chart.data as! BarChartData;
        var step = bd.dataSetCount;
        
        for (var i = 0; i < _xAxis.values.count; i += _xAxis.axisLabelModulus)
        {
            position.x = 0.0;
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace + bd.groupSpace / 2.0;
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.y += (CGFloat(step) - 1.0) / 2.0;
            }
            
            transformer.pointValueToPixel(&position);
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                var label = _xAxis.values[i];
                
                ChartUtils.drawText(context: context, text: label, point: CGPoint(x: pos, y: position.y - _xAxis.labelHeight / 2.0), align: align, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor]);
            }
        }
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    public override func renderGridLines(#context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawGridLinesEnabled || _chart.data === nil)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, _xAxis.gridColor.CGColor);
        CGContextSetLineWidth(context, _xAxis.gridLineWidth);
        if (_xAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _xAxis.gridLineDashPhase, _xAxis.gridLineDashLengths, _xAxis.gridLineDashLengths.count);
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }
        
        var position = CGPoint(x: 0.0, y: 0.0);
        
        var bd = _chart.data as! BarChartData;
        
        // take into consideration that multiple DataSets increase _deltaX
        var step = bd.dataSetCount;
        
        for (var i = 0; i < _xAxis.values.count; i += _xAxis.axisLabelModulus)
        {
            position.x = 0.0;
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace - 0.5;
            
            transformer.pointValueToPixel(&position);
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                _gridLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
                _gridLineSegmentsBuffer[0].y = position.y;
                _gridLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
                _gridLineSegmentsBuffer[1].y = position.y;
                CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2);
            }
        }
        
        CGContextRestoreGState(context);
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
            CGContextSetLineDash(context, _xAxis.axisLineDashPhase, _xAxis.axisLineDashLengths, _xAxis.axisLineDashLengths.count);
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }
        
        if (_xAxis.labelPosition == .Top
            || _xAxis.labelPosition == .TopInside
            || _xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }
        
        if (_xAxis.labelPosition == .Bottom
            || _xAxis.labelPosition == .BottomInside
            || _xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }
        
        CGContextRestoreGState(context);
    }
}