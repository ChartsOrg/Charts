//
//  ChartRendererBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class ChartRendererBase: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    public var viewPortHandler: ChartViewPortHandler?
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ChartViewPortHandler?)
    {
        super.init()
        self.viewPortHandler = viewPortHandler
    }
}
        