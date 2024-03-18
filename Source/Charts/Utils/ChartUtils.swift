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

    public func drawText(_ text: String, at point: CGPoint, align: TextAlignment, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat = 0.0, attributes: [NSAttributedString.Key : Any]?, isUpperSemicircle:Bool = false, drawWithWidth:Bool = false, maxWidth:CGFloat? = nil, maxHeight:CGFloat? = nil)
    {
        var mutableAttributes = attributes
        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.0
        paragraphStyle.lineBreakMode = .byCharWrapping
        if align == .right {
            paragraphStyle.alignment = .right
        }
        mutableAttributes?.updateValue(paragraphStyle, forKey: .paragraphStyle)
        let font:NSUIFont = mutableAttributes?[.font] as! NSUIFont
        let twoLineHeight = font.pointSize * 2 + paragraphStyle.lineSpacing
        let textMaxWidth = font.pointSize * 6 + 1
        
        var height:CGFloat? = nil
        var width:CGFloat? = nil
        var x:CGFloat? = nil
        var y:CGFloat? = nil
        var subText:String? = nil
        
        subText = text.count > 12 ? text.prefix(11) + "…" : text
        var displayText = subText != nil ? subText! : text
        
        var drawPoint = getDrawPoint(text: displayText, point: point, align: align, attributes: mutableAttributes, isUpperSemicircle: isUpperSemicircle, maxWidth: maxWidth)
        if drawWithWidth {
            guard let maxWidth = maxWidth else {
                return
            }
            let size = displayText.size(withAttributes: mutableAttributes)
            height = displayText.count > 6 ? twoLineHeight : font.pointSize
            width = align == .center ? ceil(size.width) + 1 : (ceil(size.width) < textMaxWidth ? ceil(size.width) + 1 : textMaxWidth)
            x = drawPoint.x
            y = drawPoint.y
            if drawPoint.x < 0 {
                height = twoLineHeight
                width! += drawPoint.x
                x = 0
            } else if drawPoint.x + width! > maxWidth {
                height = twoLineHeight
                width! -= drawPoint.x + width! - maxWidth
            }
            
            if let maxHeight = maxHeight {
                if drawPoint.y < 0 {
                    drawPoint.y += font.pointSize + paragraphStyle.lineSpacing
                    y = drawPoint.y
                    height = font.pointSize
                } else if drawPoint.y + (height ?? font.pointSize) > maxHeight {
                    height = font.pointSize
                }
            }
            
        }
        
        if (angleRadians == 0.0)
        {
            NSUIGraphicsPushContext(self)
            
            if var width = width, let height = height, let x = x, let y = y {
                if width < font.pointSize {
                    width = font.pointSize
                }
                let maxDisplayTextCount:Int = Int(width / font.pointSize) * Int(height / font.pointSize)
                if displayText.count > 6 && displayText.count > maxDisplayTextCount {
                    displayText = text.prefix(maxDisplayTextCount - 1) + "…"
                }
                (displayText as NSString).draw(in: CGRect.init(x: x, y: y, width: width, height: height), withAttributes: mutableAttributes)
            } else {
                (displayText as NSString).draw(at: drawPoint, withAttributes: mutableAttributes)
            }
            
            NSUIGraphicsPopContext()
        }
        else
        {
            drawText(displayText, at: drawPoint, anchor: anchor, angleRadians: angleRadians, attributes: mutableAttributes, width: width, height: height)
        }
    }
    

    public func drawText(_ text: String, at point: CGPoint, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat, attributes: [NSAttributedString.Key : Any]?, width: CGFloat? = nil, height: CGFloat? = nil)
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

            if let width = width, let height = height{
                (text as NSString).draw(in: CGRect.init(x: drawOffset.x, y: drawOffset.y, width: width, height: height), withAttributes: attributes)
            } else {
                (text as NSString).draw(at: drawOffset, withAttributes: attributes)
            }

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

    private func getDrawPoint(text: String, point: CGPoint, align: TextAlignment, attributes: [NSAttributedString.Key : Any]?, isUpperSemicircle:Bool = false, maxWidth:CGFloat? = nil) -> CGPoint
    {
        var point = point
        let size = text.size(withAttributes: attributes)
        let font:NSUIFont = attributes?[.font] as! NSUIFont
        let paragraphStyle:ParagraphStyle = attributes?[.paragraphStyle] as! ParagraphStyle
        let textMaxWidth = font.pointSize * 6 + 1

        if align == .center
        {
            point.x -= size.width / 2.0 - 5.0
        }
        else if align == .right
        {
            point.x -= size.width < textMaxWidth ? size.width : textMaxWidth
        }
        else if align == .left
        {
            point.x -= 4.0
        }
        
        if (align != .center && isUpperSemicircle && size.width > textMaxWidth) {
            point.y -= text.count > 6 ? font.pointSize + paragraphStyle.lineSpacing : font.pointSize
        } else if point.x < 0 && isUpperSemicircle {
            point.y -= font.pointSize + paragraphStyle.lineSpacing
        } else if let maxWidth = maxWidth {
            if (maxWidth - point.x < min(size.width, textMaxWidth) && isUpperSemicircle) {
                point.y -= font.pointSize + paragraphStyle.lineSpacing
            }
        } else if align == .center && isUpperSemicircle {
            point.y -= 4.0
        } else if align == .center && !isUpperSemicircle {
            point.y += 4.0
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
