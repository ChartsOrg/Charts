//
//  YAxis.swift
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

#if !os(OSX)
    import UIKit
#endif


/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
@objc(ChartYAxis)
public class YAxis: AxisBase
{
    @objc(YAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case OutsideChart
        case InsideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    @objc
    public enum AxisDependency: Int
    {
        case Left
        case Right
    }
    
    /// indicates if the top y-label entry is drawn or not
    public var drawTopYLabelEntryEnabled = true
    
    /// flag that indicates if the axis is inverted or not
    public var inverted = false
    
    /// flag that indicates if the zero-line should be drawn regardless of other grid lines
    public var drawZeroLineEnabled = false
    
    /// Color of the zero line
    public var zeroLineColor: NSUIColor? = NSUIColor.grayColor()
    
    /// Width of the zero line
    public var zeroLineWidth: CGFloat = 1.0
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var zeroLineDashPhase = CGFloat(0.0)
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var zeroLineDashLengths: [CGFloat]?

    /// axis space from the largest value to the top in percent of the total axis range
    public var spaceTop = CGFloat(0.1)

    /// axis space from the smallest value to the bottom in percent of the total axis range
    public var spaceBottom = CGFloat(0.1)
    
    /// the position of the y-labels relative to the chart
    public var labelPosition = LabelPosition.OutsideChart
    
    /// the side this axis object represents
    private var _axisDependency = AxisDependency.Left
    
    /// the minimum width that the axis should take
    /// 
    /// **default**: 0.0
    public var minWidth = CGFloat(0)
    
    /// the maximum width that the axis can take.
    /// use Infinity for disabling the maximum.
    /// 
    /// **default**: CGFloat.infinity
    public var maxWidth = CGFloat(CGFloat.infinity)
    
    public override init()
    {
        super.init()
        
        self.yOffset = 0.0
    }
    
    public init(position: AxisDependency)
    {
        super.init()
        
        _axisDependency = position
        
        self.yOffset = 0.0
    }
    
    public var axisDependency: AxisDependency
    {
        return _axisDependency
    }
    
    public func requiredSize() -> CGSize
    {
        let label = getLongestLabel() as NSString
        var size = label.sizeWithAttributes([NSFontAttributeName: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    public func getRequiredHeightSpace() -> CGFloat
    {
        return requiredSize().height
    }
    
    /// - returns: `true` if this axis needs horizontal offset, `false` ifno offset is needed.
    public var needsOffset: Bool
    {
        if (isEnabled && isDrawLabelsEnabled && labelPosition == .OutsideChart)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    public var isInverted: Bool { return inverted; }
    
    public override func calculate(min dataMin: Double, max dataMax: Double)
    {
        // if custom, use value as is, else use data value
        var min = _customAxisMin ? _axisMinimum : dataMin
        var max = _customAxisMax ? _axisMaximum : dataMax
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        // bottom-space only effects non-custom min
        if !_customAxisMin
        {
            let bottomSpace = range / 100.0 * Double(spaceBottom)
            _axisMinimum = (min - bottomSpace)
        }
        
        // top-space only effects non-custom max
        if !_customAxisMax
        {
            let topSpace = range / 100.0 * Double(spaceTop)
            _axisMaximum = (max + topSpace)
        }
        
        // calc actual range
        axisRange = abs(_axisMaximum - _axisMinimum)
    }
    
    public var isDrawTopYLabelEntryEnabled: Bool { return drawTopYLabelEntryEnabled; }

}
