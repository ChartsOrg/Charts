//
//  RadarChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 24/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation


public class RadarChartDataSet: LineRadarChartDataSet, IRadarChartDataSet
{
    private func initialize()
    {
        self.valueFont = NSUIFont.systemFontOfSize(13.0)
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        initialize()
    }
    
    private var _drawCircleEnabled = false
    public var drawCircleEnabled : Bool
    {
        get {
            return _drawCircleEnabled
        }
        set {
            _drawCircleEnabled = newValue
        }
    }
    
    private var _drawCircleRadius : CGFloat = 4.0
    public var drawCircleRadius : CGFloat
    {
        set {
            _drawCircleRadius = newValue
        }
        get{
            return _drawCircleRadius
        }
    }
    
    private var _drawCircleStrokeColor : UIColor = UIColor.clearColor()
    public var drawCircleStrokeColor : UIColor
        {
        set {
            _drawCircleStrokeColor = newValue
        }
        get{
            return _drawCircleStrokeColor
        }
    }
    
    private var _drawCircleFillColor : UIColor = UIColor.clearColor()
    public var drawCircleFillColor : UIColor
        {
        set {
            _drawCircleFillColor = newValue
        }
        get{
            return _drawCircleFillColor
        }
    }
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
}