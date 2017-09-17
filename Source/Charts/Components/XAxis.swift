//
//  XAxis.swift
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

@objc(ChartXAxis)
open class XAxis: AxisBase
{
    @objc(XAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case top
        case bottom
        case bothSided
        case topInside
        case bottomInside
    }
    
    /// width of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    open var labelWidth = CGFloat(1.0)
    
    /// height of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    open var labelHeight = CGFloat(1.0)
    
    /// width of the (rotated) x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    open var labelRotatedWidth = CGFloat(1.0)
    
    /// height of the (rotated) x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    open var labelRotatedHeight = CGFloat(1.0)
    
    /// This is the angle for drawing the X axis labels (in degrees)
    open var labelRotationAngle = CGFloat(0.0)

    /// the position of the x-labels relative to the chart
    open var labelPosition = LabelPosition.top
    
    /// if set to true, word wrapping the labels will be enabled.
    /// word wrapping is done using `(value width * labelRotatedWidth)`
    ///
    /// - note: currently supports all charts except pie/radar/horizontal-bar*
    /// - returns: `true` if word wrapping the labels is enabled
    @objc public var isWordWrapEnabled: Bool {
        get { return _isWordWrapEnabled }
        @objc(setWordWrapEnabled:) set { _isWordWrapEnabled = newValue }
    }
    private var _isWordWrapEnabled = false
    
    /// the width for wrapping the labels, as percentage out of one value width.
    /// used only when isWordWrapEnabled = true.
    /// 
    /// **default**: 1.0
    open var wordWrapWidthPercent: CGFloat = 1.0
    
    public override init()
    {
        super.init()
        
        self.yOffset = 4.0
    }

    /// if set to true, the chart will avoid that the first and last label entry in the chart "clip" off the edge of the chart

    @objc public var isAvoidFirstLastClippingEnabled: Bool {
        get { return _isAvoidFirstLastClippingEnabled }
        @objc(setAvoidFirstLastClippingEnabled:) set { _isAvoidFirstLastClippingEnabled = newValue }
    }
    private var _isAvoidFirstLastClippingEnabled = false
}
