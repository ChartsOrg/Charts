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
import Darwin

public class ChartUtils
{
    private static var _defaultValueFormatter: NSNumberFormatter = ChartUtils.generateDefaultValueFormatter()
    
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(M_PI / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / M_PI)
        internal static let DEG2RAD = M_PI / 180.0
        internal static let RAD2DEG = 180.0 / M_PI
    }
    
    internal class func roundToNextSignificant(number number: Double) -> Double
    {
        if (isinf(number) || isnan(number) || number == 0)
        {
            return number
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number))
        let pw = 1 - Int(d)
        let magnitude = pow(Double(10.0), Double(pw))
        let shifted = round(number * magnitude)
        return shifted / magnitude
    }
    
    internal class func decimals(number: Double) -> Int
    {
        if (number == 0.0)
        {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        return Int(ceil(-log10(i))) + 2
    }
    
    internal class func nextUp(number: Double) -> Double
    {
        if (isinf(number) || isnan(number))
        {
            return number
        }
        else
        {
            return number + DBL_EPSILON
        }
    }

    /// - returns: the index of the DataSet that contains the closest value on the y-axis. This will return -Integer.MAX_VALUE if failure.
    internal class func closestDataSetIndex(valsAtIndex: [ChartSelectionDetail], value: Double, axis: ChartYAxis.AxisDependency?) -> Int
    {
        var index = -Int.max
        var distance = DBL_MAX
        
        for (var i = 0; i < valsAtIndex.count; i++)
        {
            let sel = valsAtIndex[i]
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                let cdistance = abs(sel.value - value)
                if (cdistance < distance)
                {
                    index = valsAtIndex[i].dataSetIndex
                    distance = cdistance
                }
            }
        }
        
        return index
    }
    
    /// - returns: the minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal class func getMinimumDistance(valsAtIndex: [ChartSelectionDetail], val: Double, axis: ChartYAxis.AxisDependency) -> Double
    {
        var distance = DBL_MAX
        
        for (var i = 0, count = valsAtIndex.count; i < count; i++)
        {
            let sel = valsAtIndex[i]
            
            if (sel.dataSet!.axisDependency == axis)
            {
                let cdistance = abs(sel.value - val)
                if (cdistance < distance)
                {
                    distance = cdistance
                }
            }
        }
        
        return distance
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(center center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        )
    }
    
    public class func drawText(context context: CGContext, text: String, var point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?)
    {
        if (align == .Center)
        {
            point.x -= text.sizeWithAttributes(attributes).width / 2.0
        }
        else if (align == .Right)
        {
            point.x -= text.sizeWithAttributes(attributes).width
        }
        
        UIGraphicsPushContext(context)
        
        (text as NSString).drawAtPoint(point, withAttributes: attributes)
        
        UIGraphicsPopContext()
    }
    
    public class func drawText(context context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, anchor: CGPoint, angleRadians: CGFloat)
    {
        var drawOffset = CGPoint()
        
        UIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            let size = text.sizeWithAttributes(attributes)
            
            // Move the text drawing rect in a way that it always rotates around its center
            drawOffset.x = -size.width * 0.5
            drawOffset.y = -size.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = sizeOfRotatedRectangle(size, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, translate.x, translate.y)
            CGContextRotateCTM(context, angleRadians)
            
            (text as NSString).drawAtPoint(drawOffset, withAttributes: attributes)
            
            CGContextRestoreGState(context)
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                let size = text.sizeWithAttributes(attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).drawAtPoint(drawOffset, withAttributes: attributes)
        }
        
        UIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context context: CGContext, text: String, knownTextSize: CGSize, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        var rect = CGRect(origin: CGPoint(), size: knownTextSize)
        
        UIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            // Move the text drawing rect in a way that it always rotates around its center
            rect.origin.x = -knownTextSize.width * 0.5
            rect.origin.y = -knownTextSize.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = sizeOfRotatedRectangle(knownTextSize, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, translate.x, translate.y)
            CGContextRotateCTM(context, angleRadians)
            
            (text as NSString).drawWithRect(rect, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            
            CGContextRestoreGState(context)
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                rect.origin.x = -knownTextSize.width * anchor.x
                rect.origin.y = -knownTextSize.height * anchor.y
            }
            
            rect.origin.x += point.x
            rect.origin.y += point.y
            
            (text as NSString).drawWithRect(rect, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        
        UIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        let rect = text.boundingRectWithSize(constrainedToSize, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(context: context, text: text, knownTextSize: rect.size, point: point, attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    /// - returns: an angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal class func normalizedAngleFromAngle(var angle: CGFloat) -> CGFloat
    {
        while (angle < 0.0)
        {
            angle += 360.0
        }
        
        return angle % 360.0
    }
    
    private class func generateDefaultValueFormatter() -> NSNumberFormatter
    {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.usesGroupingSeparator = true
        return formatter
    }
    
    /// - returns: the default value formatter used for all chart components that needs a default
    internal class func defaultValueFormatter() -> NSNumberFormatter
    {
        return _defaultValueFormatter
    }
    
    internal class func sizeOfRotatedRectangle(rectangleSize: CGSize, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleSize: CGSize, radians: CGFloat) -> CGSize
    {
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth rectangleWidth: CGFloat, rectangleHeight: CGFloat, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleWidth, rectangleHeight: rectangleHeight, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth rectangleWidth: CGFloat, rectangleHeight: CGFloat, radians: CGFloat) -> CGSize
    {
        return CGSize(
            width: abs(rectangleWidth * cos(radians)) + abs(rectangleHeight * sin(radians)),
            height: abs(rectangleWidth * sin(radians)) + abs(rectangleHeight * cos(radians))
        )
    }
    
    /// MARK: - Bridging functions
    
    internal class func bridgedObjCGetUIColorArray (swift array: [UIColor?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if (val == nil)
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val!)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetUIColorArray (objc array: [NSObject]) -> [UIColor?]
    {
        var newArray = [UIColor?]()
        for object in array
        {
            newArray.append(object as? UIColor)
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (swift array: [String?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if (val == nil)
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val!)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (objc array: [NSObject]) -> [String?]
    {
        var newArray = [String?]()
        for object in array
        {
            newArray.append(object as? String)
        }
        return newArray
    }
}