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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

@objc
public protocol ILineChartDataSet: ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Intensity for cubic lines (min = 0.05, max = 1)
    ///
    /// **default**: 0.2
    var cubicIntensity: CGFloat { get set }
    
    /// If true, cubic lines are drawn instead of linear
    var drawCubicEnabled: Bool { get set }
    
    /// - returns: true if drawing cubic lines is enabled, false if not.
    var isDrawCubicEnabled: Bool { get }
    
    /// The radius of the drawn circles.
    var circleRadius: CGFloat { get set }
    
    var circleColors: [NSUIColor] { get set }
    
    /// - returns: the color at the given index of the DataSet's circle-color array.
    /// Performs a IndexOutOfBounds check by modulus.
    func getCircleColor(var index: Int) -> NSUIColor?
    
    /// Sets the one and ONLY color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    func setCircleColor(color: NSUIColor)
    
    /// Resets the circle-colors array and creates a new one
    func resetCircleColors(index: Int)
    
    /// If true, drawing circles is enabled
    var drawCirclesEnabled: Bool { get set }
    
    /// - returns: true if drawing circles for this DataSet is enabled, false if not
    var isDrawCirclesEnabled: Bool { get }
    
    /// The color of the inner circle (the circle-hole).
    var circleHoleColor: NSUIColor { get set }
    
    /// True if drawing circles for this DataSet is enabled, false if not
    var drawCircleHoleEnabled: Bool { get set }
    
    /// - returns: true if drawing the circle-holes is enabled, false if not.
    var isDrawCircleHoleEnabled: Bool { get }
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    var lineDashPhase: CGFloat { get }
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    var lineDashLengths: [CGFloat]? { get set }
    
    /// Sets a custom FillFormatter to the chart that handles the position of the filled-line for each DataSet. Set this to null to use the default logic.
    var fillFormatter: ChartFillFormatter? { get set }
}
