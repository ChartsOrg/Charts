//
//  ChartFill.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/01/2016.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics
import QuartzCore

public class ChartFill: NSObject
{
    @objc(ChartFillType)
    public enum ChartFillType: Int
    {
        case empty
        case color
        case linearGradient
        case radialGradient
        case image
        case tiledImage
        case layer
    }
    
    private var _type: ChartFillType = ChartFillType.empty
    private var _color: CGColor?
    private var _gradient: CGGradient?
    private var _gradientAngle: CGFloat = 0.0
    private var _gradientStartOffsetPercent: CGPoint = CGPoint()
    private var _gradientStartRadiusPercent: CGFloat = 0.0
    private var _gradientEndOffsetPercent: CGPoint = CGPoint()
    private var _gradientEndRadiusPercent: CGFloat = 0.0
    private var _image: CGImage?
    private var _layer: CGLayer?
    
    // MARK: Properties
    
    public var type: ChartFillType
    {
        return _type
    }
    
    public var color: CGColor?
    {
        return _color
    }
    
    public var gradient: CGGradient?
    {
        return _gradient
    }
    
    public var gradientAngle: CGFloat
    {
        return _gradientAngle
    }
    
    public var gradientStartOffsetPercent: CGPoint
    {
        return _gradientStartOffsetPercent
    }
    
    public var gradientStartRadiusPercent: CGFloat
    {
        return _gradientStartRadiusPercent
    }
    
    public var gradientEndOffsetPercent: CGPoint
    {
        return _gradientEndOffsetPercent
    }
    
    public var gradientEndRadiusPercent: CGFloat
    {
        return _gradientEndRadiusPercent
    }
    
    public var image: CGImage?
    {
        return _image
    }
    
    public var layer: CGLayer?
    {
        return _layer
    }
    
    // MARK: Constructors
    
    public override init()
    {
    }
    
    public init(color: CGColor)
    {
        _type = .color
        _color = color
    }
    
    public convenience init(nsuiColor: NSUIColor)
    {
        self.init(color: nsuiColor.cgColor)
    }
    
    public init(linearGradient: CGGradient, angle: CGFloat)
    {
        _type = .linearGradient
        _gradient = linearGradient
        _gradientAngle = angle
    }
    
    public init(
        radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        )
    {
        _type = .radialGradient
        _gradient = radialGradient
        _gradientStartOffsetPercent = startOffsetPercent
        _gradientStartRadiusPercent = startRadiusPercent
        _gradientEndOffsetPercent = endOffsetPercent
        _gradientEndRadiusPercent = endRadiusPercent
    }
    
    public convenience init(radialGradient: CGGradient)
    {
        self.init(
            radialGradient: radialGradient,
            startOffsetPercent: CGPoint(x: 0.0, y: 0.0),
            startRadiusPercent: 0.0,
            endOffsetPercent: CGPoint(x: 0.0, y: 0.0),
            endRadiusPercent: 1.0
        )
    }
    
    public init(image: CGImage, tiled: Bool)
    {
        _type = tiled ? .tiledImage : .image
        _image = image
    }
    
    public convenience init(nsuiImage: NSUIImage, tiled: Bool)
    {
        if nsuiImage.cgImage == nil
        {
            self.init()
        }
        else
        {
            self.init(image: nsuiImage.cgImage!, tiled: tiled)
        }
    }
    
    public convenience init(image: CGImage)
    {
        self.init(image: image, tiled: false)
    }
    
    public convenience init(nsuiImage: NSUIImage)
    {
        self.init(nsuiImage: nsuiImage, tiled: false)
    }
    
    public init(layer: CGLayer)
    {
        _type = .layer
        _layer = layer
    }
    
    // MARK: Constructors
    
    public class func fillWithCGColor(_ color: CGColor) -> ChartFill
    {
        return ChartFill(color: color)
    }
    
    public class func fillWithColor(_ color: NSUIColor) -> ChartFill
    {
        return ChartFill(nsuiColor: color)
    }
    
    public class func fillWithLinearGradient(_ linearGradient: CGGradient, angle: CGFloat) -> ChartFill
    {
        return ChartFill(linearGradient: linearGradient, angle: angle)
    }
    
    public class func fillWithRadialGradient(
        _ radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        ) -> ChartFill
    {
        return ChartFill(
            radialGradient: radialGradient,
            startOffsetPercent: startOffsetPercent,
            startRadiusPercent: startRadiusPercent,
            endOffsetPercent: endOffsetPercent,
            endRadiusPercent: endRadiusPercent
        )
    }
    
    public class func fillWithRadialGradient(_ radialGradient: CGGradient) -> ChartFill
    {
        return ChartFill(radialGradient: radialGradient)
    }
    
    public class func fillWithCGImage(_ image: CGImage, tiled: Bool) -> ChartFill
    {
        return ChartFill(image: image, tiled: tiled)
    }
    
    public class func fillWithImage(_ image: NSUIImage, tiled: Bool) -> ChartFill
    {
        return ChartFill(image: image.cgImage!, tiled: tiled)
    }
    
    public class func fillWithCGImage(_ image: CGImage) -> ChartFill
    {
        return ChartFill(image: image)
    }
    
    public class func fillWithImage(_ image: NSUIImage) -> ChartFill
    {
        return ChartFill(nsuiImage: image)
    }
    
    public class func fillWithCGLayer(_ layer: CGLayer) -> ChartFill
    {
        return ChartFill(layer: layer)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    public func fillPath(
        context: CGContext,
        rect: CGRect)
    {
        let fillType = _type
        if fillType == .empty
        {
            return
        }
        
        context.saveGState()
        
        switch fillType
        {
        case .color:
            
            context.setFillColor(_color!)
            context.fillPath()
            
        case .image:
            
            context.clip()
            context.draw(in: rect, image: _image!)
            
        case .tiledImage:
            
            context.clip()
            context.draw(in: rect, byTiling: _image!)
            
        case .layer:
            
            context.clip()
            context.draw(in: rect, layer: _layer!)
            
        case .linearGradient:
            
            let radians = ChartUtils.Math.FDEG2RAD * (360.0 - _gradientAngle)
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
            context.drawLinearGradient(_gradient!,
                start: startPoint,
                end: endPoint,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .radialGradient:
            
            let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
            let radius = max(rect.width, rect.height) / 2.0
            
            context.clip()
            context.drawRadialGradient(_gradient!,
                startCenter: CGPoint(
                    x: centerPoint.x + rect.width * _gradientStartOffsetPercent.x,
                    y: centerPoint.y + rect.height * _gradientStartOffsetPercent.y
                ),
                startRadius: radius * _gradientStartRadiusPercent,
                endCenter: CGPoint(
                    x: centerPoint.x + rect.width * _gradientEndOffsetPercent.x,
                    y: centerPoint.y + rect.height * _gradientEndOffsetPercent.y
                ),
                endRadius: radius * _gradientEndRadiusPercent,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .empty:
            break;
        }
        
        context.restoreGState()
    }
    
}
