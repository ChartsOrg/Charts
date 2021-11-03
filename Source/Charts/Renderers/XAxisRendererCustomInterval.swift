//
//  XAxisRendererCustomInterval.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class XAxisRendererCustomInterval: XAxisRenderer
{
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    @objc open override func computeAxisValues(min: Double, max: Double)
    {
        AxisRendererCustomInterval.computeAxisValues(min: min, max: max, axis: axis)
    }
}
