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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public class ScatterChartDataSet: LineScatterCandleRadarChartDataSet, IScatterChartDataSet
{
    @objc
    public enum ScatterShape: Int
    {
        case Square
        case Circle
        case Triangle
        case Cross
        case X
        case Custom
    }
    
    // The size the scatter shape will have
    public var scatterShapeSize = CGFloat(10.0)
    
    // The type of shape that is set to be drawn where the values are at
    // **default**: .Square
    public var scatterShape = ScatterChartDataSet.ScatterShape.Square
    
    // The radius of the hole in the shape (applies to Square, Circle and Triangle)
    // **default**: 0.0
    public var scatterShapeHoleRadius: CGFloat = 0.0
    
    // Color for the hole in the shape. Setting to `nil` will behave as transparent.
    // **default**: nil
    public var scatterShapeHoleColor: NSUIColor? = nil
    
    // Custom path object to draw where the values are at.
    // This is used when shape is set to Custom.
    public var customScatterShape: CGPath?
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.customScatterShape = customScatterShape
        return copy
    }
}
