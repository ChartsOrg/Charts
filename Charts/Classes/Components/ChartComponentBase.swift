//
//  ChartComponentBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 16/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


/// This class encapsulates everything both Axis, Legend and LimitLines have in common
open class ChartComponentBase: NSObject
{
    /// flag that indicates if this component is enabled or not
    open var enabled = true
    
    /// Sets the used x-axis offset for the labels on this axis.
    /// **default**: 5.0
    open var xOffset = CGFloat(5.0)
    
    /// Sets the used y-axis offset for the labels on this axis.
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    open var yOffset = CGFloat(5.0)
    
    public override init()
    {
        super.init()
    }
}
