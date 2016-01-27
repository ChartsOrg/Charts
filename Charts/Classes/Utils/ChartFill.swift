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
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class ChartFill: NSObject
{
    @objc
    public enum ChartFillType: Int
    {
        case Empty
        case Color
        case LinearGradient
        case RadialGradient
        case Image
        case TiledImage
        case Layer
    }
    
    private var _type: ChartFillType = ChartFillType.Empty
    private var _color: CGColorRef?
    private var _gradient: CGGradientRef?
    private var _gradientAngle: CGFloat = 0.0
    private var _gradientStartOffsetPercent: CGPoint = CGPoint()
    private var _gradientStartRadiusPercent: CGFloat = 0.0
    private var _gradientEndOffsetPercent: CGPoint = CGPoint()
    private var _gradientEndRadiusPercent: CGFloat = 0.0
    private var _image: CGImageRef?
    private var _layer: CGLayerRef?
    
    // MARK: Properties
    
    public var type: ChartFillType
    {
        return _type
    }
    
    public var color: CGColorRef?
    {
        return _color
    }
    
    public var gradient: CGGradientRef?
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
    
    public var image: CGImageRef?
    {
        return _image
    }
    
    public var layer: CGLayerRef?
    {
        return _layer
    }
    
    // MARK: Constructors
    
    public override init()
    {
    }
    
    public init(CGColor: CGColorRef)
    {
        _type = .Color
        _color = CGColor
    }
    
    public convenience init(color: UIColor)
    {
        self.init(CGColor: color.CGColor)
    }
    
    public init(linearGradient: CGGradientRef, angle: CGFloat)
    {
        _type = .LinearGradient
        _gradient = linearGradient
        _gradientAngle = angle
    }
    
    public init(
        radialGradient: CGGradientRef,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        )
    {
        _type = .RadialGradient
        _gradient = radialGradient
        _gradientStartOffsetPercent = startOffsetPercent
        _gradientStartRadiusPercent = startRadiusPercent
        _gradientEndOffsetPercent = endOffsetPercent
        _gradientEndRadiusPercent = endRadiusPercent
    }
    
    public convenience init(radialGradient: CGGradientRef)
    {
        self.init(
            radialGradient: radialGradient,
            startOffsetPercent: CGPointMake(0.0, 0.0),
            startRadiusPercent: 0.0,
            endOffsetPercent: CGPointMake(0.0, 0.0),
            endRadiusPercent: 1.0
        )
    }
    
    public init(CGImage: CGImageRef, tiled: Bool)
    {
        _type = tiled ? .TiledImage : .Image
        _image = CGImage
    }
    
    public convenience init(image: UIImage, tiled: Bool)
    {
        if image.CGImage == nil
        {
            self.init()
        }
        else
        {
            self.init(CGImage: image.CGImage!, tiled: tiled)
        }
    }
    
    public convenience init(CGImage: CGImageRef)
    {
        self.init(CGImage: CGImage, tiled: false)
    }
    
    public convenience init(image: UIImage)
    {
        self.init(image: image, tiled: false)
    }
    
    public init(CGLayer: CGLayerRef)
    {
        _type = .Layer
        _layer = CGLayer
    }
    
    // MARK: Constructors
    
    public class func fillWithCGColor(CGColor: CGColorRef) -> ChartFill
    {
        return ChartFill(CGColor: CGColor)
    }
    
    public class func fillWithColor(color: UIColor) -> ChartFill
    {
        return ChartFill(color: color)
    }
    
    public class func fillWithLinearGradient(linearGradient: CGGradientRef, angle: CGFloat) -> ChartFill
    {
        return ChartFill(linearGradient: linearGradient, angle: angle)
    }
    
    public class func fillWithRadialGradient(
        radialGradient: CGGradientRef,
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
    
    public class func fillWithRadialGradient(radialGradient: CGGradientRef) -> ChartFill
    {
        return ChartFill(radialGradient: radialGradient)
    }
    
    public class func fillWithCGImage(CGImage: CGImageRef, tiled: Bool) -> ChartFill
    {
        return ChartFill(CGImage: CGImage, tiled: tiled)
    }
    
    public class func fillWithImage(image: UIImage, tiled: Bool) -> ChartFill
    {
        return ChartFill(image: image, tiled: tiled)
    }
    
    public class func fillWithCGImage(CGImage: CGImageRef) -> ChartFill
    {
        return ChartFill(CGImage: CGImage)
    }
    
    public class func fillWithImage(image: UIImage) -> ChartFill
    {
        return ChartFill(image: image)
    }
    
    public class func fillWithCGLayer(CGLayer: CGLayerRef) -> ChartFill
    {
        return ChartFill(CGLayer: CGLayer)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    public func fillPath(
        context context: CGContext,
        rect: CGRect)
    {
        let fillType = _type
        if fillType == .Empty
        {
            return
        }
        
        CGContextSaveGState(context)
        
        switch fillType
        {
        case .Color:
            
            CGContextSetFillColorWithColor(context, _color)
            CGContextFillPath(context)
            
        case .Image:
            
            CGContextClip(context)
            CGContextDrawImage(context, rect, _image)
            
        case .TiledImage:
            
            CGContextClip(context)
            CGContextDrawTiledImage(context, rect, _image)
            
        case .Layer:
            
            CGContextClip(context)
            CGContextDrawLayerInRect(context, rect, _layer)
            
        case .LinearGradient:
            
            let radians = ChartUtils.Math.FDEG2RAD * (360.0 - _gradientAngle)
            let centerPoint = CGPointMake(rect.midX, rect.midY)
            let xAngleDelta = cos(radians) * rect.width / 2.0
            let yAngleDelta = sin(radians) * rect.height / 2.0
            let startPoint = CGPointMake(
                centerPoint.x - xAngleDelta,
                centerPoint.y - yAngleDelta
            )
            let endPoint = CGPointMake(
                centerPoint.x + xAngleDelta,
                centerPoint.y + yAngleDelta
            )
            
            CGContextClip(context)
            CGContextDrawLinearGradient(
                context,
                _gradient,
                startPoint,
                endPoint,
                [.DrawsAfterEndLocation, .DrawsBeforeStartLocation]
            )
            
        case .RadialGradient:
            
            let centerPoint = CGPointMake(rect.midX, rect.midY)
            let radius = max(rect.width, rect.height) / 2.0
            
            CGContextClip(context)
            CGContextDrawRadialGradient(
                context,
                _gradient,
                CGPointMake(
                    centerPoint.x + rect.width * _gradientStartOffsetPercent.x,
                    centerPoint.y + rect.height * _gradientStartOffsetPercent.y
                ),
                radius * _gradientStartRadiusPercent,
                CGPointMake(
                    centerPoint.x + rect.width * _gradientEndOffsetPercent.x,
                    centerPoint.y + rect.height * _gradientEndOffsetPercent.y
                ),
                radius * _gradientEndRadiusPercent,
                [.DrawsAfterEndLocation, .DrawsBeforeStartLocation]
            )
            
        case .Empty:
            break;
        }
        
        CGContextRestoreGState(context)
    }
    
}