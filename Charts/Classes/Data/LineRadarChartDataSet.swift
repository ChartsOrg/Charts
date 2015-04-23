//
//  LineRadarChartDataSet.swift
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
import CoreGraphics.CGBase
import UIKit.UIColor

public class LineRadarChartDataSet: BarLineScatterCandleChartDataSet
{
    public var fillColor = UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    public var fillAlpha = CGFloat(0.33)
    private var _lineWidth = CGFloat(1.0)
    public var drawFilledEnabled = false
    
    /// line width of the chart (min = 0.2f, max = 10f)
    /// :default: 1
    public var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth;
        }
        set
        {
            _lineWidth = newValue;
            if (_lineWidth < 0.2)
            {
                _lineWidth = 0.5;
            }
            if (_lineWidth > 10.0)
            {
                _lineWidth = 10.0;
            }
        }
    }
    
    public var isDrawFilledEnabled: Bool
    {
        return drawFilledEnabled;
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! LineRadarChartDataSet;
        copy.fillColor = fillColor;
        copy._lineWidth = _lineWidth;
        copy.drawFilledEnabled = drawFilledEnabled;
        return copy;
    }
}
