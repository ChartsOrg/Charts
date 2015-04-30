//
//  ChartXAxisRendererBarChart.swift
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
import CoreGraphics.CGBase
import UIKit.UIFont

public class ChartXAxisRendererBarChart: ChartXAxisRenderer
{
    internal weak var _chart: BarChartView!;
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer);
        
        self._chart = chart;
    }
    
    /// draws the x-labels on the specified y-position
    internal override func drawLabels(#context: CGContext, pos: CGFloat)
    {
        if (_chart.data === nil)
        {
            return;
        }
        
        var labelFont = _xAxis.labelFont;
        var labelTextColor = _xAxis.labelTextColor;
        
        var barData = _chart.data as! BarChartData;
        var step = barData.dataSetCount;
        
        var trans = transformer.valueToPixelMatrix;
        
        var position = CGPoint(x: 0.0, y: 0.0);
        
        for (var i = _minX; i <= _maxX; i += _xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace + barData.groupSpace / 2.0;
            position.y = 0.0;
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.x += (CGFloat(step) - 1.0) / 2.0;
            }
            
            position = CGPointApplyAffineTransform(position, trans);
            
            if (viewPortHandler.isInBoundsX(position.x) && i >= 0 && i < _xAxis.values.count)
            {
                var label = _xAxis.values[i];
                var labelns = label as NSString;
                
                if (_xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == _xAxis.values.count - 1)
                    {
                        var width = label.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]).width;
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0;
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        var width = label.sizeWithAttributes([NSFontAttributeName: _xAxis.labelFont]).width;
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
        
        var barData = _chart.data as! BarChartData;
        var step = barData.dataSetCount;
        
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
        
        var trans = transformer.valueToPixelMatrix;
        
        var position = CGPoint(x: 0.0, y: 0.0);
        
        for (var i = _minX; i < _maxX; i += _xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace - 0.5;
            position.y = 0.0;
            position = CGPointApplyAffineTransform(position, trans);
            
            if (viewPortHandler.isInBoundsX(position.x))
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