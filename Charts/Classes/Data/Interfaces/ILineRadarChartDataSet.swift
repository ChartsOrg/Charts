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
//  https://github.com/danielgindi/ios-charts
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
    /// - default: nil
    var fill: ChartFill? { get set }
    
    /// The alpha value that is used for filling the line surface.
    /// - default: 0.33
    var fillAlpha: CGFloat { get set }
    
    /// line width of the chart (min = 0.2, max = 10)
    ///
    /// **default**: 1
    var lineWidth: CGFloat { get set }
    
    var drawFilledEnabled: Bool { get set }
    
    var isDrawFilledEnabled: Bool { get }
}
