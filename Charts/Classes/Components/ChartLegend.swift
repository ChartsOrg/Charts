//
//  ChartLegend.swift
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
import UIKit

public class ChartLegend: ChartComponentBase
{
    @objc
    public enum ChartLegendPosition: Int
    {
        case RightOfChart
        case RightOfChartCenter
        case RightOfChartInside
        case LeftOfChart
        case LeftOfChartCenter
        case LeftOfChartInside
        case BelowChartLeft
        case BelowChartRight
        case BelowChartCenter
        case PiechartCenter
    }
    
    @objc
    public enum ChartLegendForm: Int
    {
        case Square
        case Circle
        case Line
    }
    
    @objc
    public enum ChartLegendDirection: Int
    {
        case LeftToRight
        case RightToLeft
    }

    private var _colors = [UIColor?]()
    private var _labels = [String?]()
    
    public var position = ChartLegendPosition.BelowChartLeft
    public var direction = ChartLegendDirection.LeftToRight
    
    public var font: UIFont = UIFont.systemFontOfSize(10.0)
    public var textColor = UIColor.blackColor()
    
    public var form = ChartLegendForm.Square
    public var formSize = CGFloat(8.0)
    public var formLineWidth = CGFloat(1.5)
    
    public var xEntrySpace = CGFloat(6.0)
    public var yEntrySpace = CGFloat(5.0)
    public var formToTextSpace = CGFloat(5.0)
    public var stackSpace = CGFloat(3.0)
    
    public var xOffset = CGFloat(5.0)
    public var yOffset = CGFloat(6.0)
    
    public override init()
    {
        super.init();
    }
    
    public init(colors: [UIColor?], labels: [String?])
    {
        super.init();
        self._colors = colors;
        self._labels = labels;
        
        validateLabelsAndColors();
    }
    
    public func getMaximumEntrySize(font: UIFont) -> CGSize
    {
        var maxW = CGFloat(0.0);
        var maxH = CGFloat(0.0);
        
        for (var i = 0; i < _labels.count; i++)
        {
            if (_labels[i] == nil)
            {
                continue;
            }
            
            var size = (_labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: font]);
            
            if (size.width > maxW)
            {
                maxW = size.width;
            }
            if (size.height > maxH)
            {
                maxH = size.height;
            }
        }
        
        return CGSize(
            width: maxW + formSize + formToTextSpace,
            height: maxH
        );
    }
    
    public var colors: [UIColor?]
    {
        get
        {
            return _colors;
        }
    }
    
    public var labels: [String?]
    {
        get
        {
            return _labels;
        }
        set
        {
            _labels = newValue;
            validateLabelsAndColors();
        }
    }
    
    private func validateLabelsAndColors()
    {
        if (_labels.count != _colors.count)
        {
            println("colors array and labels array need to be of same size");
            
            while (colors.count > labels.count)
            {
                self._colors.removeLast();
            }
            while (labels.count > colors.count)
            {
                self._labels.removeLast();
            }
        }
    }
    
    public func getLabel(index: Int) -> String?
    {
        return _labels[index];
    }
    
    public func apply(legend: ChartLegend)
    {
        position = legend.position;
        direction = legend.direction;
        font = legend.font;
        textColor = legend.textColor;
        form = legend.form;
        formSize = legend.formSize;
        formLineWidth = legend.formLineWidth;
        xEntrySpace = legend.xEntrySpace;
        yEntrySpace = legend.yEntrySpace;
        formToTextSpace = legend.formToTextSpace;
        stackSpace = legend.stackSpace;
        enabled = legend.enabled;
        xOffset = legend.xOffset;
        yOffset = legend.yOffset;
    }
    
    public func getFullSize(labelFont: UIFont) -> CGSize
    {
        var width = CGFloat(0.0);
        var height = CGFloat(0.0);
        
        for (var i = 0, count = _labels.count; i < count; i++)
        {
            if (labels[i] != nil)
            {
                // make a step to the left
                if (_colors[i] != nil)
                {
                    width += formSize + formToTextSpace;
                }
                
                var size = (_labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]);
                
                width += size.width;
                height += size.height;
                
                if (i < count - 1)
                {
                    width += xEntrySpace;
                    height += yEntrySpace;
                }
            }
            else
            {
                width += formSize + stackSpace;
                
                if (i < count - 1)
                {
                    width += stackSpace;
                }
            }
        }
        
        return CGSize(width: width, height: height);
    }

    public var neededWidth = CGFloat(0.0);
    public var neededHeight = CGFloat(0.0);
    public var textWidthMax = CGFloat(0.0);
    public var textHeightMax = CGFloat(0.0);

    public func calculateDimensions(labelFont: UIFont)
    {
        var maxEntrySize = getMaximumEntrySize(labelFont);
        var fullSize = getFullSize(labelFont);
        
        if (position == .RightOfChart
            || position == .RightOfChartCenter
            || position == .LeftOfChart
            || position == .LeftOfChartCenter
            || position == .PiechartCenter)
        {
            neededWidth = maxEntrySize.width;
            neededHeight = fullSize.height;
            textWidthMax = maxEntrySize.width;
            textHeightMax = maxEntrySize.height;
        }
        else
        {
            neededWidth = fullSize.width;
            neededHeight = maxEntrySize.height;
            textWidthMax = maxEntrySize.width;
            textHeightMax = maxEntrySize.height;
        }
    }
}