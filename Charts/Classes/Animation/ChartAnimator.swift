//
//  ChartAnimator.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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

@objc
public protocol ChartAnimatorDelegate
{
    /// Called when the Animator has stepped.
    func chartAnimatorUpdated(_ chartAnimator: ChartAnimator)
    
    /// Called when the Animator has stopped.
    func chartAnimatorStopped(_ chartAnimator: ChartAnimator)
}

public class ChartAnimator: NSObject
{
    public weak var delegate: ChartAnimatorDelegate?
    public var updateBlock: (() -> Void)?
    public var stopBlock: (() -> Void)?
    
    /// the phase that is animated and influences the drawn values on the x-axis
    public var phaseX: CGFloat = 1.0
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseY: CGFloat = 1.0
    
    private var _startTimeX: TimeInterval = 0.0
    private var _startTimeY: TimeInterval = 0.0
    private var _displayLink: NSUIDisplayLink!
    
    private var _durationX: TimeInterval = 0.0
    private var _durationY: TimeInterval = 0.0
    
    private var _endTimeX: TimeInterval = 0.0
    private var _endTimeY: TimeInterval = 0.0
    private var _endTime: TimeInterval = 0.0
    
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
    
    public func stop()
    {
        if (_displayLink != nil)
        {
            _displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            _displayLink = nil
            
            _enabledX = false
            _enabledY = false
            
            // If we stopped an animation in the middle, we do not want to leave it like this
            if phaseX != 1.0 || phaseY != 1.0
            {
                phaseX = 1.0
                phaseY = 1.0
                
                if (delegate != nil)
                {
                    delegate!.chartAnimatorUpdated(self)
                }
                if (updateBlock != nil)
                {
                    updateBlock!()
                }
            }
            
            if (delegate != nil)
            {
                delegate!.chartAnimatorStopped(self)
            }
            if (stopBlock != nil)
            {
                stopBlock?()
            }
        }
    }
    
    private func updateAnimationPhases(_ currentTime: TimeInterval)
    {
        if (_enabledX)
        {
            let elapsedTime: TimeInterval = currentTime - _startTimeX
            let duration: TimeInterval = _durationX
            var elapsed: TimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
           
            if (_easingX != nil)
            {
                phaseX = _easingX!(elapsed: elapsed, duration: duration)
            }
            else
            {
                phaseX = CGFloat(elapsed / duration)
            }
        }
        if (_enabledY)
        {
            let elapsedTime: TimeInterval = currentTime - _startTimeY
            let duration: TimeInterval = _durationY
            var elapsed: TimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
            
            if (_easingY != nil)
            {
                phaseY = _easingY!(elapsed: elapsed, duration: duration)
            }
            else
            {
                phaseY = CGFloat(elapsed / duration)
            }
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhases(currentTime)
        
        if (delegate != nil)
        {
            delegate!.chartAnimatorUpdated(self)
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
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        stop()
        
        _startTimeX = CACurrentMediaTime()
        _startTimeY = _startTimeX
        _durationX = xAxisDuration
        _durationY = yAxisDuration
        _endTimeX = _startTimeX + xAxisDuration
        _endTimeY = _startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        _enabledY = yAxisDuration > 0.0
        
        _easingX = easingX
        _easingY = easingY
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeX)
        
        if (_enabledX || _enabledY)
        {
            _displayLink = NSUIDisplayLink(target: self, selector: #selector(ChartAnimator.animationLoop))
            _displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOptionX: the easing function for the animation on the x axis
    /// - parameter easingOptionY: the easing function for the animation on the y axis
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingFunctionFromOption(easingOptionX), easingY: easingFunctionFromOption(easingOptionY))
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easing, easingY: easing)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: .easeInOutSine)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _startTimeX = CACurrentMediaTime()
        _durationX = xAxisDuration
        _endTimeX = _startTimeX + xAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        
        _easingX = easing
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeX)
        
        if (_enabledX || _enabledY)
        {
            if _displayLink === nil
            {
                _displayLink = NSUIDisplayLink(target: self, selector: #selector(ChartAnimator.animationLoop))
                _displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    public func animate(xAxisDuration: TimeInterval)
    {
        animate(xAxisDuration: xAxisDuration, easingOption: .easeInOutSine)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _startTimeY = CACurrentMediaTime()
        _durationY = yAxisDuration
        _endTimeY = _startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledY = yAxisDuration > 0.0
        
        _easingY = easing
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeY)
        
        if (_enabledX || _enabledY)
        {
            if _displayLink === nil
            {
                _displayLink = NSUIDisplayLink(target: self, selector: #selector(ChartAnimator.animationLoop))
                _displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        animate(yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption))
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(yAxisDuration: TimeInterval)
    {
        animate(yAxisDuration: yAxisDuration, easingOption: .easeInOutSine)
    }
}
