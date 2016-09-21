//
//  RealmScatterDataSet.swift
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
#if NEEDS_CHARTS
import Charts
#endif
import Realm
import Realm.Dynamic

open class RealmScatterDataSet: RealmLineScatterCandleRadarDataSet, IScatterChartDataSet
{
    
    /// The size the scatter shape will have
    open var scatterShapeSize = CGFloat(10.0)
    
    /// The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// **default**: 0.0
    open var scatterShapeHoleRadius: CGFloat = 0.0
    
    /// Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    open var scatterShapeHoleColor: NSUIColor? = nil
    
    /// Sets the ScatterShape this DataSet should be drawn with.
    /// This will search for an available IShapeRenderer and set this renderer for the DataSet
    open func setScatterShape(_ shape: ScatterChartDataSet.Shape)
    {
        self.shapeRenderer = ScatterChartDataSet.renderer(forShape: shape)
    }
    
    /// The IShapeRenderer responsible for rendering this DataSet.
    /// This can also be used to set a custom IShapeRenderer aside from the default ones.
    /// **default**: `SquareShapeRenderer`
    open var shapeRenderer: IShapeRenderer? = SquareShapeRenderer()
    
    open override func initialize()
    {

    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmScatterDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShapeHoleRadius = scatterShapeHoleRadius
        copy.scatterShapeHoleColor = scatterShapeHoleColor
        copy.shapeRenderer = shapeRenderer
        return copy
    }
    
}
