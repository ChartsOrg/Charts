//
//  Utils.swift
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
import Darwin;

internal class ChartUtils
{
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(M_PI / 180.0);
        internal static let FRAD2DEG = CGFloat(180.0 / M_PI);
        internal static let DEG2RAD = M_PI / 180.0;
        internal static let RAD2DEG = 180.0 / M_PI;
    };
    
    internal class func roundToNextSignificant(#number: Double) -> Double
    {
        if (isinf(number) || isnan(number) || number == 0)
        {
            return number;
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number));
        let pw = 1 - Int(d);
        let magnitude = pow(Double(10.0), Double(pw));
        let shifted = round(number * magnitude);
        return shifted / magnitude;
    }
    
    internal class func decimals(number: Float) -> Int
    {
        if (number == 0.0)
        {
            return 0;
        }
        
        var i = roundToNextSignificant(number: Double(number));
        return Int(ceil(-log10(i))) + 2;
    }
    
    internal class func nextUp(number: Double) -> Double
    {
        if (isinf(number) || isnan(number))
        {
            return number;
        }
        else
        {
            return number + DBL_EPSILON;
        }
    }

    /// Returns the index of the DataSet that contains the closest value on the y-axis. This is needed for highlighting.
    internal class func closestDataSetIndex(valsAtIndex: [ChartSelInfo], value: Float, axis: AxisDependency?) -> Int
    {
        var index = -1;
        var distance = FLT_MAX;
        
        for (var i = 0; i < valsAtIndex.count; i++)
        {
            var sel = valsAtIndex[i];
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                var cdistance = abs(sel.value - value);
                if (cdistance < distance)
                {
                    index = valsAtIndex[i].dataSetIndex;
                    distance = cdistance;
                }
            }
        }
        
        return index;
    }
    
    /// Returns the minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal class func getMinimumDistance(valsAtIndex: [ChartSelInfo], val: Float, axis: AxisDependency) -> Float
    {
        var distance = FLT_MAX;
        
        for (var i = 0, count = valsAtIndex.count; i < count; i++)
        {
            var sel = valsAtIndex[i];
            
            if (sel.dataSet!.axisDependency == axis)
            {
                var cdistance = abs(sel.value - val);
                if (cdistance < distance)
                {
                    distance = cdistance;
                }
            }
        }
        
        return distance;
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(#center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        );
    }
    
    internal class func drawText(#context: CGContext, text: String, var point: CGPoint, align: NSTextAlignment, attributes: [NSObject : AnyObject]?)
    {
        if (align == .Center)
        {
            point.x -= text.sizeWithAttributes(attributes).width / 2.0;
        }
        else if (align == .Right)
        {
            point.x -= text.sizeWithAttributes(attributes).width;
        }
        
        UIGraphicsPushContext(context);
        (text as NSString).drawAtPoint(point, withAttributes: attributes);
        UIGraphicsPopContext();
    }
}