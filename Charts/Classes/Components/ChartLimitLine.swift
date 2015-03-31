//
//  ChartLimitLine.swift
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

public class ChartLimitLine: ChartComponentBase
{
    public var limit = Float(0.0)
    private var _lineWidth = CGFloat(2.0)
    public var lineColor = UIColor(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    public var lineDashPhase = CGFloat(0.0)
    public var lineDashLengths: [CGFloat]?
    public var valueTextColor = UIColor.blackColor()
    public var valueFont = UIFont.systemFontOfSize(13.0)
    public var label = ""
    public var labelPosition = LabelPosition.Right
    
    public override init()
    {
        super.init();
    }
    
    public init(limit: Float)
    {
        super.init();
        self.limit = limit;
    }
    
    public init(limit: Float, label: String)
    {
        super.init();
        self.limit = limit;
        self.label = label;
    }
    
    /// set the line width of the chart (min = 0.2f, max = 12f); default 2f
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
                _lineWidth = 0.2;
            }
            if (_lineWidth > 12.0)
            {
                _lineWidth = 12.0;
            }
        }
    }
}