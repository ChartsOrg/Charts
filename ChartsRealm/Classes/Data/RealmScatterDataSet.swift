//
//  RealmScatterDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

import Charts
import Realm
import Realm.Dynamic

public class RealmScatterDataSet: RealmLineScatterCandleRadarDataSet, IScatterChartDataSet
{
    
    /// The size the scatter shape will have
    public var scatterShapeSize = CGFloat(10.0)
    
    /// The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// **default**: 0.0
    public var scatterShapeHoleRadius: CGFloat = 0.0
    
    /// Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    public var scatterShapeHoleColor: NSUIColor? = nil
    
    private var _scatterShape: ScatterChartDataSet.Shape = ScatterChartDataSet.Shape.Square
    
    /// Sets the ScatterShape this DataSet should be drawn with.
    /// This will search for an available ShapeRenderer and set this renderer for the DataSet
    public var scatterShape: ScatterChartDataSet.Shape
    {
        get
        {
            return _scatterShape
        }
        set
        {
            _scatterShape = newValue
            
            switch _scatterShape
            {
            case .Square: _shapeRenderer = SquareShapeRenderer()
            case .Circle: _shapeRenderer = CircleShapeRenderer()
            case .Triangle: _shapeRenderer = TriangleShapeRenderer()
            case .Cross: _shapeRenderer = CrossShapeRenderer()
            case .X: _shapeRenderer = XShapeRenderer()
            case .ChevronUp: _shapeRenderer = ChevronUpShapeRenderer()
            case .ChevronDown: _shapeRenderer = ChevronDownShapeRenderer()
            case .Custom: break // Do nothing. Leave it as it is.
            }
        }
    }
    
    private var _shapeRenderer: IShapeRenderer?
    
    /// The ShapeRenderer responsible for rendering this DataSet.
    /// This can also be used to set a custom ShapeRenderer aside from the default ones.
    /// **default**: `SquareShapeRenderer`
    public var shapeRenderer: IShapeRenderer?
    {
        get
        {
            return _shapeRenderer
        }
        set
        {
            _scatterShape = .Custom
            _shapeRenderer = newValue
        }
    }
    
    public override func initialize()
    {

    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmScatterDataSet
        copy._scatterShape = _scatterShape
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.scatterShapeHoleRadius = scatterShapeHoleRadius
        copy.scatterShapeHoleColor = scatterShapeHoleColor
        copy.shapeRenderer = shapeRenderer
        return copy
    }
    
}