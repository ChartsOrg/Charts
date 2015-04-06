//
//  ChartYAxisRendererHorizontalBarChart.swift
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

public class ChartYAxisRendererHorizontalBarChart: ChartYAxisRenderer
{
    public override init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer);
    }

    /// Computes the axis values.
    public override func computeAxis(var #yMin: Float, var yMax: Float)
    {
        // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
        if (viewPortHandler.contentHeight > 10.0 && !viewPortHandler.isFullyZoomedOutX)
        {
            var p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop));
            var p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop));
            
            if (!_yAxis.isInverted)
            {
                yMin = Float(p1.x);
                yMax = Float(p2.x);
            }
            else
            {
                yMin = Float(p2.x);
                yMax = Float(p1.x);
            }
        }
        
        computeAxisValues(min: yMin, max: yMax);
    }

    /// draws the y-axis labels to the screen
    public override func renderAxisLabels(#context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawLabelsEnabled)
        {
            return;
        }
        
        var positions = [CGPoint]();
        positions.reserveCapacity(_yAxis.entries.count);
        
        for (var i = 0; i < _yAxis.entries.count; i++)
        {
            positions.append(CGPoint(x: CGFloat(_yAxis.entries[i]), y: 0.0))
        }
        
        transformer.pointValuesToPixel(&positions);
        
        var lineHeight = _yAxis.labelFont.lineHeight;
        var yoffset = lineHeight + _yAxis.yOffset;
        
        var dependency = _yAxis.axisDependency;
        var labelPosition = _yAxis.labelPosition;
        
        var yPos: CGFloat = 0.0;
        
        if (dependency == .Left)
        {
            if (labelPosition == .OutsideChart)
            {
                yoffset = 3.0;
                yPos = viewPortHandler.contentTop;
            }
            else
            {
                yoffset = yoffset * -1;
                yPos = viewPortHandler.contentTop;
            }
        }
        else
        {
            if (labelPosition == .OutsideChart)
            {
                yoffset = yoffset * -1.0;
                yPos = viewPortHandler.contentBottom;
            }
            else
            {
                yoffset = 4.0;
                yPos = viewPortHandler.contentBottom;
            }
        }
        
        yPos -= lineHeight;
        
        drawYLabels(context: context, fixedPosition: yPos, positions: positions, offset: yoffset);
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    internal override func renderAxisLine(#context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.drawAxisLineEnabled)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, _yAxis.axisLineColor.CGColor);
        CGContextSetLineWidth(context, _yAxis.axisLineWidth);
        if (_yAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _yAxis.axisLineDashPhase, _yAxis.axisLineDashLengths, UInt(_yAxis.axisLineDashLengths.count));
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }

        if (_yAxis.axisDependency == .Left)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft;
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom;
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight;
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom;
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2);
        }
        
        CGContextRestoreGState(context);
    }

    /// draws the y-labels on the specified x-position
    internal func drawYLabels(#context: CGContext, fixedPosition: CGFloat, positions: [CGPoint], offset: CGFloat)
    {
        var labelFont = _yAxis.labelFont;
        var labelTextColor = _yAxis.labelTextColor;
        
        for (var i = 0; i < _yAxis.entryCount; i++)
        {
            var text = _yAxis.getFormattedLabel(i);
            
            if (!_yAxis.isDrawTopYLabelEntryEnabled && i >= _yAxis.entryCount - 1)
            {
                return;
            }
            
            ChartUtils.drawText(context: context, text: text, point: CGPoint(x: positions[i].x, y: fixedPosition - offset), align: .Center, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor]);
        }
    }

    public override func renderGridLines(#context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawGridLinesEnabled)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        // pre alloc
        var position = CGPoint();
        
        CGContextSetStrokeColorWithColor(context, _yAxis.gridColor.CGColor);
        CGContextSetLineWidth(context, _yAxis.gridLineWidth);
        if (_yAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _yAxis.gridLineDashPhase, _yAxis.gridLineDashLengths, UInt(_yAxis.gridLineDashLengths.count));
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }
        
        // draw the horizontal grid
        for (var i = 0; i < _yAxis.entryCount; i++)
        {
            position.x = CGFloat(_yAxis.entries[i]);
            position.y = 0.0;
            transformer.pointValueToPixel(&position);
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, position.x, viewPortHandler.contentTop);
            CGContextAddLineToPoint(context, position.x, viewPortHandler.contentBottom);
            CGContextStrokePath(context);
        }
        
        CGContextRestoreGState(context);
    }
    
    /// Draws the LimitLines associated with this axis to the screen.
    public override func renderLimitLines(#context: CGContext)
    {
        var limitLines = _yAxis.limitLines;

        if (limitLines.count <= 0)
        {
            return;
        }

        var pts = [CGPoint](count: 2, repeatedValue: CGPoint());
        var limitLinePath = CGPathCreateMutable();
        
        CGContextSaveGState(context);
        
        for (var i = 0; i < limitLines.count; i++)
        {
            var l = limitLines[i];
            
            pts[0].x = CGFloat(l.limit);
            pts[1].x = CGFloat(l.limit);

            transformer.pointValuesToPixel(&pts);

            pts[0].y = viewPortHandler.contentTop;
            pts[1].y = viewPortHandler.contentBottom;
            
            CGContextSetStrokeColorWithColor(context, l.lineColor.CGColor);
            CGContextSetLineWidth(context, l.lineWidth);
            if (l.lineDashLengths != nil)
            {
                CGContextSetLineDash(context, l.lineDashPhase, l.lineDashLengths!, UInt(l.lineDashLengths!.count));
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0);
            }
            
            CGContextStrokeLineSegments(context, pts, 2);

            var label = l.label;

            // if drawing the limit-value label is enabled
            if (label.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) > 0)
            {
                var xOffset = l.lineWidth;
                var add: CGFloat = 4.0;
                
                var valueFont = l.valueFont;
                var yOffset = valueFont.lineHeight + add / 2.0;

                if (l.labelPosition == .Right)
                {
                    ChartUtils.drawText(context: context, text: label, point: CGPoint(x: pts[0].x + xOffset - valueFont.lineHeight, y: viewPortHandler.contentBottom - add), align: .Left, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: l.valueTextColor]);
                }
                else
                {
                    ChartUtils.drawText(context: context, text: label, point: CGPoint(x: pts[0].x + xOffset - valueFont.lineHeight, y: viewPortHandler.contentTop + yOffset), align: .Left, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: l.valueTextColor]);
                }
            }
        }
        
        CGContextRestoreGState(context);
    }
}