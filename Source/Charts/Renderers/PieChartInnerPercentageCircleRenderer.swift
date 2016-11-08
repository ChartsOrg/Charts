//
//  PieChartInnerPercentageCircleRenderer.swift
//  Charts
//
//  Created by pjapple on 2016/11/08.
//
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class PieChartInnerPercentageCircleRenderer : PieChartRenderer {
    
    var _innerChart : PieChartInnerPercentageView?

    public init(innnerChart: PieChartInnerPercentageView?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(chart: innnerChart, animator: animator, viewPortHandler: viewPortHandler)
        self.chart = chart
        _innerChart = innnerChart!
    }
    
    
    open override func drawExtras(context: CGContext) {
        drawCenterPieChart(context: context)
    }

    
    fileprivate func drawCenterPieChart(context: CGContext)
    {
        guard
            let chart = chart
            else { return }
        let radius = chart.radius
        let center = chart.centerCircleBox
        if chart.drawHoleEnabled
        {
            context.saveGState()
            // only draw the circle if it can be seen (not covered by the hole)
            if let transparentCircleColor = chart.transparentCircleColor
            {
                if transparentCircleColor != NSUIColor.clear &&
                    chart.transparentCircleRadiusPercent > chart.holeRadiusPercent
                {
                    context.setLineWidth(10.0);
                    UIColor.red.set()
                    context.addArc(center: CGPoint.init(x:  center.x , y: center.y), radius: (radius + 15)/2 , startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
                    context.strokePath();
                    
                    context.setLineWidth(10.0);
                    UIColor.green.set()
                    context.addArc(center: CGPoint.init(x:  center.x, y: center.y), radius: (radius + 15)/2 , startAngle: CGFloat( M_PI * 2.0), endAngle: CGFloat(M_PI * 2.0 * (_innerChart!.innerCirclePercentage/100)), clockwise: true)
                    context.strokePath();
                }
            }
        
            context.restoreGState()
        }
        
        
    }

    
}
