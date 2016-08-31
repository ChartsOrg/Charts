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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

/// Base class for all axes
open class ChartAxisBase: ChartComponentBase
{
    open var labelFont = NSUIFont.systemFont(ofSize: 10.0)
    open var labelTextColor = NSUIColor.black
    
    open var axisLineColor = NSUIColor.gray
    open var axisLineWidth = CGFloat(0.5)
    open var axisLineDashPhase = CGFloat(0.0)
    open var axisLineDashLengths: [CGFloat]!
    
    open var gridColor = NSUIColor.gray.withAlphaComponent(0.9)
    open var gridLineWidth = CGFloat(0.5)
    open var gridLineDashPhase = CGFloat(0.0)
    open var gridLineDashLengths: [CGFloat]!
    open var gridLineCap = CGLineCap.butt
    
    open var drawGridLinesEnabled = true
    open var drawAxisLineEnabled = true
    
    /// flag that indicates of the labels of this axis should be drawn or not
    open var drawLabelsEnabled = true
    
    /// array of limitlines that can be set for the axis
    private var _limitLines = [ChartLimitLine]()
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    open var drawLimitLinesBehindDataEnabled = false

    /// the flag can be used to turn off the antialias for grid lines
    open var gridAntialiasEnabled = true

    public override init()
    {
        super.init()
    }
    
    open func getLongestLabel() -> String
    {
        fatalError("getLongestLabel() cannot be called on ChartAxisBase")
    }
    
    /// Flag indicating that the axis-min value has been customized
    internal var _customAxisMin: Bool = false
    
    /// Flag indicating that the axis-max value has been customized
    internal var _customAxisMax: Bool = false
    
    /// Do not touch this directly, instead, use axisMinValue.
    /// This is automatically calculated to represent the real min value,
    /// and is used when calculating the effective minimum.
    open var _axisMinimum = Double(0)
    
    /// Do not touch this directly, instead, use axisMaxValue.
    /// This is automatically calculated to represent the real max value,
    /// and is used when calculating the effective maximum.
    open var _axisMaximum = Double(0)
    
    /// the total range of values this axis covers
    open var axisRange = Double(0)
    
    /// Adds a new ChartLimitLine to this axis.
    open func addLimitLine(_ line: ChartLimitLine)
    {
        _limitLines.append(line)
    }
    
    /// Removes the specified ChartLimitLine from the axis.
    open func removeLimitLine(_ line: ChartLimitLine)
    {
        for i in 0 ..< _limitLines.count
        {
            if (_limitLines[i] === line)
            {
                _limitLines.remove(at: i)
                return
            }
        }
    }
    
    /// Removes all LimitLines from the axis.
    open func removeAllLimitLines()
    {
        _limitLines.removeAll(keepingCapacity: false)
    }
    
    /// - returns: the LimitLines of this axis.
    open var limitLines : [ChartLimitLine]
    {
        return _limitLines
    }
    
    // MARK: Custom axis ranges
    
    /// By calling this method, any custom minimum value that has been previously set is reseted, and the calculation is done automatically.
    open func resetCustomAxisMin()
    {
        _customAxisMin = false
    }
    
    open var isAxisMinCustom: Bool { return _customAxisMin }
    
    /// By calling this method, any custom maximum value that has been previously set is reseted, and the calculation is done automatically.
    open func resetCustomAxisMax()
    {
        _customAxisMax = false
    }
    
    open var isAxisMaxCustom: Bool { return _customAxisMax }
    
    /// The minimum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMin()` to undo this.
    open var axisMinValue: Double
    {
        get
        {
            return _axisMinimum
        }
        set
        {
            _customAxisMin = true
            _axisMinimum = newValue
        }
    }
    
    /// The maximum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMin()` to undo this.
    open var axisMaxValue: Double
    {
        get
        {
            return _axisMaximum
        }
        set
        {
            _customAxisMax = true
            _axisMaximum = newValue
        }
    }
}
