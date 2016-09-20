//
//  ChartViewPortJob.swift
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

// This defines a viewport modification job, used for delaying or animating viewport changes
public class ChartViewPortJob
{
    internal var point: CGPoint = CGPoint()
    internal weak var viewPortHandler: ChartViewPortHandler?
    internal var xIndex: CGFloat = 0.0
    internal var yValue: Double = 0.0
    internal weak var transformer: ChartTransformer?
    internal weak var view: ChartViewBase?
    
    public init(
        viewPortHandler: ChartViewPortHandler,
        xIndex: CGFloat,
        yValue: Double,
        transformer: ChartTransformer,
        view: ChartViewBase)
    {
        self.viewPortHandler = viewPortHandler
        self.xIndex = xIndex
        self.yValue = yValue
        self.transformer = transformer
        self.view = view
    }
    
    public func doJob()
    {
        // Override this
    }
}