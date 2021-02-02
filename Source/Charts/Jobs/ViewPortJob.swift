//
//  ViewPortJob.swift
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
open class ViewPortJob
{
    internal var point: CGPoint = .zero
    internal unowned var viewPortHandler: ViewPortHandler
    internal var xValue = 0.0
    internal var yValue = 0.0
    internal unowned var transformer: Transformer
    internal unowned var view: ChartViewBase

    public init(
        viewPortHandler: ViewPortHandler,
        xValue: Double,
        yValue: Double,
        transformer: Transformer,
        view: ChartViewBase)
    {
        self.viewPortHandler = viewPortHandler
        self.xValue = xValue
        self.yValue = yValue
        self.transformer = transformer
        self.view = view
    }
    
    open func doJob()
    {
        fatalError("`doJob()` must be overridden by subclasses")
    }
}
