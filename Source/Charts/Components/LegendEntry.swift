//
//  LegendEntry.swift
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

@objc(ChartLegendEntry)
public class LegendEntry: NSObject
{
    public override init()
    {
        super.init()
    }
    
    /// - parameter label:                  The legend entry text.
    ///                                     A `nil` label will start a group.
    /// - parameter form:                   The form to draw for this entry.
    /// - parameter formSize:               Set to NaN to use the legend's default.
    /// - parameter formLineWidth:          Set to NaN to use the legend's default.
    /// - parameter formLineDashPhase:      Line dash configuration.
    /// - parameter formLineDashLengths:    Line dash configurationas NaN to use the legend's default.
    /// - parameter formColor:              The color for drawing the form.
    public init(label: String?,
                form: Legend.Form,
                formSize: CGFloat,
                formLineWidth: CGFloat,
                formLineDashPhase: CGFloat,
                formLineDashLengths: [CGFloat]?,
                formColor: NSUIColor?)
    {
        self.label = label
        self.form = form
        self.formSize = formSize
        self.formLineWidth = formLineWidth
        self.formLineDashPhase = formLineDashPhase
        self.formLineDashLengths = formLineDashLengths
        self.formColor = formColor
    }
    
    /// The legend entry text.
    /// A `nil` label will start a group.
    public var label: String?
    
    /// The form to draw for this entry.
    ///
    /// `None` will avoid drawing a form, and any related space.
    /// `Empty` will avoid drawing a form, but keep its space.
    /// `Default` will use the Legend's default.
    public var form: Legend.Form = .Default
    
    /// Form size will be considered except for when .None is used
    ///
    /// Set as NaN to use the legend's default
    public var formSize: CGFloat = CGFloat.NaN
    
    /// Line width used for shapes that consist of lines.
    ///
    /// Set to NaN to use the legend's default.
    public var formLineWidth: CGFloat = CGFloat.NaN
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    ///
    /// Set to NaN to use the legend's default.
    public var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    ///
    /// Set to nil to use the legend's default.
    public var formLineDashLengths: [CGFloat]?
    
    /// The color for drawing the form
    public var formColor: NSUIColor?
}