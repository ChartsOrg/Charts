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

@objc(ChartFill)
public protocol Fill {

    /// Draws the provided path in filled mode with the provided area
    @objc func fillPath(context: CGContext, rect: CGRect)
}

@objc(ChartEmptyFill)
open class EmptyFill: NSObject, Fill {

    open func fillPath(context: CGContext, rect: CGRect) { }
}

@objc(ChartColorFill)
open class ColorFill: NSObject, Fill {

    @objc open let color: CGColor

    @objc public init(cgColor: CGColor) {
        self.color = cgColor
    }

    @objc public convenience init(color: NSUIColor) {
        self.init(cgColor: color.cgColor)
    }

    open func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        defer { context.restoreGState() }

        context.setFillColor(color)
        context.fillPath()
    }
}

@objc(ChartImageFill)
open class ImageFill: NSObject, Fill {

    @objc open let image: CGImage
    @objc open let isTiled: Bool

    @objc public init(cgImage: CGImage, isTiled: Bool = false) {
        image = cgImage
        self.isTiled = isTiled
    }

    @objc public convenience init(image: NSUIImage, isTiled: Bool = false) {
        self.init(cgImage: image.cgImage!, isTiled: isTiled)
    }

    open func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        defer { context.restoreGState() }

        context.clip()
        context.draw(image, in: rect, byTiling: isTiled)
    }
}

@objc(ChartLayerFill)
open class LayerFill: NSObject, Fill {

    @objc open let layer: CGLayer

    @objc public init(layer: CGLayer) {
        self.layer = layer
    }

    open func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        defer { context.restoreGState() }

        context.clip()
        context.draw(layer, in: rect)
    }
}

@objc(ChartLinearGradient)
open class LinearGradient: NSObject, Fill {

    @objc open let gradient: CGGradient
    @objc open let angle: CGFloat

    @objc public init(gradient: CGGradient, angle: CGFloat = 0) {
        self.gradient = gradient
        self.angle = angle
    }

    open func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        defer { context.restoreGState() }

        let radians = (360.0 - angle).DEG2RAD
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let xAngleDelta = cos(radians) * rect.width / 2.0
        let yAngleDelta = sin(radians) * rect.height / 2.0
        let startPoint = CGPoint(x: centerPoint.x - xAngleDelta,
                                 y: centerPoint.y - yAngleDelta)
        let endPoint = CGPoint(x: centerPoint.x + xAngleDelta,
                               y: centerPoint.y + yAngleDelta)

        context.clip()
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
    }
}

@objc(ChartRadialGradient)
open class RadialGradient: NSObject, Fill {

    @objc open let gradient: CGGradient
    @objc open let startOffsetPercent: CGPoint
    @objc open let endOffsetPercent: CGPoint
    @objc open let startRadiusPercent: CGFloat
    @objc open let endRadiusPercent: CGFloat

    @objc public init(gradient: CGGradient,
                      startOffsetPercent: CGPoint,
                      endOffsetPercent: CGPoint,
                      startRadiusPercent: CGFloat,
                      endRadiusPercent: CGFloat)
    {
        self.gradient = gradient
        self.startOffsetPercent = startOffsetPercent
        self.endOffsetPercent = endOffsetPercent
        self.startRadiusPercent = startRadiusPercent
        self.endRadiusPercent = endRadiusPercent
    }
    
    @objc public convenience init(gradient: CGGradient) {
        self.init(gradient: gradient,
                  startOffsetPercent: .zero,
                  endOffsetPercent: .zero,
                  startRadiusPercent: 0,
                  endRadiusPercent: 1)
    }

    @objc open func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        defer { context.restoreGState() }

        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(rect.width, rect.height) / 2.0

        context.clip()
        context.drawRadialGradient(gradient,
                                   startCenter: CGPoint(x: centerPoint.x + rect.width * startOffsetPercent.x,
                                                        y: centerPoint.y + rect.height * startOffsetPercent.y),
                                   startRadius: radius * startRadiusPercent,
                                   endCenter: CGPoint(x: centerPoint.x + rect.width * endOffsetPercent.x,
                                                      y: centerPoint.y + rect.height * endOffsetPercent.y),
                                   endRadius: radius * endRadiusPercent,
                                   options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
        )
    }
}
