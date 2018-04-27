//
//  Gradient.swift
//  Charts
//
//  Copyright 2018 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

@objc(ChartDrawableGradient)
public protocol DrawableGradient {
    func draw(_ gradient: CGGradient, in context: CGContext)
}

@objc(ChartBaseGradient)
open class BaseGradient: NSObject {
    @objc open let colors: [UIColor]

    @objc open let positions: [CGFloat]?

    @objc open let options: CGGradientDrawingOptions

    @objc public init(
        colors: [UIColor],
        positions: [CGFloat]?,
        options: CGGradientDrawingOptions) {
        self.colors = colors
        self.positions = positions
        self.options = options
    }
}

@objc(ChartLinearGradient)
open class LinearGradient: BaseGradient, DrawableGradient {
    @objc open let start: CGPoint
    @objc open let end: CGPoint

    @objc public init(
        colors: [UIColor],
        positions: [CGFloat]? = nil,
        options: CGGradientDrawingOptions = [],
        start: CGPoint,
        end: CGPoint) {
        self.start = start
        self.end = end

        super.init(colors: colors, positions: positions, options: options)
    }

    // MARK: - DrawableGradient

    public func draw(_ gradient: CGGradient, in context: CGContext) {
        context.drawLinearGradient(gradient, start: start, end: end, options: options)
    }
}

@objc(ChartLinearGradient)
open class RadialGradient: BaseGradient, DrawableGradient {
    @objc open let startCenter: CGPoint
    @objc open let startRadius: CGFloat
    @objc open let endCenter: CGPoint
    @objc open let endRadius: CGFloat
    
    @objc public init(
        colors: [UIColor],
        positions: [CGFloat]? = nil,
        options: CGGradientDrawingOptions = [],
        startCenter: CGPoint,
        startRadius: CGFloat,
        endCenter: CGPoint,
        endRadius: CGFloat) {
        self.startCenter = startCenter
        self.startRadius = startRadius
        self.endCenter = endCenter
        self.endRadius = endRadius

        super.init(colors: colors, positions: positions, options: options)
    }

    
    // MARK: - DrawableGradient
    
    public func draw(_ gradient: CGGradient, in context: CGContext) {
        context.drawRadialGradient(
            gradient,
            startCenter: startCenter,
            startRadius: startRadius,
            endCenter: endCenter,
            endRadius: endRadius,
            options: options)
    }
}
