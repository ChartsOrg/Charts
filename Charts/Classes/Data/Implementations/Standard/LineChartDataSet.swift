//
//  LineChartDataSet.swift
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


public class LineChartDataSet: LineRadarChartDataSet, ILineChartDataSet
{
    @objc(LineChartMode)
    public enum Mode: Int
    {
        case Linear
        case Stepped
        case CubicBezier
        case HorizontalBezier
    }
    
    private func initialize()
    {
        // default color
        circleColors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(values: [ChartDataEntry]?, label: String?)
    {
        super.init(values: values, label: label)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The drawing mode for this line dataset
    ///
    /// **default**: Linear
    public var mode: Mode = Mode.Linear
    
    private var _cubicIntensity = CGFloat(0.2)
    
    /// Intensity for cubic lines (min = 0.05, max = 1)
    ///
    /// **default**: 0.2
    public var cubicIntensity: CGFloat
    {
        get
        {
            return _cubicIntensity
        }
        set
        {
            _cubicIntensity = newValue
            if (_cubicIntensity > 1.0)
            {
                _cubicIntensity = 1.0
            }
            if (_cubicIntensity < 0.05)
            {
                _cubicIntensity = 0.05
            }
        }
    }
    
    @available(*, deprecated=1.0, message="Use `mode` instead.")
    public var drawCubicEnabled: Bool
    {
        get
        {
            return mode == .CubicBezier
        }
        set
        {
            mode = newValue ? LineChartDataSet.Mode.CubicBezier : LineChartDataSet.Mode.Linear
        }
    }
    
    @available(*, deprecated=1.0, message="Use `mode` instead.")
    public var isDrawCubicEnabled: Bool { return drawCubicEnabled }
    
    @available(*, deprecated=1.0, message="Use `mode` instead.")
    public var drawSteppedEnabled: Bool
    {
        get
        {
            return mode == .Stepped
        }
        set
        {
            mode = newValue ? LineChartDataSet.Mode.Stepped : LineChartDataSet.Mode.Linear
        }
    }
    
    @available(*, deprecated=1.0, message="Use `mode` instead.")
    public var isDrawSteppedEnabled: Bool { return drawSteppedEnabled }
    
    /// The radius of the drawn circles.
    public var circleRadius = CGFloat(8.0)
    
    /// The hole radius of the drawn circles
    public var circleHoleRadius = CGFloat(4.0)
    
    public var circleColors = [NSUIColor]()
    
    /// - returns: The color at the given index of the DataSet's circle-color array.
    /// Performs a IndexOutOfBounds check by modulus.
    public func getCircleColor(index: Int) -> NSUIColor?
    {
        let size = circleColors.count
        let index = index % size
        if (index >= size)
        {
            return nil
        }
        return circleColors[index]
    }
    
    /// Sets the one and ONLY color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    public func setCircleColor(color: NSUIColor)
    {
        circleColors.removeAll(keepCapacity: false)
        circleColors.append(color)
    }
    
    public func setCircleColors(colors: NSUIColor...)
    {
        circleColors.removeAll(keepCapacity: false)
        circleColors.appendContentsOf(colors)
    }
    
    /// Resets the circle-colors array and creates a new one
    public func resetCircleColors(index: Int)
    {
        circleColors.removeAll(keepCapacity: false)
    }
    
    /// If true, drawing circles is enabled
    public var drawCirclesEnabled = true
    
    /// - returns: `true` if drawing circles for this DataSet is enabled, `false` ifnot
    public var isDrawCirclesEnabled: Bool { return drawCirclesEnabled }
    
    /// The color of the inner circle (the circle-hole).
    public var circleHoleColor: NSUIColor? = NSUIColor.whiteColor()
    
    /// `true` if drawing circles for this DataSet is enabled, `false` ifnot
    public var drawCircleHoleEnabled = true
    
    /// - returns: `true` if drawing the circle-holes is enabled, `false` ifnot.
    public var isDrawCircleHoleEnabled: Bool { return drawCircleHoleEnabled }
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var lineDashPhase = CGFloat(0.0)
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var lineDashLengths: [CGFloat]?
    
    /// Line cap type, default is CGLineCap.Butt
    public var lineCapType = CGLineCap.Butt
    
    /// formatter for customizing the position of the fill-line
    private var _fillFormatter: IFillFormatter = DefaultFillFormatter()
    
    /// Sets a custom IFillFormatter to the chart that handles the position of the filled-line for each DataSet. Set this to null to use the default logic.
    public var fillFormatter: IFillFormatter?
    {
        get
        {
            return _fillFormatter
        }
        set
        {
            if newValue == nil
            {
                _fillFormatter = DefaultFillFormatter()
            }
            else
            {
                _fillFormatter = newValue!
            }
        }
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! LineChartDataSet
        copy.circleColors = circleColors
        copy.circleRadius = circleRadius
        copy.cubicIntensity = cubicIntensity
        copy.lineDashPhase = lineDashPhase
        copy.lineDashLengths = lineDashLengths
        copy.lineCapType = lineCapType
        copy.drawCirclesEnabled = drawCirclesEnabled
        copy.drawCircleHoleEnabled = drawCircleHoleEnabled
        copy.mode = mode
        return copy
    }
}
