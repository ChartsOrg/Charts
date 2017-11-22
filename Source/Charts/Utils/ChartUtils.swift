//
//  Utils.swift
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

#if !os(OSX)
    import UIKit
#endif

extension CGSize {
    func rotatedBy(degrees: CGFloat) -> CGSize {
        let radians = ChartUtils.Math.FDEG2RAD * degrees
        return rotatedBy(radians: radians)
    }

    func rotatedBy(radians: CGFloat) -> CGSize {
        return CGSize(
            width: abs(width * cos(radians)) + abs(height * sin(radians)),
            height: abs(width * sin(radians)) + abs(height * cos(radians))
        )
    }
}

open class ChartUtils
{
    fileprivate static var _defaultValueFormatter: IValueFormatter = ChartUtils.generateDefaultValueFormatter()
    
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(Double.pi / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / Double.pi)
        internal static let DEG2RAD = Double.pi / 180.0
        internal static let RAD2DEG = 180.0 / Double.pi
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
        if number.isNaN || number.isInfinite || number == 0.0
        {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        
        if i.isInfinite || i.isNaN
        {
            return 0
        }
        
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
            return number + Double.ulpOfOne
        }
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        )
    }
    
    open class func drawImage(
        context: CGContext,
        image: NSUIImage,
        x: CGFloat,
        y: CGFloat,
        size: CGSize)
    {
        var drawOffset = CGPoint()
        drawOffset.x = x - (size.width / 2)
        drawOffset.y = y - (size.height / 2)
        
        NSUIGraphicsPushContext(context)
        
        if image.size.width != size.width && image.size.height != size.height
        {
            let key = "resized_\(size.width)_\(size.height)"
            
            // Try to take scaled image from cache of this image
            var scaledImage = objc_getAssociatedObject(image, key) as? NSUIImage
            if scaledImage == nil
            {
                // Scale the image
                NSUIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                
                image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
                
                scaledImage = NSUIGraphicsGetImageFromCurrentImageContext()
                NSUIGraphicsEndImageContext()
                
                // Put the scaled image in a cache owned by the original image
                objc_setAssociatedObject(image, key, scaledImage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            scaledImage?.draw(in: CGRect(origin: drawOffset, size: size))
        }
        else
        {
            image.draw(in: CGRect(origin: drawOffset, size: size))
        }
        
        NSUIGraphicsPopContext()
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [NSAttributedStringKey : Any]?)
    {
        var point = point
        
        if align == .center
        {
            point.x -= text.size(withAttributes: attributes).width / 2.0
        }
        else if align == .right
        {
            point.x -= text.size(withAttributes: attributes).width
        }
        
        NSUIGraphicsPushContext(context)
        
        (text as NSString).draw(at: point, withAttributes: attributes)
        
        NSUIGraphicsPopContext()
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, attributes: [NSAttributedStringKey : Any]?, anchor: CGPoint, angleRadians: CGFloat)
    {
        var drawOffset = CGPoint()
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            let size = text.size(withAttributes: attributes)
            
            // Move the text drawing rect in a way that it always rotates around its center
            drawOffset.x = -size.width * 0.5
            drawOffset.y = -size.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = size.rotatedBy(radians: angleRadians)
                
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
                let size = text.size(withAttributes: attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, knownTextSize: CGSize, point: CGPoint, attributes: [NSAttributedStringKey : Any]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
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
                let rotatedSize = knownTextSize.rotatedBy(radians: angleRadians)
                
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
    
    internal class func drawMultilineText(context: CGContext, text: String, point: CGPoint, attributes: [NSAttributedStringKey : Any]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        let rect = text.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(context: context, text: text, knownTextSize: rect.size, point: point, attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    /// - returns: An angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal class func normalizedAngleFromAngle(_ angle: CGFloat) -> CGFloat
    {
        var angle = angle
        
        while (angle < 0.0)
        {
            angle += 360.0
        }
        
        return angle.truncatingRemainder(dividingBy: 360.0)
    }
    
    fileprivate class func generateDefaultValueFormatter() -> IValueFormatter
    {
        let formatter = DefaultValueFormatter(decimals: 1)
        return formatter
    }
    
    /// - returns: The default value formatter used for all chart components that needs a default
    open class func defaultValueFormatter() -> IValueFormatter
    {
        return _defaultValueFormatter
    }

    /// MARK: - Bridging functions
    
    internal class func bridgedObjCGetNSUIColorArray (swift array: [NSUIColor?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if val == nil
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
            if val == nil
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
