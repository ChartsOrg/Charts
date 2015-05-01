//
//  BubbleChartRenderer.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

@objc
public protocol BubbleChartRendererDelegate
{
    func bubbleChartRendererData(renderer: BubbleChartRenderer) -> BubbleChartData!;
    func bubbleChartRenderer(renderer: BubbleChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!;
    func bubbleChartDefaultRendererValueFormatter(renderer: BubbleChartRenderer) -> NSNumberFormatter!;
    func bubbleChartRendererMaxVisibleValueCount(renderer: BubbleChartRenderer) -> Int;
}

public class BubbleChartRenderer: ChartDataRendererBase
{
    public weak var delegate: BubbleChartRendererDelegate?;
    
    public init(delegate: BubbleChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler);
        
        self.delegate = delegate;
    }
    
    public override func drawData(#context: CGContext)
    {
        let bubbleData = delegate!.bubbleChartRendererData(self);
        
        for set in bubbleData.dataSets as! [BubbleChartDataSet]
        {
            if (set.isVisible)
            {
                drawDataSet(context: context, dataSet: set);
            }
        }
    }
    
    internal func drawDataSet(#context: CGContext, dataSet: BubbleChartDataSet)
    {
        let trans = delegate!.bubbleChartRenderer(self, transformerForAxis: dataSet.axisDependency);
        
        let bubbleData = delegate!.bubbleChartRendererData(self);

        let phaseX = _animator.phaseX;
        let phaseY = _animator.phaseY;
        
        let entries = dataSet.yVals as! [BubbleChartDataEntry];
        
        let valueToPixelMatrix = trans.valueToPixelMatrix;
        
        CGContextSaveGState(context);
        
        var entryFrom = dataSet.entryForXIndex(_minX);
        var entryTo = dataSet.entryForXIndex(_maxX);
        
        var minx = max(dataSet.entryIndex(entry: entryFrom, isEqual: true), 0);
        var maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, entries.count);
        
        let chartSize: CGFloat = (self.viewPortHandler.contentWidth * self.viewPortHandler.scaleX) <= (self.viewPortHandler.contentHeight * self.viewPortHandler.scaleY) ?
            self.viewPortHandler.contentWidth * self.viewPortHandler.scaleX :
            self.viewPortHandler.contentHeight * self.viewPortHandler.scaleY;
        
        let bubbleSizeFactor: CGFloat = CGFloat(bubbleData.xVals.count > 0 ? bubbleData.xVals.count : 1);
        
        for (var j = minx; j < maxx; j++)
        {
            var entry = entries[j];
            
            let rawPoint = CGPoint(x: CGFloat(entry.xIndex - minx) * phaseX + CGFloat(minx), y: CGFloat(entry.value) * phaseY);
            let point = CGPointApplyAffineTransform(rawPoint, valueToPixelMatrix);
            
            let shapeSize = (chartSize / bubbleSizeFactor) * CGFloat(sqrt(entry.size / (dataSet.maxSize != 0.0 ? dataSet.maxSize : 1.0)))
            let shapeHalf = shapeSize / 2.0
            
            if (!viewPortHandler.isInBoundsY(point.y))
            {
                continue;
            }
            
            let color = dataSet.colorAt(entry.xIndex);
            
            let rect = CGRect(x: point.x - shapeHalf, y: point.y - shapeHalf, width: shapeSize, height: shapeSize);

            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillEllipseInRect(context, rect);
        }
        
        CGContextRestoreGState(context);
    }
    
    public override func drawValues(#context: CGContext)
    {
        let bubbleData = delegate!.bubbleChartRendererData(self);
        if (bubbleData === nil)
        {
            return;
        }
        
        let defaultValueFormatter = delegate!.bubbleChartDefaultRendererValueFormatter(self);
        
        // if values are drawn
        if (bubbleData.yValCount < Int(ceil(CGFloat(delegate!.bubbleChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)))
        {
            let dataSets = bubbleData.dataSets as! [BubbleChartDataSet];
            
            for dataSet in dataSets
            {
                if (!dataSet.isDrawValuesEnabled)
                {
                    continue;
                }
                
                let phaseX = _animator.phaseX;
                let phaseY = _animator.phaseY;
                
                let alpha = phaseX == 1 ? phaseY : phaseX
                let valueTextColor = dataSet.valueTextColor.colorWithAlphaComponent(alpha);
                
                let formatter = dataSet.valueFormatter === nil ? defaultValueFormatter : dataSet.valueFormatter;
                
                let entries = dataSet.yVals;
                
                var entryFrom = dataSet.entryForXIndex(_minX);
                var entryTo = dataSet.entryForXIndex(_maxX);
                
                var minx = max(dataSet.entryIndex(entry: entryFrom, isEqual: true), 0);
                var maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, entries.count);
                
                let positions = delegate!.bubbleChartRenderer(self, transformerForAxis: dataSet.axisDependency).generateTransformedValuesBubble(entries, phaseX: phaseX, phaseY: phaseY, from: minx, to: maxx);
                
                for (var j = 0, count = positions.count; j < count; j++)
                {
                    if (!viewPortHandler.isInBoundsRight(positions[j].x))
                    {
                        break;
                    }
                    
                    if ((!viewPortHandler.isInBoundsLeft(positions[j].x) || !viewPortHandler.isInBoundsY(positions[j].y)))
                    {
                        continue;
                    }
                    
                    let entry = entries[j + minx] as! BubbleChartDataEntry
                    
                    let val = entry.size;
                    
                    let text = formatter!.stringFromNumber(val);
                    
                    // Larger font for larger bubbles?
                    let valueFont = dataSet.valueFont;
                    let lineHeight = valueFont.lineHeight;

                    ChartUtils.drawText(context: context, text: text!, point: CGPoint(x: positions[j].x, y: positions[j].y - ( 0.5 * lineHeight)), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor]);
                }
            }
        }
    }
    
    public override func drawExtras(#context: CGContext)
    {
        
    }
    
    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        let bubbleData = delegate!.bubbleChartRendererData(self);
        
        CGContextSaveGState(context);
        
        let phaseX = _animator.phaseX;
        let phaseY = _animator.phaseY;
        
        let chartSize: CGFloat = (self.viewPortHandler.contentWidth * self.viewPortHandler.scaleX) <= (self.viewPortHandler.contentHeight * self.viewPortHandler.scaleY) ?
            self.viewPortHandler.contentWidth * self.viewPortHandler.scaleX :
            self.viewPortHandler.contentHeight * self.viewPortHandler.scaleY;
        
        let bubbleSizeFactor: CGFloat = CGFloat(bubbleData.xVals.count > 0 ? bubbleData.xVals.count : 1);
        
        for indice in indices
        {
            let dataSet = bubbleData.getDataSetByIndex(indice.dataSetIndex) as! BubbleChartDataSet!;
            
            if (dataSet === nil)
            {
                continue
            }
            
            var entryFrom = dataSet.entryForXIndex(_minX);
            var entryTo = dataSet.entryForXIndex(_maxX);
            
            var minx = max(dataSet.entryIndex(entry: entryFrom, isEqual: true), 0);
            var maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, dataSet.entryCount);
            
            let entry = bubbleData.getEntryForHighlight(indice) as! BubbleChartDataEntry
            
            let trans = delegate!.bubbleChartRenderer(self, transformerForAxis: dataSet.axisDependency);

            let valueToPixelMatrix = trans.valueToPixelMatrix;
            
            let rawPoint = CGPoint(x: CGFloat(entry.xIndex - minx) * phaseX + CGFloat(minx), y: CGFloat(entry.value) * phaseY);
            let point = CGPointApplyAffineTransform(rawPoint, valueToPixelMatrix)
            
            let shapeSize = (chartSize / bubbleSizeFactor) * CGFloat(sqrt(entry.size / (dataSet.maxSize != 0.0 ? dataSet.maxSize : 1.0)))
            let shapeHalf = shapeSize / 2.0
            
            if (indice.xIndex < minx || indice.xIndex >= maxx)
            {
                continue;
            }
            
            if (!viewPortHandler.isInBoundsY(point.y))
            {
                continue;
            }
            
            let originalColor = dataSet.colorAt(entry.xIndex)
            
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            
            originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            
            let color = UIColor(hue: h, saturation: s, brightness: b * 0.5, alpha: a)
            let rect = CGRect(x: point.x - shapeHalf, y: point.y - shapeHalf, width: shapeSize, height: shapeSize)

            CGContextSetLineWidth(context, dataSet.highlightCircleWidth)
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextStrokeEllipseInRect(context, rect)
        }
        
        CGContextRestoreGState(context);
    }
}