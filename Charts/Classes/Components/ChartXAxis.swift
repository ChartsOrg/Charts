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
    /// This only applies if the number of labels that will be skipped in between drawn axis labels is not custom set.
    /// :default: 4
    public var spaceBetweenLabels = Int(4)
    
    /// the modulus that indicates if a value at a specified index in an array(list) for the x-axis-labels is drawn or not. Draw when (index % modulus) == 0.
    public var axisLabelModulus = Int(1) {
        didSet {
            updateAxisLabelModulus()
        }
    }
    
    /// the modulus that makes sure that certain indexes are drawn, unless there are too many.
    public var requieredAxisLabelModulus: Int? {
        didSet {
            updateAxisLabelModulus()
        }
    }
    
    //changes the axisLabelModulus to an higher value that matches the requieredAxisLabelModulus
    private func updateAxisLabelModulus() {
        if let reqModulus = requieredAxisLabelModulus {
            if reqModulus % axisLabelModulus != 0 && axisLabelModulus % reqModulus != 0{
                if reqModulus > axisLabelModulus {
                    var newModulus = reqModulus
                    for var i = 2; i < reqModulus && reqModulus % reqModulus / i == 0; i *= 2 {
                        if reqModulus / i >= axisLabelModulus {
                            newModulus = reqModulus / i
                        }
                    }
                    axisLabelModulus = newModulus
                } else {
                    axisLabelModulus = (axisLabelModulus / reqModulus + 1) * reqModulus
                }
            }
        }
    }

    
    /// Is axisLabelModulus a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// :default: false (automatic modulus)
    private var _isAxisModulusCustom = false

    /// the modulus that indicates if a value at a specified index in an array(list) for the y-axis-labels is drawn or not. Draw when (index % modulus) == 0.
    /// Used only for Horizontal BarChart
    public var yAxisLabelModulus = Int(1)

    /// if set to true, the chart will avoid that the first and last label entry in the chart "clip" off the edge of the chart
    public var avoidFirstLastClippingEnabled = false
    
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

    /// Sets the number of labels that should be skipped on the axis before the next label is drawn. 
    /// This will disable the feature that automatically calculates an adequate space between the axis labels and set the number of labels to be skipped to the fixed number provided by this method. 
    /// Call resetLabelsToSkip(...) to re-enable automatic calculation.
    public func setLabelsToSkip(var count: Int)
    {
        if (count < 0)
        {
            count = 0;
        }
        
        _isAxisModulusCustom = true;
        axisLabelModulus = count + 1;
    }
    
    /// Calling this will disable a custom number of labels to be skipped (set by setLabelsToSkip(...)) while drawing the x-axis. Instead, the number of values to skip will again be calculated automatically.
    public func resetLabelsToSkip()
    {
        _isAxisModulusCustom = false;
    }
    
    /// Returns true if a custom axis-modulus has been set that determines the number of labels to skip when drawing.
    public var isAxisModulusCustom: Bool
    {
        return _isAxisModulusCustom;
    }
}