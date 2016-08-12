//
//  IScatterChartDataSet.swift
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

@objc
public protocol IScatterChartDataSet: ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// - returns: The size the scatter shape will have
    var scatterShapeSize: CGFloat { get }
    
    /// - returns: The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// Set this to <= 0 to remove holes.
    /// **default**: 0.0
    var scatterShapeHoleRadius: CGFloat { get }
    
    /// - returns: Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    var scatterShapeHoleColor: NSUIColor? { get }
    
    /// - returns: The IShapeRenderer responsible for rendering this DataSet.
    var shapeRenderer: IShapeRenderer? { get }
}
