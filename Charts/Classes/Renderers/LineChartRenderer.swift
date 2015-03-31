//
//  LineChartRenderer.swift
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

//@objc
public protocol LineChartRendererDelegate
{
    func lineChartRendererData(renderer: LineChartRenderer) -> LineChartData!;
    func lineChartRenderer(renderer: LineChartRenderer, transformerForAxis which: AxisDependency) -> ChartTransformer!;
    func lineChartRendererFillFormatter(renderer: LineChartRenderer) -> ChartFillFormatter;
    func lineChartDefaultRendererValueFormatter(renderer: LineChartRenderer) -> NSNumberFormatter!;
    func lineChartRendererChartYMax(renderer: LineChartRenderer) -> Float;
    func lineChartRendererChartYMin(renderer: LineChartRenderer) -> Float;
    func lineChartRendererChartXMax(renderer: LineChartRenderer) -> Float;
    func lineChartRendererChartXMin(renderer: LineChartRenderer) -> Float;
    func lineChartRendererMaxVisibleValueCount(renderer: LineChartRenderer) -> Int;
}

public class LineChartRenderer: ChartDataRendererBase
{
    public var delegate: LineChartRendererDelegate?;
    
    public init(delegate: LineChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler);
        
        self.delegate = delegate;
    }
    
    public override func drawData(#context: CGContext)
    {
        var lineData = delegate!.lineChartRendererData(self);
        
        if (lineData === nil)
        {
            return;
        }
        
        for (var i = 0; i < lineData.dataSetCount; i++)
        {
            var set = lineData.getDataSetByIndex(i);
            
            if (set !== nil && set!.isVisible)
            {
                drawDataSet(context: context, dataSet: set as LineChartDataSet);
            }
        }
    }
    
    internal struct CGCPoint
    {
        internal var x: CGFloat = 0.0;
        internal var y: CGFloat = 0.0;
        
        ///  x-axis distance
        internal var dx: CGFloat = 0.0;
        ///  y-axis distance
        internal var dy: CGFloat = 0.0;
        
        internal init(x: CGFloat, y: CGFloat)
        {
            self.x = x;
            self.y = y;
        }
    }
    
    internal func drawDataSet(#context: CGContext, dataSet: LineChartDataSet)
    {
        var lineData = delegate!.lineChartRendererData(self);
        
        var entries = dataSet.yVals;
        
        if (entries.count < 1)
        {
            return;
        }
        
        calcXBounds(delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency));
        
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, dataSet.lineWidth);
        if (dataSet.lineDashLengths != nil)
        {
            CGContextSetLineDash(context, dataSet.lineDashPhase, dataSet.lineDashLengths, UInt(dataSet.lineDashLengths.count));
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0);
        }
        
        // if drawing cubic lines is enabled
        if (dataSet.isDrawCubicEnabled)
        {
            drawCubic(context: context, dataSet: dataSet, entries: entries);
        }
        else
        { // draw normal (straight) lines
            drawLinear(context: context, dataSet: dataSet, entries: entries);
        }
        
        CGContextRestoreGState(context);
    }
    
    internal func drawCubic(#context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry])
    {
        var trans = delegate?.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency);
        
        var minx = _minX;
        var maxx = _maxX + 2;
        
        if (maxx > entries.count)
        {
            maxx = entries.count;
        }
        
        var phaseX = _animator.phaseX;
        var phaseY = _animator.phaseY;
        
        // get the color that is specified for this position from the DataSet
        var drawingColor = dataSet.colors.first!;
        
        var intensity = dataSet.cubicIntensity;
        
        // the path for the cubic-spline
        var cubicPath = CGPathCreateMutable();
        
        var valueToPixelMatrix = trans!.valueToPixelMatrix;
        
        var size = Int(ceil(CGFloat(entries.count) * phaseX));
        
        if (entries.count > 2)
        {
            var prevDx: CGFloat = 0.0;
            var prevDy: CGFloat = 0.0;
            var curDx: CGFloat = 0.0;
            var curDy: CGFloat = 0.0;
            
            var cur = entries[0];
            var next = entries[1];
            var prev = entries[0];
            var prevPrev = entries[0];
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY);
            
            prevDx = CGFloat(next.xIndex - cur.xIndex) * intensity;
            prevDy = CGFloat(next.value - cur.value) * intensity;
            
            cur = entries[1];
            next = entries[2];
            curDx = CGFloat(next.xIndex - prev.xIndex) * intensity;
            curDy = CGFloat(next.value - prev.value) * intensity;
            
            // the first cubic
            CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY, CGFloat(cur.xIndex) - curDx, (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY);
            
            for (var j = 2; j < size - 1; j++)
            {
                prevPrev = entries[j - 2];
                prev = entries[j - 1];
                cur = entries[j];
                next = entries[j + 1];
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity;
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity;
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity;
                curDy = CGFloat(next.value - prev.value) * intensity;
                
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY);
            }
            
            if (size > entries.count - 1)
            {
                cur = entries[entries.count - 1];
                prev = entries[entries.count - 2];
                prevPrev = entries[entries.count - 3];
                next = cur;
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity;
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity;
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity;
                curDy = CGFloat(next.value - prev.value) * intensity;
                
                // the last cubic
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY);
            }
        }
        
        
        CGContextSaveGState(context);
        
        if (dataSet.isDrawFilledEnabled)
        {
            drawCubicFill(context: context, dataSet: dataSet, spline: cubicPath, matrix: valueToPixelMatrix);
        }
        
        CGContextBeginPath(context);
        CGContextAddPath(context, cubicPath);
        CGContextSetStrokeColorWithColor(context, drawingColor.CGColor);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
    
    internal func drawCubicFill(#context: CGContext, dataSet: LineChartDataSet, spline: CGMutablePath, var matrix: CGAffineTransform)
    {
        CGContextSaveGState(context);
        
        var fillMin = delegate!.lineChartRendererFillFormatter(self).getFillLinePosition(
            dataSet: dataSet,
            data: delegate!.lineChartRendererData(self),
            chartMaxY: delegate!.lineChartRendererChartYMax(self),
            chartMinY: delegate!.lineChartRendererChartYMin(self));
        
        var entryFrom = dataSet.entryForXIndex(_minX);
        var entryTo = dataSet.entryForXIndex(_maxX + 1);
        
        var pt1 = CGPoint(x: CGFloat(entryTo.xIndex), y: fillMin);
        var pt2 = CGPoint(x: CGFloat(entryFrom.xIndex), y: fillMin);
        pt1 = CGPointApplyAffineTransform(pt1, matrix);
        pt2 = CGPointApplyAffineTransform(pt2, matrix);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, spline);
        CGContextAddLineToPoint(context, pt1.x, pt1.y);
        CGContextAddLineToPoint(context, pt2.x, pt2.y);
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, dataSet.fillColor.CGColor);
        CGContextSetAlpha(context, dataSet.fillAlpha);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
    }
    
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    internal func drawLinear(#context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry])
    {
        var lineData = delegate!.lineChartRendererData(self);
        var dataSetIndex = lineData.indexOfDataSet(dataSet);

        var trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency);
        var valueToPixelMatrix = trans.valueToPixelMatrix;
        
        var phaseX = _animator.phaseX;
        var phaseY = _animator.phaseY;
        
        var pointBuffer = CGPoint();
        
        CGContextSaveGState(context);
        
        // more than 1 color
        if (dataSet.colors.count > 1)
        {
            for (var j = 0, count = Int(ceil(CGFloat(entries.count) * phaseX)); j < count; j++)
            {
                if (count > 1 && j == count - 1)
                { // Last point, we have already drawn a line to this point
                    break;
                }
                
                var e = entries[j];
                
                _lineSegments[0].x = CGFloat(e.xIndex);
                _lineSegments[0].y = CGFloat(e.value) * phaseY;
                _lineSegments[0] = CGPointApplyAffineTransform(_lineSegments[0], valueToPixelMatrix);
                if (j + 1 < count)
                {
                    e = entries[j + 1];
                    
                    _lineSegments[1].x = CGFloat(e.xIndex);
                    _lineSegments[1].y = CGFloat(e.value) * phaseY;
                    _lineSegments[1] = CGPointApplyAffineTransform(_lineSegments[1], valueToPixelMatrix);
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0];
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break;
                }
                
                // make sure the lines don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y)))
                {
                    continue;
                }
                
                // get the color that is set for this line-segment
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor);
                CGContextStrokeLineSegments(context, _lineSegments, 2);
            }
        }
        else
        { // only one color per dataset
            
            var entryFrom = dataSet.entryForXIndex(_minX);
            var entryTo = dataSet.entryForXIndex(_maxX);
            
            var minx = dataSet.entryIndex(entry: entryFrom, isEqual: true);
            var maxx = dataSet.entryIndex(entry: entryTo, isEqual: true);
            
            var point = CGPoint();
            point.x = CGFloat(entries[minx].xIndex);
            point.y = CGFloat(entries[minx].value) * phaseY;
            point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, point.x, point.y);
            
            // create a new path
            for (var x = minx + 1, count = Int(ceil(CGFloat(min(entries.count, maxx) + 1) * phaseX)); x < count; x++)
            {
                var e = entries[x];
                
                point.x = CGFloat(e.xIndex);
                point.y = CGFloat(e.value) * phaseY;
                point = CGPointApplyAffineTransform(point, valueToPixelMatrix)
                
                CGContextAddLineToPoint(context, point.x, point.y);
            }
            
            CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor);
            CGContextStrokePath(context);
        }
        
        CGContextRestoreGState(context);
        
        // if drawing filled is enabled
        if (dataSet.isDrawFilledEnabled && entries.count > 0)
        {
            drawLinearFill(context: context, dataSet: dataSet, entries: entries, trans: trans);
        }
    }
    
    internal func drawLinearFill(#context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry], trans: ChartTransformer)
    {
        var entryFrom = dataSet.entryForXIndex(_minX - 2);
        var entryTo = dataSet.entryForXIndex(_maxX + 2);
        
        var minx = dataSet.entryIndex(entry: entryFrom, isEqual: true);
        var maxx = dataSet.entryIndex(entry: entryTo, isEqual: true);
        
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, dataSet.fillColor.CGColor);
        
        // filled is usually drawn with less alpha
        CGContextSetAlpha(context, dataSet.fillAlpha);
        
        var filled = generateFilledPath(
            entries,
            fillMin: delegate!.lineChartRendererFillFormatter(self).getFillLinePosition(
                dataSet: dataSet,
                data: delegate!.lineChartRendererData(self),
                chartMaxY: delegate!.lineChartRendererChartYMax(self),
                chartMinY: delegate!.lineChartRendererChartYMin(self)),
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, filled);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
    }
    
    /// Generates the path that is used for filled drawing.
    private func generateFilledPath(entries: [ChartDataEntry], fillMin: CGFloat, from: Int, to: Int, var matrix: CGAffineTransform) -> CGPath
    {
        var point = CGPoint();
        
        var phaseX = _animator.phaseX;
        var phaseY = _animator.phaseY;
        
        var filled = CGPathCreateMutable();
        CGPathMoveToPoint(filled, &matrix, CGFloat(entries[from].xIndex), CGFloat(entries[from].value) * phaseY);
        
        // create a new path
        for (var x = from + 1, count = Int(ceil(CGFloat(to) * phaseX)); x <= count; x++)
        {
            var e = entries[x];
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY);
        }
        
        // close up
        CGPathAddLineToPoint(filled, &matrix, CGFloat(entries[Int(CGFloat(to) * phaseX)].xIndex), fillMin);
        CGPathAddLineToPoint(filled, &matrix, CGFloat(entries[from].xIndex), fillMin);
        CGPathCloseSubpath(filled);
        
        return filled;
    }
    
    public override func drawValues(#context: CGContext)
    {
        var lineData = delegate!.lineChartRendererData(self);
        if (lineData === nil)
        {
            return;
        }
        
        var defaultValueFormatter = delegate!.lineChartDefaultRendererValueFormatter(self);
        
        if (CGFloat(lineData.yValCount) < CGFloat(delegate!.lineChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)
        {
            var dataSets = lineData.dataSets;
            
            for (var i = 0; i < dataSets.count; i++)
            {
                var dataSet = dataSets[i] as LineChartDataSet;
                
                if (!dataSet.isDrawValuesEnabled)
                {
                    continue;
                }
                
                var valueFont = dataSet.valueFont;
                var valueTextColor = dataSet.valueTextColor;
                
                var formatter = dataSet.valueFormatter;
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter;
                }
                
                var trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency);
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75);
                
                if (!dataSet.isDrawCirclesEnabled)
                {
                    valOffset = valOffset / 2;
                }
                
                var entries = dataSet.yVals;
                
                var positions = trans.generateTransformedValuesLine(entries, phaseY: _animator.phaseY);
                
                for (var j = 0, count = Int(ceil(CGFloat(positions.count) * _animator.phaseX)); j < count; j++)
                {
                    if (!viewPortHandler.isInBoundsRight(positions[j].x))
                    {
                        break;
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(positions[j].x) || !viewPortHandler.isInBoundsY(positions[j].y))
                    {
                        continue;
                    }
                    
                    var val = entries[j].value;
                    
                    ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(val)!, point: CGPoint(x: positions[j].x, y: positions[j].y - CGFloat(valOffset) - valueFont.lineHeight), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor]);
                }
            }
        }
    }
    
    public override func drawExtras(#context: CGContext)
    {
        drawCircles(context: context);
    }
    
    private func drawCircles(#context: CGContext)
    {
        var phaseX = _animator.phaseX;
        var phaseY = _animator.phaseY;
        
        var lineData = delegate!.lineChartRendererData(self);
        
        var dataSets = lineData.dataSets;
        
        var pt = CGPoint();
        var rect = CGRect();
        
        CGContextSaveGState(context);
        
        for (var i = 0, count = dataSets.count; i < count; i++)
        {
            var dataSet = lineData.getDataSetByIndex(i) as LineChartDataSet!;
            
            if (!dataSet.isVisible || !dataSet.isDrawCirclesEnabled)
            {
                continue;
            }
            
            var trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency);
            var valueToPixelMatrix = trans.valueToPixelMatrix;
            
            var entries = dataSet.yVals;
            
            var circleRadius = dataSet.circleRadius;
            var circleDiameter = circleRadius * 2.0;
            var circleHoleDiameter = circleRadius;
            var circleHoleRadius = circleHoleDiameter / 2.0;
            var isDrawCircleHoleEnabled = dataSet.isDrawCircleHoleEnabled;
            
            for (var j = 0, count = Int(min(ceil(CGFloat(entries.count) * _animator.phaseX), CGFloat(entries.count))); j < count; j++)
            {
                var e = entries[j];
                pt.x = CGFloat(e.xIndex);
                pt.y = CGFloat(e.value) * phaseY;
                pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix);
                
                if (!viewPortHandler.isInBoundsRight(pt.x))
                {
                    break;
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                {
                    continue;
                }
                
                CGContextSetFillColorWithColor(context, dataSet.getCircleColor(j)!.CGColor);
                
                rect.origin.x = pt.x - circleRadius;
                rect.origin.y = pt.y - circleRadius;
                rect.size.width = circleDiameter;
                rect.size.height = circleDiameter;
                CGContextFillEllipseInRect(context, rect);
                
                if (isDrawCircleHoleEnabled)
                {
                    CGContextSetFillColorWithColor(context, dataSet.circleHoleColor.CGColor);
                    
                    rect.origin.x = pt.x - circleHoleRadius;
                    rect.origin.y = pt.y - circleHoleRadius;
                    rect.size.width = circleHoleDiameter;
                    rect.size.height = circleHoleDiameter;
                    CGContextFillEllipseInRect(context, rect);
                }
            }
        }
        
        CGContextRestoreGState(context);
    }
    
    var _highlightPtsBuffer = [CGPoint](count: 4, repeatedValue: CGPoint());
    
    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        var lineData = delegate!.lineChartRendererData(self);
        var chartXMax = delegate!.lineChartRendererChartXMax(self);
        var chartYMax = delegate!.lineChartRendererChartYMax(self);
        var chartYMin = delegate!.lineChartRendererChartYMin(self);
        
        CGContextSaveGState(context);
        
        for (var i = 0; i < indices.count; i++)
        {
            var set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as LineChartDataSet!;
            
            if (set === nil)
            {
                continue;
            }
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor);
            CGContextSetLineWidth(context, set.highlightLineWidth);
            if (set.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, UInt(set.highlightLineDashLengths!.count));
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0);
            }
            
            var xIndex = indices[i].xIndex; // get the x-position
            
            if (CGFloat(xIndex) > CGFloat(chartXMax) * _animator.phaseX)
            {
                continue;
            }
            
            var y = CGFloat(set.yValForXIndex(xIndex)) * _animator.phaseY; // get the y-position
            
            _highlightPtsBuffer[0] = CGPoint(x: CGFloat(xIndex), y: CGFloat(chartYMax));
            _highlightPtsBuffer[1] = CGPoint(x: CGFloat(xIndex), y: CGFloat(chartYMin));
            _highlightPtsBuffer[2] = CGPoint(x: 0.0, y: y);
            _highlightPtsBuffer[3] = CGPoint(x: CGFloat(chartXMax), y: y);
            
            var trans = delegate!.lineChartRenderer(self, transformerForAxis: set.axisDependency);
            
            trans.pointValuesToPixel(&_highlightPtsBuffer);
            
            // draw the highlight lines
            CGContextStrokeLineSegments(context, _highlightPtsBuffer, 4);
        }
        
        CGContextRestoreGState(context);
    }
}