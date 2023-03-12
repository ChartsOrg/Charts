//
//  LineScatterCandleRadarRenderer.swift
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

@objc(LineScatterCandleRadarChartRenderer)
open class LineScatterCandleRadarRenderer: BarLineScatterCandleBubbleRenderer
{
    public override init(animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// :param: context
    /// :param: points
    /// :param: horizontal
    /// :param: vertical
    @objc open func drawHighlightLines(context: CGContext, point: CGPoint, set: LineScatterCandleRadarChartDataSetProtocol)
    {
        
        // draw vertical highlight lines
        if set.isVerticalHighlightIndicatorEnabled
        {
            context.beginPath()

            if set.isVerticalHighlightRadarIndicatorEnabled {
                let colorTop = UIColor.white.cgColor
                let colorBottom = UIColor.clear.cgColor

                var gradientOne = CGGradient(colorsSpace: .none, colors: [colorTop, colorBottom] as CFArray, locations: [0.0, 1.0])!
                let startPointOne = CGPoint(x: point.x, y: point.y)
                let endPointOne = CGPoint(x: point.x, y: viewPortHandler.contentBottom)
                context.drawRadialGradient(gradientOne, startCenter: startPointOne, startRadius: 0.5, endCenter: endPointOne, endRadius: 0.5, options: .drawsAfterEndLocation)

                var gradientTwo = CGGradient(colorsSpace: .none, colors: [colorBottom, colorTop] as CFArray, locations: [0.0, 1.0])!
                let startPointTwo = CGPoint(x: point.x, y: viewPortHandler.contentTop)
                let endPointTwo = CGPoint(x: point.x, y: point.y)
                context.drawRadialGradient(gradientTwo, startCenter: startPointTwo, startRadius: 0.5, endCenter: endPointTwo, endRadius: 0.5, options: .drawsBeforeStartLocation)
            }

            context.move(to: CGPoint(x: point.x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: point.x, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        // draw horizontal highlight lines
        if set.isHorizontalHighlightIndicatorEnabled
        {
            context.beginPath()

            if set.isHorizontalHighlightRadarIndicatorEnabled {
                let colorTop = UIColor.white.cgColor
                let colorBottom = UIColor.clear.cgColor

                var gradientOne = CGGradient(colorsSpace: .none, colors: [colorBottom, colorTop] as CFArray, locations: [0.0, 1.0])!
                let startPointOne = CGPoint(x: viewPortHandler.contentLeft, y: point.y)
                let endPointOne = CGPoint(x: point.x, y: point.y)
                context.drawRadialGradient(gradientOne, startCenter: startPointOne, startRadius: 0.5, endCenter: endPointOne, endRadius: 0.5, options: .drawsBeforeStartLocation)

                var gradientTwo = CGGradient(colorsSpace: .none, colors: [colorBottom, colorTop] as CFArray, locations: [0.0, 1.0])!
                let startPointTwo = CGPoint(x: viewPortHandler.contentRight, y: point.y)
                let endPointTwo = CGPoint(x: point.x, y: point.y)
                context.drawRadialGradient(gradientTwo, startCenter: startPointTwo, startRadius: 0.5, endCenter: endPointTwo, endRadius: 0.5, options: .drawsBeforeStartLocation)
            }

            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: point.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: point.y))
            context.strokePath()
        }
    }
}
