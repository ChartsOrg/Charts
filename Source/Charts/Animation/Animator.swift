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
    func animatorUpdated(_ animator: Animator)
    
    /// Called when the Animator has stopped.
    func animatorStopped(_ animator: Animator)
}

@objc(ChartAnimator)
open class Animator: NSObject
{
    public enum Dimension: Int {
        case X, Y, H
    }
    
    public struct State
    {
        var phase: Double = 1.0
        var duration: TimeInterval = 0.0
        var startTime: TimeInterval = 0.0
        var endTime: TimeInterval = 0.0
        var enabled: Bool = false
        var easing: ChartEasingFunctionBlock?
        
        mutating func updatePhase(currentTime: TimeInterval) {
            var elapsed = currentTime - startTime
            if elapsed > duration
            {
                elapsed = duration
            }
            self.phase = easing?(elapsed, duration) ?? Double(elapsed / duration)
        }
    }
    private var animatedDimensions: [Dimension: State] = [:]
    
    @objc open weak var delegate: AnimatorDelegate?
    @objc open var updateBlock: (() -> Void)?
    @objc open var stopBlock: (() -> Void)?
    
    /// the phase that is animated and influences the drawn values on the x-axis
    @objc open var phaseX: Double {
        return animatedDimensions[.X]?.phase ?? 1.0
    }
    
    /// the phase that is animated and influences the drawn values on the y-axis
    @objc open var phaseY: Double {
        return animatedDimensions[.Y]?.phase ?? 1.0
    }
    
    /// the phase that is animated and influences the drawn values on H dimension
    @objc open var phaseH: Double {
        return animatedDimensions[.H]?.phase ?? 1.0
    }
    
    fileprivate var _endTime: TimeInterval {
        return animatedDimensions.reduce(0) { (m, animation) -> TimeInterval in
            return max(m, animation.1.endTime)
        }
    }
    fileprivate var hasUnfinishedAnimations: Bool {
        return animatedDimensions.reduce(false) { (has, animation) in
            return has || animation.1.phase != 1.0
        }
    }
    
    fileprivate var hasEnabledAnimations: Bool {
        return animatedDimensions.reduce(true) { (has, animation) in
            return has || animation.1.enabled
        }
    }
    
    private var _startTimeX: TimeInterval = 0.0
    private var _startTimeY: TimeInterval = 0.0
    private var _displayLink: NSUIDisplayLink?
    
    private var _durationX: TimeInterval = 0.0
    private var _durationY: TimeInterval = 0.0
    
    private var _endTimeX: TimeInterval = 0.0
    private var _endTimeY: TimeInterval = 0.0
    
    private var _enabledX: Bool = false
    private var _enabledY: Bool = false
    
    private var _easingX: ChartEasingFunctionBlock?
    private var _easingY: ChartEasingFunctionBlock?
    
    public override init()
    {
        super.init()
    }
    
    deinit
    {
        stop()
    }
    
    @objc open func stop()
    {
        guard _displayLink != nil else { return }
        
        _displayLink?.remove(from: .main, forMode: .commonModes)
        _displayLink = nil
        
        _enabledX = false
        _enabledY = false
        disableAllAnimations();
        // If we stopped an animation in the middle, we do not want to leave it like this
        if hasUnfinishedAnimations {
            disableAllAnimations()
            delegate?.animatorUpdated(self)
            updateBlock?()
        }
        
        delegate?.animatorStopped(self)
        stopBlock?()
    }
    
    /// Returns a phase value for specified Dimension
    /// - Parameter dimension: Dimension enum value
    /// - Returns: Phase value
    open func phase(for dimension: Dimension) -> Double {
        return animatedDimensions[dimension]?.phase ?? 1.0
    }
    
    fileprivate func disableAllAnimations() {
        for (dim, _) in animatedDimensions {
            animatedDimensions[dim]?.enabled = false
        }
    }
    
    fileprivate func finishAllAnimations() {
        for (dim, _) in animatedDimensions {
            animatedDimensions[dim]?.enabled = false
            animatedDimensions[dim]?.phase = 1.0
        }
    }
    
    
    /// Updates animation time according to given current time interval
    /// - parameter currentTime: Current TimeInterval value
    private func updateAnimationPhases(_ currentTime: TimeInterval) {
        for (dim, _) in animatedDimensions {
            guard let enabled = animatedDimensions[dim]?.enabled, enabled else { continue }
            var elapsed = currentTime - animatedDimensions[dim]!.startTime
            if elapsed > animatedDimensions[dim]!.duration
            {
                elapsed = animatedDimensions[dim]!.duration
            }
            animatedDimensions[dim]!.updatePhase(currentTime: currentTime)
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhases(currentTime)
        
        delegate?.animatorUpdated(self)
        updateBlock?()
        
        if currentTime >= _endTime
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
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        stop()
        
        animate(dimension: .X, duration: xAxisDuration, easing: easingX)
        animate(dimension: .Y, duration: yAxisDuration, easing: easingY)
    }
    
    open func animate(dimension: Dimension, duration: TimeInterval, easing: ChartEasingFunctionBlock?) {
        let startTime = CACurrentMediaTime()
        let endTime = startTime + duration
        
        let animation = State(phase: 0.0, duration: duration, startTime: startTime, endTime: endTime, enabled: duration > 0.0, easing: easing)
        
        animatedDimensions[dimension] = animation
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(startTime)
        
        if hasEnabledAnimations
        {
            if _displayLink == nil
            {
                _displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
                _displayLink?.add(to: RunLoop.main, forMode: .commonModes)
            }
        }
    }
    
    open func animate(dimension: Dimension, duration: TimeInterval, easingOption: ChartEasingOption) {
        animate(dimension: dimension, duration: duration, easing: easingFunctionFromOption(easingOption))
    }
    
    open func animate(dimension: Dimension, duration: TimeInterval) {
        animate(dimension: dimension, duration: duration, easingOption: .easeInOutSine)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOptionX: the easing function for the animation on the x axis
    /// - parameter easingOptionY: the easing function for the animation on the y axis
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        animate(dimension: .X, duration: xAxisDuration, easing: easingFunctionFromOption(easingOptionX))
        animate(dimension: .Y, duration: yAxisDuration, easing: easingFunctionFromOption(easingOptionY))
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(dimension: .X, duration: xAxisDuration, easing: easing)
        animate(dimension: .Y, duration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(dimension: .X, duration: xAxisDuration,
                easing: easingFunctionFromOption(easingOption))
        animate(dimension: .Y, duration: yAxisDuration,
                easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(dimension: .X, duration: xAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easingOption: the easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(dimension: .X, duration: xAxisDuration,
                easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    @objc open func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(dimension: .Y, duration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    @objc open func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption = .easeInOutSine)
    {
        animate(dimension: .Y, duration: yAxisDuration,
                easing: easingFunctionFromOption(easingOption))
    }
}
