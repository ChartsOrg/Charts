//
//  ILineChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


@objc
public protocol ILineChartDataSet: ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The drawing mode for this line dataset
    ///
    /// **default**: Linear
    var mode: LineChartDataSet.Mode { get set }
    
    /// Intensity for cubic lines (min = 0.05, max = 1)
    ///
    /// **default**: 0.2
    var cubicIntensity: CGFloat { get set }
    
    @available(*, deprecated:1.0, message:"Use `mode` instead.")
    var drawCubicEnabled: Bool { get set }
    
    @available(*, deprecated:1.0, message:"Use `mode` instead.")
    var drawSteppedEnabled: Bool { get set }

    /// The radius of the drawn circles.
    var circleRadius: CGFloat { get set }
    
    /// The hole radius of the drawn circles.
    var circleHoleRadius: CGFloat { get set }
    
    var circleColors: [NSUIColor] { get set }
    
    /// - returns: the color at the given index of the DataSet's circle-color array.
    /// Performs a IndexOutOfBounds check by modulus.
    func getCircleColor(_ index: Int) -> NSUIColor?
    
    /// Sets the one and ONLY color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    func setCircleColor(_ color: NSUIColor)
    
    /// Resets the circle-colors array and creates a new one
    func resetCircleColors(_ index: Int)
    
    /// If true, drawing circles is enabled
    var drawCirclesEnabled: Bool { get set }
    
    /// The color of the inner circle (the circle-hole).
    var circleHoleColor: NSUIColor? { get set }
    
    /// True if drawing circles for this DataSet is enabled, false if not
    var drawCircleHoleEnabled: Bool { get set }
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    var lineDashPhase: CGFloat { get }
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    var lineDashLengths: [CGFloat]? { get set }
    
    /// Line cap type, default is CGLineCap.Butt
    var lineCapType: CGLineCap { get set }
    
    /// Sets a custom FillFormatter to the chart that handles the position of the filled-line for each DataSet. Set this to null to use the default logic.
    var fillFormatter: ChartFillFormatter? { get set }
}
