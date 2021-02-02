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

public protocol Fill
{
    /// Draws the provided path in filled mode with the provided area
    func fillPath(context: CGContext, rect: CGRect)
}

public struct EmptyFill: Fill
{
    public func fillPath(context: CGContext, rect: CGRect) { }
}

public struct ColorFill: Fill
{

    public let color: CGColor

    public init(cgColor: CGColor)
    {
        self.color = cgColor
    }

    public init(color: NSUIColor)
    {
        self.init(cgColor: color.cgColor)
    }

    public func fillPath(context: CGContext, rect: CGRect)
    {
        context.saveGState()
        defer { context.restoreGState() }

        context.setFillColor(color)
        context.fillPath()
    }
}

public struct ImageFill: Fill
{
    public let image: CGImage
    public let isTiled: Bool

    public init(cgImage: CGImage, isTiled: Bool = false)
    {
        image = cgImage
        self.isTiled = isTiled
    }

    public init(image: NSUIImage, isTiled: Bool = false)
    {
        self.init(cgImage: image.cgImage!, isTiled: isTiled)
    }

    public func fillPath(context: CGContext, rect: CGRect)
    {
        context.saveGState()
        defer { context.restoreGState() }

        context.clip()
        context.draw(image, in: rect, byTiling: isTiled)
    }
}

public struct LayerFill: Fill
{
    public let layer: CGLayer

    public init(layer: CGLayer)
    {
        self.layer = layer
    }

    public func fillPath(context: CGContext, rect: CGRect)
    {
        context.saveGState()
        defer { context.restoreGState() }

        context.clip()
        context.draw(layer, in: rect)
    }
}

public struct LinearGradientFill: Fill
{

    public let gradient: CGGradient
    public let angle: CGFloat

    public init(gradient: CGGradient, angle: CGFloat = 0)
    {
        self.gradient = gradient
        self.angle = angle
    }

    public func fillPath(context: CGContext, rect: CGRect)
    {
        context.saveGState()
        defer { context.restoreGState() }

        let radians = (360.0 - angle).DEG2RAD
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
        context.drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
        )
    }
}

public struct RadialGradientFill: Fill
{

    public let gradient: CGGradient
    public let startOffsetPercent: CGPoint
    public let endOffsetPercent: CGPoint
    public let startRadiusPercent: CGFloat
    public let endRadiusPercent: CGFloat

    public init(
        gradient: CGGradient,
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

    public init(gradient: CGGradient)
    {
        self.init(
            gradient: gradient,
            startOffsetPercent: .zero,
            endOffsetPercent: .zero,
            startRadiusPercent: 0,
            endRadiusPercent: 1
        )
    }

    public func fillPath(context: CGContext, rect: CGRect)
    {
        context.saveGState()
        defer { context.restoreGState() }

        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(rect.width, rect.height) / 2.0

        context.clip()
        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(
                x: centerPoint.x + rect.width * startOffsetPercent.x,
                y: centerPoint.y + rect.height * startOffsetPercent.y
            ),
            startRadius: radius * startRadiusPercent,
            endCenter: CGPoint(
                x: centerPoint.x + rect.width * endOffsetPercent.x,
                y: centerPoint.y + rect.height * endOffsetPercent.y
            ),
            endRadius: radius * endRadiusPercent,
            options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
        )
    }
}
