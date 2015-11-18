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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
import Realm
import Realm.Dynamic

public class RealmScatterDataSet: RealmLineScatterCandleRadarDataSet, IScatterChartDataSet
{
    public var scatterShapeSize = CGFloat(15.0)
    public var scatterShape = ScatterChartDataSet.ScatterShape.Square
    public var customScatterShape: CGPath?
    
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