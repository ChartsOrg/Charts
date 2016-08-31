//
//  ScatterChartDataSet.swift
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

open class ScatterChartDataSet: LineScatterCandleRadarChartDataSet, IScatterChartDataSet
{
    @objc(ScatterShape)
    public enum Shape: Int
    {
        case square
        case circle
        case triangle
        case cross
        case x
        case custom
    }
    
    // The size the scatter shape will have
    open var scatterShapeSize = CGFloat(10.0)
    
    // The type of shape that is set to be drawn where the values are at
    // **default**: .Square
    open var scatterShape = ScatterChartDataSet.Shape.square
    
    // The radius of the hole in the shape (applies to Square, Circle and Triangle)
    // **default**: 0.0
    open var scatterShapeHoleRadius: CGFloat = 0.0
    
    // Color for the hole in the shape. Setting to `nil` will behave as transparent.
    // **default**: nil
    open var scatterShapeHoleColor: NSUIColor? = nil
    
    // Custom path object to draw where the values are at.
    // This is used when shape is set to Custom.
    open var customScatterShape: CGPath?
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! ScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.customScatterShape = customScatterShape
        return copy
    }
}
