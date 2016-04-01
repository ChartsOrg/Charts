//
//  PiePolylineChartRenderer.swift
//  Charts
//
//  Created by Jack Wang on 3/21/16.
//  Copyright © 2016 Jack Wang.
//  Licensed under Apache License 2.0
//

import UIKit

public class PiePolylineChartRenderer: PieChartRenderer {
    public var polylineColor: UIColor? = UIColor.blackColor()
    public var polylineWidth: CGFloat = 1.0
    public var polylineLengths: [CGFloat] = [0.1,0.2]
    public var enableAdjustPolylineWidth = true;
    
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            chart = chart,
            data = chart.data,
            animator = animator
            else { return }
        
        let center = chart.centerCircleBox
        
        // get whole the radius
        var r = chart.radius
        let rotationAngle = chart.rotationAngle
        var drawAngles = chart.drawAngles
        var absoluteAngles = chart.absoluteAngles
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        var off = r / 10.0 * 3.0
        
        if chart.drawHoleEnabled
        {
            off = (r - (r * chart.holeRadiusPercent)) / 2.0
        }
        
        r -= off; // offset to keep things inside the chart
        
        var dataSets = data.dataSets
        
        let yValueSum = (data as! PieChartData).yValueSum
        
        let drawXVals = chart.isDrawSliceTextEnabled
        let usePercentValuesEnabled = chart.usePercentValuesEnabled
        
        var angle: CGFloat = 0.0
        var xIndex = 0
        
        for (var i = 0; i < dataSets.count; i++)
        {
            guard let dataSet = dataSets[i] as? IPieChartDataSet else { continue }
            
            let drawYVals = dataSet.isDrawValuesEnabled
            
            if (!drawYVals && !drawXVals)
            {
                continue
            }
            
            let valueFont = dataSet.valueFont
            
            guard let formatter = dataSet.valueFormatter else { continue }
            
            for (var j = 0, entryCount = dataSet.entryCount; j < entryCount; j++)
            {
                if (drawXVals && !drawYVals && (j >= data.xValCount || data.xVals[j] == nil))
                {
                    continue
                }
                
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                if (xIndex == 0)
                {
                    angle = 0.0
                }
                else
                {
                    angle = absoluteAngles[xIndex - 1] * phaseX
                }
                
                let sliceAngle = drawAngles[xIndex]
                let sliceSpace = dataSet.sliceSpace
                let sliceSpaceMiddleAngle = sliceSpace / (ChartUtils.Math.FDEG2RAD * r)
                
                // offset needed to center the drawn text in the slice
                let offset = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0
                
                angle = angle + offset
                
                // calculate the text position
                let x = r
                    * cos((rotationAngle + angle * phaseY) * ChartUtils.Math.FDEG2RAD)
                    + center.x
                var y = r
                    * sin((rotationAngle + angle * phaseY) * ChartUtils.Math.FDEG2RAD)
                    + center.y
                
                let angle = rotationAngle + absoluteAngles[xIndex] - offset;
                
                let x1 = (r * (1 + polylineLengths[0])
                    * cos((angle * phaseY) * ChartUtils.Math.FDEG2RAD) + center.x)
                let y1 = (r * (1 + polylineLengths[0])
                    * sin((angle * phaseY) * ChartUtils.Math.FDEG2RAD) + center.y)
                
                let value = usePercentValuesEnabled ? e.value / yValueSum * 100.0 : e.value
                
                let val = formatter.stringFromNumber(value)!
                
                let lineHeight = valueFont.lineHeight
                y -= lineHeight
                
                //draw polyline
                var startPoint:CGPoint, midPoint:CGPoint, endPoint:CGPoint, labelPoint:CGPoint
                var align:NSTextAlignment
                let polyline2Width = enableAdjustPolylineWidth
                    ? r * polylineLengths[1] * abs(sin(angle * ChartUtils.Math.FDEG2RAD))
                    : r * polylineLengths[1];
                
                startPoint = CGPoint(x: x, y: y + lineHeight);
                midPoint = CGPoint(x: x1, y: y1)
                
                if(angle%360 >= 90 && angle%360 <= 270) {
                    endPoint = CGPoint(x: x1 - polyline2Width, y: y1)
                    align = .Right
                    labelPoint = CGPoint(x: endPoint.x - 5, y: endPoint.y - lineHeight)
                } else {
                    endPoint = CGPoint(x: x1 + polyline2Width, y: y1)
                    align = .Left
                    labelPoint = CGPoint(x: endPoint.x + 5, y: endPoint.y - lineHeight)
                }
                
                self.drawPolyline(context: context, startPoint: startPoint, midPoint: midPoint, endPoint: endPoint)
                
                // draw everything, depending on settings
                if (drawXVals && drawYVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: val,
                        point: labelPoint,
                        align: align,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                    
                    if (j < data.xValCount && data.xVals[j] != nil)
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: data.xVals[j]!,
                            point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight),
                            align: align,
                            attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                        )
                    }
                }
                else if (drawXVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: data.xVals[j]!,
                        point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
                        align: align,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                }
                else if (drawYVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: val,
                        point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
                        align: align,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                }
                
                xIndex++
            }
        }
    }
    
    public func drawPolyline(context context:CGContextRef, startPoint:CGPoint, midPoint:CGPoint, endPoint:CGPoint) {
        CGContextSaveGState(context)
        
        // draw the hole-circle
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 1.0);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y)
        CGContextAddLineToPoint(context, midPoint.x, midPoint.y)
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        
        CGContextDrawPath(context, CGPathDrawingMode.Stroke);
        CGContextRestoreGState(context)
    }
}
