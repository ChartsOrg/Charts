//
//  AnimatedZoomChartViewJob.swift
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

open class AnimatedZoomChartViewJob: AnimatedViewPortJob
{
    internal var yAxis: ChartYAxis?
    internal var xValCount: Int = 0
    internal var scaleX: CGFloat = 0.0
    internal var scaleY: CGFloat = 0.0
    internal var zoomOriginX: CGFloat = 0.0
    internal var zoomOriginY: CGFloat = 0.0
    internal var zoomCenterX: CGFloat = 0.0
    internal var zoomCenterY: CGFloat = 0.0

    public init(
        viewPortHandler: ChartViewPortHandler,
        transformer: ChartTransformer,
        view: ChartViewBase,
        yAxis: ChartYAxis,
        xValCount: Int,
        scaleX: CGFloat,
        scaleY: CGFloat,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        zoomCenterX: CGFloat,
        zoomCenterY: CGFloat,
        zoomOriginX: CGFloat,
        zoomOriginY: CGFloat,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        super.init(viewPortHandler: viewPortHandler,
            xIndex: 0.0,
            yValue: 0.0,
            transformer: transformer,
            view: view,
            xOrigin: xOrigin,
            yOrigin: yOrigin,
            duration: duration,
            easing: easing)
        
        self.yAxis = yAxis
        self.xValCount = xValCount
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.zoomCenterX = zoomCenterX
        self.zoomCenterY = zoomCenterY
        self.zoomOriginX = zoomOriginX
        self.zoomOriginY = zoomOriginY
    }
    
    internal override func animationUpdate()
    {
        guard let viewPortHandler = viewPortHandler,
              let transformer = transformer,
              let view = view
        else { return }
        
        let scaleX = xOrigin + (self.scaleX - xOrigin) * phase
        let scaleY = yOrigin + (self.scaleY - yOrigin) * phase
        
        var matrix = viewPortHandler.setZoom(scaleX: scaleX, scaleY: scaleY)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: false)
        
        let valsInView = CGFloat(yAxis?.axisRange ?? 0.0) / viewPortHandler.scaleY
        let xsInView = CGFloat(xValCount) / viewPortHandler.scaleX
        
        let x = zoomOriginX + ((zoomCenterX - xsInView / 2.0) - zoomOriginX) * phase
        let y = zoomOriginY + ((zoomCenterY + valsInView / 2.0) - zoomOriginY) * phase
        var pt = CGPoint(x: x, y: y)
        
        transformer.pointValueToPixel(&pt)
        
        matrix = viewPortHandler.translate(pt: pt)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: true)
    }
    
    internal override func animationEnd()
    {
        (view as? BarLineChartViewBase)?.calculateOffsets()
        view?.setNeedsDisplay()
    }
}
