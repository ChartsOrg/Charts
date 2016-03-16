//
//  ChartAxisBase.swift
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
import CoreGraphics

public class ChartAxisBase: ChartComponentBase
{
    public var labelFont = NSUIFont.systemFontOfSize(10.0)
    public var labelTextColor = NSUIColor.blackColor()
    
    public var axisLineColor = NSUIColor.grayColor()
    public var axisLineWidth = CGFloat(0.5)
    public var axisLineDashPhase = CGFloat(0.0)
    public var axisLineDashLengths: [CGFloat]!
    
    public var gridColor = NSUIColor.grayColor().colorWithAlphaComponent(0.9)
    public var gridLineWidth = CGFloat(0.5)
    public var gridLineDashPhase = CGFloat(0.0)
    public var gridLineDashLengths: [CGFloat]!
    public var gridLineCap = CGLineCap.Butt
    
    public var drawGridLinesEnabled = true
    public var drawAxisLineEnabled = true
    
    /// flag that indicates of the labels of this axis should be drawn or not
    public var drawLabelsEnabled = true
    
    /// array of limitlines that can be set for the axis
    private var _limitLines = [ChartLimitLine]()
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    public var drawLimitLinesBehindDataEnabled = false

    /// the flag can be used to turn off the antialias for grid lines
    public var gridAntialiasEnabled = true

    public override init()
    {
        super.init()
    }
    
    public func getLongestLabel() -> String
    {
        fatalError("getLongestLabel() cannot be called on ChartAxisBase")
    }
    
    public var isDrawGridLinesEnabled: Bool { return drawGridLinesEnabled; }
    
    public var isDrawAxisLineEnabled: Bool { return drawAxisLineEnabled; }
    
    public var isDrawLabelsEnabled: Bool { return drawLabelsEnabled; }
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    public var isDrawLimitLinesBehindDataEnabled: Bool { return drawLimitLinesBehindDataEnabled; }
    
    /// Adds a new ChartLimitLine to this axis.
    public func addLimitLine(line: ChartLimitLine)
    {
        _limitLines.append(line)
    }
    
    /// Removes the specified ChartLimitLine from the axis.
    public func removeLimitLine(line: ChartLimitLine)
    {
        for (var i = 0; i < _limitLines.count; i++)
        {
            if (_limitLines[i] === line)
            {
                _limitLines.removeAtIndex(i)
                return
            }
        }
    }
    
    /// Removes all LimitLines from the axis.
    public func removeAllLimitLines()
    {
        _limitLines.removeAll(keepCapacity: false)
    }
    
    /// - returns: the LimitLines of this axis.
    public var limitLines : [ChartLimitLine]
        {
            return _limitLines
    }
}