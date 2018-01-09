//
//  Fill.swift
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

@objc(ChartFillType)
public enum FillType: Int
{
    case empty
    case color
    case linearGradient
    case radialGradient
    case image
    case tiledImage
    case layer
}

@objc(ChartFill)
open class Fill: NSObject
{
    // MARK: Properties

    @objc open private(set) var type: FillType = .empty
    @objc open private(set) var color: CGColor?
    @objc open private(set) var gradient: CGGradient?
    @objc open private(set) var gradientAngle: CGFloat = 0.0
    @objc open private(set) var gradientStartOffsetPercent = CGPoint.zero
    @objc open private(set) var gradientStartRadiusPercent: CGFloat = 0.0
    @objc open private(set) var gradientEndOffsetPercent = CGPoint.zero
    @objc open private(set) var gradientEndRadiusPercent: CGFloat = 0.0
    @objc open private(set) var image: CGImage?
    @objc open private(set) var layer: CGLayer?

    // MARK: Constructors

    @objc public init(CGColor: CGColor)
    {
        type = .color
        color = CGColor
    }
    
    @objc public convenience init(color: NSUIColor)
    {
        self.init(CGColor: color.cgColor)
    }
    
    @objc public init(linearGradient: CGGradient, angle: CGFloat)
    {
        type = .linearGradient
        gradient = linearGradient
        gradientAngle = angle
    }
    
    @objc public init(
        radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        )
    {
        type = .radialGradient
        gradient = radialGradient
        gradientStartOffsetPercent = startOffsetPercent
        gradientStartRadiusPercent = startRadiusPercent
        gradientEndOffsetPercent = endOffsetPercent
        gradientEndRadiusPercent = endRadiusPercent
    }
    
    @objc public convenience init(radialGradient: CGGradient)
    {
        self.init(
            radialGradient: radialGradient,
            startOffsetPercent: CGPoint(x: 0.0, y: 0.0),
            startRadiusPercent: 0.0,
            endOffsetPercent: CGPoint(x: 0.0, y: 0.0),
            endRadiusPercent: 1.0
        )
    }
    
    @objc public init(CGImage: CGImage, tiled: Bool = false)
    {
        type = tiled ? .tiledImage : .image
        image = CGImage
    }
    
    @objc public convenience init(image: NSUIImage, tiled: Bool = false)
    {
        self.init(CGImage: image.cgImage!, tiled: tiled)
    }

    @objc public init(CGLayer: CGLayer)
    {
        type = .layer
        layer = CGLayer
    }
    
    // MARK: Constructors
    
    @objc open class func fillWithCGColor(_ CGColor: CGColor) -> Fill
    {
        return Fill(CGColor: CGColor)
    }
    
    @objc open class func fillWithColor(_ color: NSUIColor) -> Fill
    {
        return Fill(color: color)
    }
    
    @objc open class func fillWithLinearGradient(
        _ linearGradient: CGGradient,
        angle: CGFloat) -> Fill
    {
        return Fill(linearGradient: linearGradient, angle: angle)
    }
    
    @objc open class func fillWithRadialGradient(
        _ radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        ) -> Fill
    {
        return Fill(
            radialGradient: radialGradient,
            startOffsetPercent: startOffsetPercent,
            startRadiusPercent: startRadiusPercent,
            endOffsetPercent: endOffsetPercent,
            endRadiusPercent: endRadiusPercent
        )
    }
    
    @objc open class func fillWithRadialGradient(_ radialGradient: CGGradient) -> Fill
    {
        return Fill(radialGradient: radialGradient)
    }
    
    @objc open class func fillWithCGImage(_ CGImage: CGImage, tiled: Bool = false) -> Fill
    {
        return Fill(CGImage: CGImage, tiled: tiled)
    }
    
    @objc open class func fillWithImage(_ image: NSUIImage, tiled: Bool = false) -> Fill
    {
        return Fill(image: image, tiled: tiled)
    }

    @objc open class func fillWithCGLayer(_ CGLayer: CGLayer) -> Fill
    {
        return Fill(CGLayer: CGLayer)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    @objc open func fillPath(
        context: CGContext,
        rect: CGRect)
    {
        let fillType = type
        if fillType == .empty
        {
            return
        }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        switch fillType
        {
        case .color:
            
            context.setFillColor(color!)
            context.fillPath()
            
        case .image:
            
            context.clip()
            context.draw(image!, in: rect)
            
        case .tiledImage:
            
            context.clip()
            context.draw(image!, in: rect, byTiling: true)
            
        case .layer:
            
            context.clip()
            context.draw(layer!, in: rect)
            
        case .linearGradient:
            
            let radians = (360.0 - gradientAngle).DEG2RAD
            let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
            let xAngleDelta = cos(radians) * rect.width / 2.0
            let yAngleDelta = sin(radians) * rect.height / 2.0
            let startPoint = CGPoint(
                x: centerPoint.x - xAngleDelta,
                y: centerPoint.y - yAngleDelta
            )
            let endPoint = CGPoint(
                x: centerPoint.x + xAngleDelta,
                y: centerPoint.y + yAngleDelta
            )
            
            context.clip()
            context.drawLinearGradient(gradient!,
                start: startPoint,
                end: endPoint,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .radialGradient:
            
            let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
            let radius = max(rect.width, rect.height) / 2.0
            
            context.clip()
            context.drawRadialGradient(gradient!,
                startCenter: CGPoint(
                    x: centerPoint.x + rect.width * gradientStartOffsetPercent.x,
                    y: centerPoint.y + rect.height * gradientStartOffsetPercent.y
                ),
                startRadius: radius * gradientStartRadiusPercent,
                endCenter: CGPoint(
                    x: centerPoint.x + rect.width * gradientEndOffsetPercent.x,
                    y: centerPoint.y + rect.height * gradientEndOffsetPercent.y
                ),
                endRadius: radius * gradientEndRadiusPercent,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .empty:
            break
        }
    }
}
