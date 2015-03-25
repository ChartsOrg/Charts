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

    public var colors = [UIColor?]()
    public var labels = [String?]()
    
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
        
        self.colors = colors;
        self.labels = labels;
    }
    
    public func getMaximumEntrySize(font: UIFont) -> CGSize
    {
        var maxW = CGFloat(0.0);
        var maxH = CGFloat(0.0);
        
        var labels = self.labels;
        for (var i = 0; i < labels.count; i++)
        {
            if (labels[i] == nil)
            {
                continue;
            }
            
            var size = (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: font]);
            
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
    
    public func getLabel(index: Int) -> String?
    {
        return labels[index];
    }
    
    public func getFullSize(labelFont: UIFont) -> CGSize
    {
        var width = CGFloat(0.0);
        var height = CGFloat(0.0);
        
        var labels = self.labels;
        for (var i = 0, count = labels.count; i < count; i++)
        {
            if (labels[i] != nil)
            {
                // make a step to the left
                if (colors[i] != nil)
                {
                    width += formSize + formToTextSpace;
                }
                
                var size = (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]);
                
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