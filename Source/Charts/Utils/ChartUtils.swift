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

extension Comparable
{
    func clamped(to range: ClosedRange<Self>) -> Self
    {
        if self > range.upperBound
        {
            return range.upperBound
        }
        else if self < range.lowerBound
        {
            return range.lowerBound
        }
        else
        {
            return self
        }
    }
}

extension FloatingPoint
{
    var DEG2RAD: Self
    {
        return self * .pi / 180
    }

    var RAD2DEG: Self
    {
        return self * 180 / .pi
    }

    /// - Note: Value must be in degrees
    /// - Returns: An angle between 0.0 < 360.0 (not less than zero, less than 360)
    var normalizedAngle: Self
    {
        let angle = truncatingRemainder(dividingBy: 360)
        return (sign == .minus) ? angle + 360 : angle
    }
}

extension CGSize
{
    func rotatedBy(degrees: CGFloat) -> CGSize
    {
        let radians = degrees.DEG2RAD
        return rotatedBy(radians: radians)
    }

    func rotatedBy(radians: CGFloat) -> CGSize
    {
        return CGSize(
            width: abs(width * cos(radians)) + abs(height * sin(radians)),
            height: abs(width * sin(radians)) + abs(height * cos(radians))
        )
    }
}

extension Double
{
    /// Rounds the number to the nearest multiple of it's order of magnitude, rounding away from zero if halfway.
    func roundedToNextSignificant() -> Double
    {
        guard
            !isInfinite,
            !isNaN,
            self != 0
            else { return self }

        let d = ceil(log10(self < 0 ? -self : self))
        let pw = 1 - Int(d)
        let magnitude = pow(10.0, Double(pw))
        let shifted = (self * magnitude).rounded()
        return shifted / magnitude
    }

    var decimalPlaces: Int
    {
        guard
            !isNaN,
            !isInfinite,
            self != 0.0
            else { return 0 }

        let i = roundedToNextSignificant()

        guard
            !i.isInfinite,
            !i.isNaN
            else { return 0 }

        return Int(ceil(-log10(i))) + 2
    }
    
    static func middleMagnitude(_ x: Double, _ y: Double) -> Double {
        return min(x, y) + (max(x, y) - min(x, y)) / 2
    }
}

extension CGPoint
{
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    func moving(distance: CGFloat, atAngle angle: CGFloat) -> CGPoint
    {
        return CGPoint(x: x + distance * cos(angle.DEG2RAD),
                       y: y + distance * sin(angle.DEG2RAD))
    }
}

extension CGContext
{

    public func drawImage(_ image: NSUIImage, atCenter center: CGPoint, size: CGSize)
    {
        var drawOffset = CGPoint()
        drawOffset.x = center.x - (size.width / 2)
        drawOffset.y = center.y - (size.height / 2)

        NSUIGraphicsPushContext(self)

        if image.size.width != size.width && image.size.height != size.height
        {
            let key = "resized_\(size.width)_\(size.height)"

            // Try to take scaled image from cache of this image
            var scaledImage = objc_getAssociatedObject(image, key) as? NSUIImage
            if scaledImage == nil
            {
                // Scale the image
                NSUIGraphicsBeginImageContextWithOptions(size, false, 0.0)

                image.draw(in: CGRect(origin: .zero, size: size))

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

    public func drawText(_ text: String, at point: CGPoint, align: TextAlignment, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat = 0.0, attributes: [NSAttributedString.Key : Any]?)
    {
        let drawPoint = getDrawPoint(text: text, point: point, align: align, attributes: attributes)
        
        if (angleRadians == 0.0)
        {
            NSUIGraphicsPushContext(self)
            
            (text as NSString).draw(at: drawPoint, withAttributes: attributes)
            
            NSUIGraphicsPopContext()
        }
        else
        {
            drawText(text, at: drawPoint, anchor: anchor, angleRadians: angleRadians, attributes: attributes)
        }
    }
    
    public func drawText(_ text: String, at point: CGPoint, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat, attributes: [NSAttributedString.Key : Any]?)
    {
        var drawOffset = CGPoint()

        NSUIGraphicsPushContext(self)

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

            saveGState()
            translateBy(x: translate.x, y: translate.y)
            rotate(by: angleRadians)

            (text as NSString).draw(at: drawOffset, withAttributes: attributes)

            restoreGState()
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

    private func getDrawPoint(text: String, point: CGPoint, align: TextAlignment, attributes: [NSAttributedString.Key : Any]?) -> CGPoint
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
        return point
    }
    
    func drawMultilineText(_ text: String, at point: CGPoint, constrainedTo size: CGSize, anchor: CGPoint, knownTextSize: CGSize, angleRadians: CGFloat, attributes: [NSAttributedString.Key : Any]?)
    {
        var rect = CGRect(origin: .zero, size: knownTextSize)

        NSUIGraphicsPushContext(self)

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

            saveGState()
            translateBy(x: translate.x, y: translate.y)
            rotate(by: angleRadians)

            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

            restoreGState()
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

    func drawMultilineText(_ text: String, at point: CGPoint, constrainedTo size: CGSize, anchor: CGPoint, angleRadians: CGFloat, attributes: [NSAttributedString.Key : Any]?)
    {
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(text, at: point, constrainedTo: size, anchor: anchor, knownTextSize: rect.size, angleRadians: angleRadians, attributes: attributes)
    }
}


extension UIBezierPath {
    /*
    **************************************
    *a.x-1, a.y+diff    b.x+1, b.y + diff*
    *      a--------------------b        *
    *a.x -1, a.y-diff     b.x+1, b.y-diff*
    **************************************
     */
    static func singleLinePath(points: [CGPoint], pathWidth: CGFloat) -> UIBezierPath {
        let calculateBezierPath = UIBezierPath()
        
        if points.count >= 2 {
            let firstPoint = points.first!
            let lastPoint = points.last!
            let angle = fabs(Double(atan((firstPoint.y - lastPoint.y) / (firstPoint.x - lastPoint.x))))
            
            let distanceX = CGFloat(fabs(sin(angle))) * pathWidth
            let distanceY = CGFloat(fabs(cos(angle))) * pathWidth

            var point1 = CGPoint(x: firstPoint.x + distanceX, y: firstPoint.y + distanceY)
            var point2 = CGPoint(x: firstPoint.x - distanceX, y: firstPoint.y - distanceY)
            var point3 = CGPoint(x: lastPoint.x - distanceX, y: lastPoint.y - distanceY)
            var point4 = CGPoint(x: lastPoint.x + distanceX, y: lastPoint.y + distanceY)
                        
            if firstPoint.x < lastPoint.x && firstPoint.y < lastPoint.y {
                point1 = CGPoint(x: firstPoint.x + distanceX, y: firstPoint.y - distanceY)
                point2 = CGPoint(x: firstPoint.x - distanceX, y: firstPoint.y + distanceY)
                point3 = CGPoint(x: lastPoint.x - distanceX, y: lastPoint.y + distanceY)
                point4 = CGPoint(x: lastPoint.x + distanceX, y: lastPoint.y - distanceY)
            } else if (lastPoint.x < firstPoint.x && lastPoint.y < firstPoint.y) {
                point1 = CGPoint(x: firstPoint.x - distanceX, y: firstPoint.y + distanceY)
                point2 = CGPoint(x: firstPoint.x + distanceX, y: firstPoint.y - distanceY)
                point3 = CGPoint(x: lastPoint.x + distanceX, y: lastPoint.y - distanceY)
                point4 = CGPoint(x: lastPoint.x - distanceX, y: lastPoint.y + distanceY)
            } else if (lastPoint.x < firstPoint.x && lastPoint.y > firstPoint.y) {
                point1 = CGPoint(x: firstPoint.x + distanceX, y: firstPoint.y + distanceY)
                point2 = CGPoint(x: firstPoint.x - distanceX, y: firstPoint.y - distanceY)
                point3 = CGPoint(x: lastPoint.x - distanceX, y: lastPoint.y - distanceY)
                point4 = CGPoint(x: lastPoint.x + distanceX, y: lastPoint.y + distanceY)
            }
            
            calculateBezierPath.move(to: point1)
            calculateBezierPath.addLine(to: point2)
            calculateBezierPath.addLine(to: point3)
            calculateBezierPath.addLine(to: point4)
        }
        return calculateBezierPath
    }
    
    
    static func closedGraphicsPath(points: [CGPoint]) -> UIBezierPath {
        let calculateBezierPath = UIBezierPath()
        if points.count > 0 {
            let point = points.first!
            calculateBezierPath.move(to: point)
            points.forEach {
                calculateBezierPath.addLine(to: $0)
            }
            calculateBezierPath.close()
        }
        return calculateBezierPath
    }
}


class FibonacciPeriod {
    static public func getFibonacciSequenceBy(begin: Double, next: Double, count: Int) -> [Double] {
        
        let space = max(0, fabs(begin - next))
        let leftDirection = begin - next > 0
        var result = Array(repeating: 0.0, count: count)
        result[0] = 0
        result[1] = 1
        
        for index in stride(from: 2, to: count, by: +1) {
            result[index] = result[index - 1] + result[index - 2]
        }
        
        for index in stride(from: 0, to: count, by: +1) {
            if index == 0 {
                result[index] = begin
            } else {
                if leftDirection {
                    result[index] = result[index - 1] - space * result[index]
                } else {
                    result[index] = result[index - 1] + space * result[index]
                }
            }
        }
                
        return result
    }
}
