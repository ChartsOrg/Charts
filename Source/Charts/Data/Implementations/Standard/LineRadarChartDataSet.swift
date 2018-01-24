//
//  LineRadarChartDataSet.swift
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


open class LineRadarChartDataSet: LineScatterCandleRadarChartDataSet, ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    fileprivate var _fillColor = NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    /// The color that is used for filling the line surface area.
    open var fillColor: NSUIColor
    {
        get { return _fillColor }
        set
        {
            _fillColor = newValue
            fill = nil
        }
    }
    
    /// The object that is used for filling the area below the line.
    /// **default**: nil
    open var fill: Fill?
    
    /// The alpha value that is used for filling the line surface,
    /// **default**: 0.33
    open var fillAlpha = CGFloat(0.33)
    
    fileprivate var _lineWidth = CGFloat(1.0)
    
    /// line width of the chart (min = 0.0, max = 10)
    ///
    /// **default**: 1
    open var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
            if newValue < 0.0
            {
                _lineWidth = 0.0
            }
            else if newValue > 10.0
            {
                _lineWidth = 10.0
            }
            else
            {
                _lineWidth = newValue
            }
        }
    }
    
    /// Set to `true` if the DataSet should be drawn filled (surface), and not just as a line.
    /// Disabling this will give great performance boost.
    /// Please note that this method uses the path clipping for drawing the filled area (with images, gradients and layers).
    open var drawFilledEnabled = false
    
    /// - returns: `true` if filled drawing is enabled, `false` ifnot
    open var isDrawFilledEnabled: Bool
    {
        return drawFilledEnabled
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! LineRadarChartDataSet
        copy.fillColor = fillColor
        copy._lineWidth = _lineWidth
        copy.drawFilledEnabled = drawFilledEnabled
        return copy
    }
    
}
