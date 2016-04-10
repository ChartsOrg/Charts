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
    // The size the scatter shape will have
    public var scatterShapeSize = CGFloat(15.0)
    
    // The type of shape that is set to be drawn where the values are at
    // **default**: .Square
    public var scatterShape = ScatterChartDataSet.Shape.Square
    
    // The radius of the hole in the shape (applies to Square, Circle and Triangle)
    // **default**: 0.0
    public var scatterShapeHoleRadius: CGFloat = 0.0
    
    // Color for the hole in the shape. Setting to `nil` will behave as transparent.
    // **default**: nil
    public var scatterShapeHoleColor: NSUIColor? = nil
    
    // Custom path object to draw where the values are at.
    // This is used when shape is set to Custom.
    public var customScatterShape: CGPath?
    
    public override func initialize()
    {

    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmScatterDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.customScatterShape = customScatterShape
        return copy
    }
    
}