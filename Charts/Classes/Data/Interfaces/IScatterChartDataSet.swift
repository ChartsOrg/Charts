//
//  IScatterChartDataSet.swift
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
public protocol IScatterChartDataSet: ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    // The size the scatter shape will have
    var scatterShapeSize: CGFloat { get set }
    
    // The type of shape that is set to be drawn where the values are at
    // - default: .Square
    var scatterShape: ScatterChartDataSet.ScatterShape { get set }
    
    // The radius of the hole in the shape (applies to Square, Circle and Triangle)
    // Set this to <= 0 to remove holes.
    // - default: 0.0
    var scatterShapeHoleRadius: CGFloat { get set }
    
    // Color for the hole in the shape. Setting to `nil` will behave as transparent.
    // - default: nil
    var scatterShapeHoleColor: NSUIColor? { get set }
    
    // Custom path object to draw where the values are at.
    // This is used when shape is set to Custom.
    var customScatterShape: CGPath? { get set }
}
