//
//  ChartXAxis.swift
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

public class ChartXAxis: ChartAxisBase
{
    @objc
    public enum XAxisLabelPosition: Int
    {
        case Top
        case Bottom
        case BothSided
        case TopInside
        case BottomInside
    }
    
    public var values = [String]()
    public var labelWidth = CGFloat(1.0)
    public var labelHeight = CGFloat(1.0)
    
    /// the space that should be left out (in characters) between the x-axis labels
    public var spaceBetweenLabels = Int(4)
    
    /// the modulus that indicates if a value at a specified index in an array(list) for the x-axis-labels is drawn or not. Draw when (index % modulus) == 0.
    public var axisLabelModulus = Int(1)
    
    /// the modulus that indicates if a value at a specified index in an array(list) for the y-axis-labels is drawn or not. Draw when (index % modulus) == 0.
    /// Used only for Horizontal BarChart
    public var yAxisLabelModulus = Int(1)

    /// if set to true, the chart will avoid that the first and last label entry in the chart "clip" off the edge of the chart
    public var avoidFirstLastClippingEnabled = false
    
    /// if set to true, the x-axis label entries will adjust themselves when scaling the graph
    public var adjustXLabelsEnabled = true
    
    /// the position of the x-labels relative to the chart
    public var labelPosition = XAxisLabelPosition.Top;
    
    public override init()
    {
        super.init();
    }

    public override func getLongestLabel() -> String
    {
        var longest = "";
        
        for (var i = 0; i < values.count; i++)
        {
            var text = values[i];
            
            if (longest.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) < text.lengthOfBytesUsingEncoding(NSUTF16StringEncoding))
            {
                longest = text;
            }
        }
        
        return longest;
    }
    
    public var isAvoidFirstLastClippingEnabled: Bool
    {
        return avoidFirstLastClippingEnabled;
    }
    
    public var isAdjustXLabelsEnabled: Bool
    {
        return adjustXLabelsEnabled;
    }
}