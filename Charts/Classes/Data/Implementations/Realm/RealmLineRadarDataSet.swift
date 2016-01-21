//
//  RealmLineRadarDataSet.swift
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

public class RealmLineRadarDataSet: RealmLineScatterCandleRadarDataSet, ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    public var fillColor = UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    /// The alpha value that is used for filling the line surface,
    /// - default: 0.33
    public var fillAlpha = CGFloat(0.33)
    
    private var _lineWidth = CGFloat(1.0)
    
    /// line width of the chart (min = 0.2, max = 10)
    ///
    /// **default**: 1
    public var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
            if (newValue < 0.2)
            {
                _lineWidth = 0.2
            }
            else if (newValue > 10.0)
            {
                _lineWidth = 10.0
            }
            else
            {
                _lineWidth = newValue
            }
        }
    }
    
    public var drawFilledEnabled = false
    
    public var isDrawFilledEnabled: Bool
    {
        return drawFilledEnabled
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmLineRadarDataSet
        copy.fillColor = fillColor
        copy._lineWidth = _lineWidth
        copy.drawFilledEnabled = drawFilledEnabled
        return copy
    }
    
}