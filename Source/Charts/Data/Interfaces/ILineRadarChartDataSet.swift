//
//  ILineRadarChartDataSet.swift
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
public protocol ILineRadarChartDataSet: ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    var fillColor: NSUIColor { get set }

    /// Returns the object that is used for filling the area below the line.
    /// **default**: nil
    var fill: ChartFill? { get set }
    
    /// The alpha value that is used for filling the line surface.
    /// **default**: 0.33
    var fillAlpha: CGFloat { get set }
    
    /// line width of the chart (min = 0.2, max = 10)
    ///
    /// **default**: 1
    var lineWidth: CGFloat { get set }
    
    /// Set to true if the DataSet should be drawn filled (surface), and not just as a line.
    /// Disabling this will give great performance boost.
    /// Please note that this method uses the path clipping for drawing the filled area (with images, gradients and layers).
    var drawFilledEnabled: Bool { get set }
    
    /// Returns true if filled drawing is enabled, false if not
    var isDrawFilledEnabled: Bool { get }
}
