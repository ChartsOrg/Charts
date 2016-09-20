//
//  ZoomChartViewJob.swift
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

#if !os(OSX)
    import UIKit
#endif

public class ZoomChartViewJob: ChartViewPortJob
{
    internal var scaleX: CGFloat = 0.0
    internal var scaleY: CGFloat = 0.0
    internal var axisDependency: ChartYAxis.AxisDependency = ChartYAxis.AxisDependency.Left
    
    public init(
        viewPortHandler: ChartViewPortHandler,
        scaleX: CGFloat,
        scaleY: CGFloat,
        xIndex: CGFloat,
        yValue: Double,
        transformer: ChartTransformer,
        axis: ChartYAxis.AxisDependency,
        view: ChartViewBase)
    {
        super.init(
            viewPortHandler: viewPortHandler,
            xIndex: xIndex,
            yValue: yValue,
            transformer: transformer,
            view: view)
        
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.axisDependency = axis
    }
    
    public override func doJob()
    {
        guard let
            viewPortHandler = viewPortHandler,
            transformer = transformer,
            view = view
            else { return }
        
        var matrix = viewPortHandler.setZoom(scaleX: scaleX, scaleY: scaleY)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: false)
        
        let valsInView = (view as! BarLineChartViewBase).getDeltaY(axisDependency) / viewPortHandler.scaleY
        let xsInView = CGFloat((view as! BarLineChartViewBase).xAxis.values.count) / viewPortHandler.scaleX
        
        var pt = CGPoint(
            x: xIndex - xsInView / 2.0,
            y: CGFloat(yValue) + valsInView / 2.0
        )
        
        transformer.pointValueToPixel(&pt)
        
        matrix = viewPortHandler.translate(pt: pt)
        viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: false)
        
        (view as! BarLineChartViewBase).calculateOffsets()
        view.setNeedsDisplay()
    }
}