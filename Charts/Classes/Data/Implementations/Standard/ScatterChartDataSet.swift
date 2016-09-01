//
//  ScatterChartDataSet.swift
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

public class ScatterChartDataSet: LineScatterCandleRadarChartDataSet, IScatterChartDataSet
{
    
    @objc(ScatterShape)
    public enum Shape: Int
    {
        case Square
        case Circle
        case Triangle
        case Cross
        case X
        case ChevronUp
        case ChevronDown
    }
    
    /// The size the scatter shape will have
    public var scatterShapeSize = CGFloat(10.0)
    
    /// The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// **default**: 0.0
    public var scatterShapeHoleRadius: CGFloat = 0.0
    
    /// Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    public var scatterShapeHoleColor: NSUIColor? = nil
    
    /// Sets the ScatterShape this DataSet should be drawn with.
    /// This will search for an available IShapeRenderer and set this renderer for the DataSet
    public func setScatterShape(shape: Shape)
    {
        self.shapeRenderer = ScatterChartDataSet.renderer(forShape: shape)
    }
    
    /// The IShapeRenderer responsible for rendering this DataSet.
    /// This can also be used to set a custom IShapeRenderer aside from the default ones.
    /// **default**: `SquareShapeRenderer`
    public var shapeRenderer: IShapeRenderer? = SquareShapeRenderer()
    
    public class func renderer(forShape shape: Shape) -> IShapeRenderer
    {
        switch shape
        {
        case .Square: return SquareShapeRenderer()
        case .Circle: return CircleShapeRenderer()
        case .Triangle: return TriangleShapeRenderer()
        case .Cross: return CrossShapeRenderer()
        case .X: return XShapeRenderer()
        case .ChevronUp: return ChevronUpShapeRenderer()
        case .ChevronDown: return ChevronDownShapeRenderer()
        }
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShapeHoleRadius = scatterShapeHoleRadius
        copy.scatterShapeHoleColor = scatterShapeHoleColor
        copy.shapeRenderer = shapeRenderer
        return copy
    }
}
