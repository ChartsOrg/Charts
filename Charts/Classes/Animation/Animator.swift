//
//  Animator.swift
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

@objc(ChartAnimatorDelegate)
public protocol AnimatorDelegate
{
    /// Called when the Animator has stepped.
    func animatorUpdated(chartAnimator: Animator)
    
    /// Called when the Animator has stopped.
    func animatorStopped(chartAnimator: Animator)
}

@objc(ChartAnimator)
public class Animator: NSObject
{
    public enum Dimension: Int {
        case X, Y, H
    }

    public struct State
    {
        var phase:      Double          = 1.0
        var duration:   NSTimeInterval  = 0.0
        var startTime:  NSTimeInterval  = 0.0
        var endTime:    NSTimeInterval  = 0.0
        var enabled:    Bool            = false
        var easing:     ChartEasingFunctionBlock?

        mutating func updatePhase(currentTime: NSTimeInterval) {
            var elapsed = currentTime - startTime
            if elapsed > duration
            {
                elapsed = duration
            }
            self.phase = easing?(elapsed: elapsed, duration: duration) ?? Double(elapsed / duration)
        }
    }

    private var animatedDimensions: [Dimension: State] = [:]

    public weak var delegate: AnimatorDelegate?
    public var updateBlock: (() -> Void)?
    public var stopBlock: (() -> Void)?
    
    /// the phase that is animated and influences the drawn values on the x-axis
    public var phaseX: Double {
        return animatedDimensions[.X]?.phase ?? 1.0
    }
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseY: Double {
        return animatedDimensions[.Y]?.phase ?? 1.0
    }
    
    private var _displayLink: NSUIDisplayLink?
    
    private var _endTime: NSTimeInterval {
        return animatedDimensions.reduce(0) { (m, animation) -> NSTimeInterval in
            return max(m, animation.1.endTime)
        }
    }

    public override init()
    {
        super.init()
    }
    
    deinit
    {
        stop()
    }
    
    public func stop()
    {
        if _displayLink != nil
        {
            _displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            _displayLink = nil
            
            disableAllAnimations()
            
            // If we stopped an animation in the middle, we do not want to leave it like this
            if hasUnfinishedAnimations()
            {
                finishAllAnimations()
                
                if (delegate != nil)
                {
                    delegate!.animatorUpdated(self)
                }
                if (updateBlock != nil)
                {
                    updateBlock!()
                }
            }
            
            if (delegate != nil)
            {
                delegate!.animatorStopped(self)
            }
            if (stopBlock != nil)
            {
                stopBlock?()
            }
        }
    }

    private func hasUnfinishedAnimations() -> Bool {
        return animatedDimensions.reduce(false) { (has, animation) -> Bool in
            return has || animation.1.phase != 1.0
        }
    }

    private func hasEnabledAnimations() -> Bool {
        return animatedDimensions.reduce(true, combine: { (has, animation) -> Bool in
            return has && animation.1.enabled
        })
    }

    private func disableAllAnimations() {
        for (dim, _) in animatedDimensions {
            animatedDimensions[dim]?.enabled = false
        }
    }

    private func finishAllAnimations() {
        for (dim, _) in animatedDimensions {
            animatedDimensions[dim]?.enabled = false
            animatedDimensions[dim]?.phase = 1.0
        }
    }
    
    private func updateAnimationPhases(currentTime: NSTimeInterval)
    {
        for (dim, _) in animatedDimensions {
            guard let enabled = animatedDimensions[dim]?.enabled where enabled else { continue }
            var elapsed = currentTime - animatedDimensions[dim]!.startTime
            if elapsed > animatedDimensions[dim]!.duration
            {
                elapsed = animatedDimensions[dim]!.duration
            }
            animatedDimensions[dim]!.updatePhase(currentTime)
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: NSTimeInterval = CACurrentMediaTime()
        
        updateAnimationPhases(currentTime)
        
        if (delegate != nil)
        {
            delegate!.animatorUpdated(self)
        }
        if (updateBlock != nil)
        {
            updateBlock!()
        }
        
        if (currentTime >= _endTime)
        {
            stop()
        }
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingX: an easing function for the animation on the x axis
    /// - parameter easingY: an easing function for the animation on the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        stop()

        animate(.X, duration: xAxisDuration, easing: easingX)
        animate(.Y, duration: yAxisDuration, easing: easingY)
    }

    public func animate(dimension: Dimension, duration: NSTimeInterval, easing: ChartEasingFunctionBlock?) {
        let startTime = CACurrentMediaTime()
        let endTime = startTime + duration

        let animation = State(phase: 0.0, duration: duration, startTime: startTime, endTime: endTime, enabled: duration > 0.0, easing: easing)

        animatedDimensions[dimension] = animation

        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(startTime)

        if hasEnabledAnimations()
        {
            if _displayLink == nil
            {
                _displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
                _displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            }
        }
    }

    public func animate(dimension: Dimension, duration: NSTimeInterval, easingOption: ChartEasingOption) {
        animate(dimension, duration: duration, easing: easingFunctionFromOption(easingOption))
    }

    public func animate(dimension: Dimension, duration: NSTimeInterval) {
        animate(dimension, duration: duration, easingOption: .EaseInOutSine)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOptionX: the easing function for the animation on the x axis
    /// - parameter easingOptionY: the easing function for the animation on the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        animate(.X, duration: xAxisDuration, easing: easingFunctionFromOption(easingOptionX))
        animate(.Y, duration: yAxisDuration, easing: easingFunctionFromOption(easingOptionY))

    }

    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(.X, duration: xAxisDuration, easing: easing)
        animate(.Y, duration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(.X, duration: xAxisDuration, easing: easingFunctionFromOption(easingOption))
        animate(.Y, duration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        animate(.X, duration: xAxisDuration)
        animate(.Y, duration: yAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(.X, duration: xAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(.X, duration: xAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval)
    {
        animate(.X, duration: xAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(.Y, duration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(.Y, duration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval)
    {
        animate(.Y, duration: yAxisDuration)
    }
}
