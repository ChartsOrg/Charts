//
//  ChartYAxis.swift
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

/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
public class ChartYAxis: ChartAxisBase
{
    @objc
    public enum YAxisLabelPosition: Int
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
    
    public var entries = [Float]()
    public var entryCount: Int { return entries.count; }
    
    /// the number of y-label entries the y-labels should have, default 6
    private var _labelCount = Int(6)
    
    /// indicates if the top y-label entry is drawn or not
    public var drawTopYLabelEntryEnabled = true
    
    /// if true, the y-labels show only the minimum and maximum value
    public var showOnlyMinMaxEnabled = false
    
    /// flag that indicates if the axis is inverted or not
    public var inverted = false
    
    /// if true, the y-label entries will always start at zero
    public var startAtZeroEnabled = true
    
    /// the formatter used to customly format the y-labels
    public var valueFormatter: NSNumberFormatter?
    
    /// the formatter used to customly format the y-labels
    internal var _defaultValueFormatter = NSNumberFormatter()
    
    /// A custom minimum value for this axis. 
    /// If set, this value will not be calculated automatically depending on the provided data. 
    /// Use resetcustomAxisMin() to undo this. 
    /// Do not forget to set startAtZeroEnabled = false if you use this method.
    /// Otherwise, the axis-minimum value will still be forced to 0.
    public var customAxisMin = Float.NaN
        
    /// Set a custom maximum value for this axis. 
    /// If set, this value will not be calculated automatically depending on the provided data. 
    /// Use resetcustomAxisMax() to undo this.
    public var customAxisMax = Float.NaN

    /// axis space from the largest value to the top in percent of the total axis range
    public var spaceTop = CGFloat(0.1)

    /// axis space from the smallest value to the bottom in percent of the total axis range
    public var spaceBottom = CGFloat(0.1)
    
    public var axisMaximum = Float(0)
    public var axisMinimum = Float(0)
    
    /// the total range of values this axis covers
    public var axisRange = Float(0)
    
    /// the position of the y-labels relative to the chart
    public var labelPosition = YAxisLabelPosition.OutsideChart
    
    /// the side this axis object represents
    private var _axisDependency = AxisDependency.Left
    
    public override init()
    {
        super.init();
        
        _defaultValueFormatter.maximumFractionDigits = 1;
        _defaultValueFormatter.minimumFractionDigits = 1;
        _defaultValueFormatter.usesGroupingSeparator = true;
    }
    
    public init(position: AxisDependency)
    {
        super.init();
        
        _axisDependency = position;
        
        _defaultValueFormatter.maximumFractionDigits = 1;
        _defaultValueFormatter.minimumFractionDigits = 1;
        _defaultValueFormatter.usesGroupingSeparator = true;
    }
    
    public var axisDependency: AxisDependency
    {
        return _axisDependency;
    }
    
    /// the number of label entries the y-axis should have
    /// max = 15,
    /// min = 2,
    /// default = 6,
    /// be aware that this number is not fixed and can only be approximated
    public var labelCount: Int
    {
        get
        {
            return _labelCount;
        }
        set
        {
            _labelCount = newValue;
            
            if (_labelCount > 15)
            {
                _labelCount = 15;
            }
            if (_labelCount < 2)
            {
                _labelCount = 2;
            }
        }
    }
    
    /// By calling this method, any custom minimum value that has been previously set is reseted, and the calculation is done automatically.
    public func resetcustomAxisMin()
    {
        customAxisMin = Float.NaN;
    }
    
    /// By calling this method, any custom maximum value that has been previously set is reseted, and the calculation is done automatically.
    public func resetcustomAxisMax()
    {
        customAxisMax = Float.NaN;
    }
    
    public func requiredSize() -> CGSize
    {
        var label = getLongestLabel() as NSString;
        var size = label.sizeWithAttributes([NSFontAttributeName: labelFont]);
        size.width += xOffset * 2.0;
        size.height += yOffset * 2.0;
        return size;
    }

    public override func getLongestLabel() -> String
    {
        var longest = "";
        
        for (var i = 0; i < entries.count; i++)
        {
            var text = getFormattedLabel(i);
            
            if (longest.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) < text.lengthOfBytesUsingEncoding(NSUTF16StringEncoding))
            {
                longest = text;
            }
        }
        
        return longest;
    }

    /// Returns the formatted y-label at the specified index. This will either use the auto-formatter or the custom formatter (if one is set).
    public func getFormattedLabel(index: Int) -> String
    {
        if (index < 0 || index >= entries.count)
        {
            return "";
        }
        
        return (valueFormatter ?? _defaultValueFormatter).stringFromNumber(entries[index])!;
    }
    
    /// Returns true if this axis needs horizontal offset, false if no offset is needed.
    public var needsOffset: Bool
    {
        if (isEnabled && isDrawLabelsEnabled && labelPosition == .OutsideChart)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public var isInverted: Bool { return inverted; }
    
    public var isStartAtZeroEnabled: Bool { return startAtZeroEnabled; }
    
    public var isShowOnlyMinMaxEnabled: Bool { return showOnlyMinMaxEnabled; }
    
    public var isDrawTopYLabelEntryEnabled: Bool { return drawTopYLabelEntryEnabled; }
}