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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class ChartUtils
{
    private static var _defaultValueFormatter: NumberFormatter = ChartUtils.generateDefaultValueFormatter()
    
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(M_PI / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / M_PI)
        internal static let DEG2RAD = M_PI / 180.0
        internal static let RAD2DEG = 180.0 / M_PI
    }
    
    internal class func roundToNextSignificant(number: Double) -> Double
    {
        if number.isInfinite || number.isNaN || number == 0
        {
            return number
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number))
        let pw = 1 - Int(d)
        let magnitude = pow(Double(10.0), Double(pw))
        let shifted = round(number * magnitude)
        return shifted / magnitude
    }
    
    internal class func decimals(_ number: Double) -> Int
    {
        if (number == 0.0)
        {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        return Int(ceil(-log10(i))) + 2
    }
    
    internal class func nextUp(_ number: Double) -> Double
    {
        if number.isInfinite || number.isNaN
        {
            return number
        }
        else
        {
            return number + DBL_EPSILON
        }
    }
    
    /// - returns: the index of the DataSet that contains the closest value on the y-axis
    internal class func closestDataSetIndexByPixelY(
        valsAtIndex: [ChartSelectionDetail],
                    y: CGFloat,
                    axis: ChartYAxis.AxisDependency?) -> Int?
    {
        return closestSelectionDetailByPixelY(valsAtIndex: valsAtIndex, y: y, axis: axis)?.dataSetIndex
    }
    
    /// - returns: the index of the DataSet that contains the closest value on the y-axis
    internal class func closestDataSetIndexByValue(
        valsAtIndex: [ChartSelectionDetail],
                    value: Double,
                    axis: ChartYAxis.AxisDependency?) -> Int?
    {
        return closestSelectionDetailByValue(valsAtIndex: valsAtIndex, value: value, axis: axis)?.dataSetIndex
    }
    
    /// - returns: the `ChartSelectionDetail` of the closest value on the y-axis
    internal class func closestSelectionDetailByPixelY(
        valsAtIndex: [ChartSelectionDetail],
                    y: CGFloat,
                    axis: ChartYAxis.AxisDependency?) -> ChartSelectionDetail?
    {
        var distance = CGFloat.greatestFiniteMagnitude
        var detail: ChartSelectionDetail?
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                let cdistance = abs(sel.y - y)
                if (cdistance < distance)
                {
                    detail = sel
                    distance = cdistance
                }
            }
        }
        
        return detail
    }
    
    /// - returns: the `ChartSelectionDetail` of the closest value on the y-axis
    internal class func closestSelectionDetailByValue(
        valsAtIndex: [ChartSelectionDetail],
                    value: Double,
                    axis: ChartYAxis.AxisDependency?) -> ChartSelectionDetail?
    {
        var distance = DBL_MAX
        var detail: ChartSelectionDetail?
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                let cdistance = abs(sel.value - value)
                if (cdistance < distance)
                {
                    detail = sel
                    distance = cdistance
                }
            }
        }
        
        return detail
    }
    
    /// - returns: the minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal class func getMinimumDistance(
        _ valsAtIndex: [ChartSelectionDetail],
        y: CGFloat,
        axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        var distance = CGFloat.greatestFiniteMagnitude
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (sel.dataSet!.axisDependency == axis)
            {
                let cdistance = abs(sel.y - y)
                if (cdistance < distance)
                {
                    distance = cdistance
                }
            }
        }
        
        return distance
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        )
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?)
    {
        var point = point
        
        if (align == .center)
        {
            point.x -= text.size(attributes: attributes).width / 2.0
        }
        else if (align == .right)
        {
            point.x -= text.size(attributes: attributes).width
        }
        
        NSUIGraphicsPushContext(context)
        
        (text as NSString).draw(at: point, withAttributes: attributes)
        
        NSUIGraphicsPopContext()
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, anchor: CGPoint, angleRadians: CGFloat)
    {
        var drawOffset = CGPoint()
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            let size = text.size(attributes: attributes)
            
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
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
            
            context.restoreGState()
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                let size = text.size(attributes: attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, knownTextSize: CGSize, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        var rect = CGRect(origin: CGPoint(), size: knownTextSize)
        
        NSUIGraphicsPushContext(context)
        
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
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            context.restoreGState()
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
            
            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        let rect = text.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(context: context, text: text, knownTextSize: rect.size, point: point, attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    /// - returns: an angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal class func normalizedAngleFromAngle(_ angle: CGFloat) -> CGFloat
    {
        var angle = angle
        
        while (angle < 0.0)
        {
            angle += 360.0
        }
        
        return angle.truncatingRemainder(dividingBy: 360.0)
    }
    
    private class func generateDefaultValueFormatter() -> NumberFormatter
    {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.usesGroupingSeparator = true
        return formatter
    }
    
    /// - returns: the default value formatter used for all chart components that needs a default
    internal class func defaultValueFormatter() -> NumberFormatter
    {
        return _defaultValueFormatter
    }
    
    internal class func sizeOfRotatedRectangle(_ rectangleSize: CGSize, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(_ rectangleSize: CGSize, radians: CGFloat) -> CGSize
    {
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleWidth, rectangleHeight: rectangleHeight, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, radians: CGFloat) -> CGSize
    {
        return CGSize(
            width: abs(rectangleWidth * cos(radians)) + abs(rectangleHeight * sin(radians)),
            height: abs(rectangleWidth * sin(radians)) + abs(rectangleHeight * cos(radians))
        )
    }
    
    /// MARK: - Bridging functions
    
    internal class func bridgedObjCGetNSUIColorArray (swift array: [NSUIColor?]) -> [NSObject]
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
    
    internal class func bridgedObjCGetNSUIColorArray (objc array: [NSObject]) -> [NSUIColor?]
    {
        var newArray = [NSUIColor?]()
        for object in array
        {
            newArray.append(object as? NSUIColor)
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
                newArray.append(val! as NSObject)
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
