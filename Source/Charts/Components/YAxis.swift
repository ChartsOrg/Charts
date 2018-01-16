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


/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
@objc(ChartYAxis)
open class YAxis: AxisBase
{
    @objc(YAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case outsideChart
        case insideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    @objc
    public enum AxisDependency: Int
    {
        case left
        case right
    }
    
    /// indicates if the bottom y-label entry is drawn or not
    @objc open var isDrawBottomYLabelEntryEnabled = true
    
    /// indicates if the top y-label entry is drawn or not
    @objc open var isDrawTopYLabelEntryEnabled = true
    
    /// flag that indicates if the axis is inverted or not
    @objc open var isInverted = false
    
    /// flag that indicates if the zero-line should be drawn regardless of other grid lines
    @objc open var drawZeroLineEnabled = false
    
    /// Color of the zero line
    @objc open var zeroLineColor: NSUIColor? = .gray
    
    /// Width of the zero line
    @objc open var zeroLineWidth: CGFloat = 1.0
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    @objc open var zeroLineDashPhase: CGFloat = 0.0
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    @objc open var zeroLineDashLengths: [CGFloat]?

    /// axis space from the largest value to the top in percent of the total axis range
    @objc open var spaceTop: CGFloat = 0.1

    /// axis space from the smallest value to the bottom in percent of the total axis range
    @objc open var spaceBottom: CGFloat = 0.1
    
    /// the position of the y-labels relative to the chart
    @objc open var labelPosition = LabelPosition.outsideChart
    
    /// the side this axis object represents
    @objc open private(set) var axisDependency: AxisDependency
    
    /// the minimum width that the axis should take
    /// 
    /// **default**: 0.0
    @objc open var minWidth: CGFloat = 0
    
    /// the maximum width that the axis can take.
    /// use Infinity for disabling the maximum.
    /// 
    /// **default**: CGFloat.infinity
    @objc open var maxWidth = CGFloat.infinity

    @objc public init(position: AxisDependency)
    {
        axisDependency = position

        super.init()
        
        self.yOffset = 0.0
    }

    @objc open func requiredSize() -> CGSize
    {
        let label = getLongestLabel() as NSString
        var size = label.size(withAttributes: [.font: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    @objc open func getRequiredHeightSpace() -> CGFloat
    {
        return requiredSize().height
    }
    
    /// - returns: `true` if this axis needs horizontal offset, `false` ifno offset is needed.
    @objc open var needsOffset: Bool
    {
        return isEnabled
            && isDrawLabelsEnabled
            && labelPosition == .outsideChart
    }

    open override func calculate(min dataMin: Double, max dataMax: Double)
    {
        // if custom, use value as is, else use data value
        var min = useCustomAxisMin ? axisMinimum : dataMin
        var max = useCustomAxisMax ? axisMaximum : dataMax
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        // bottom-space and top-space only effects non-custom min
        if !useCustomAxisMin
        {
            let bottomSpace = range * Double(spaceBottom)
            axisMinimum = (min - bottomSpace)

            let topSpace = range * Double(spaceTop)
            axisMaximum = (max + topSpace)
        }
        
        // calc actual range
        axisRange = abs(axisMaximum - axisMinimum)
    }
}
