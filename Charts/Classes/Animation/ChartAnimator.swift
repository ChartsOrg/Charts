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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

@objc
public protocol ChartAnimatorDelegate
{
    // Called when the Animator has stepped.
    func chartAnimatorUpdated(chartAnimator: ChartAnimator);
}

public class ChartAnimator: NSObject
{
    public weak var delegate: ChartAnimatorDelegate?;
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseX: CGFloat = 1.0
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseY: CGFloat = 1.0
    
    private var _startTime: NSTimeInterval = 0.0
    private var _displayLink: CADisplayLink!
    private var _xDuration: NSTimeInterval = 0.0
    private var _yDuration: NSTimeInterval = 0.0
    private var _endTimeX: NSTimeInterval = 0.0
    private var _endTimeY: NSTimeInterval = 0.0
    private var _endTime: NSTimeInterval = 0.0
    private var _enabledX: Bool = false
    private var _enabledY: Bool = false
    
    private var _easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?
    
    public override init()
    {
        super.init();
    }
    
    deinit
    {
        stop();
    }
    
    public func stop()
    {
        if (_displayLink != nil)
        {
            _displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
            _displayLink = nil;
            
            _enabledX = false;
            _enabledY = false;
        }
    }
    
    @objc private func animationLoop()
    {
        var currentTime: NSTimeInterval = CACurrentMediaTime();
        var elapsedTime: NSTimeInterval = currentTime - _startTime;
        if (_enabledX)
        {
            var duration: NSTimeInterval = _xDuration;
            var elapsed: NSTimeInterval = elapsedTime;
            if (elapsed > duration)
            {
                elapsed = duration;
            }
           
            if (_easing != nil)
            {
                phaseX = _easing!(elapsed: elapsed, duration: duration);
            }
            else
            {
                phaseX = CGFloat(elapsed / duration);
            }
        }
        if (_enabledY)
        {
            var duration: NSTimeInterval = _yDuration;
            var elapsed: NSTimeInterval = elapsedTime;
            if (elapsed > duration)
            {
                elapsed = duration;
            }
            
            if (_easing != nil)
            {
                phaseY = _easing!(elapsed: elapsed, duration: duration);
            }
            else
            {
                phaseY = CGFloat(elapsed / duration);
            }
        }
        if (currentTime >= _endTime)
        {
            stop();
        }
        if (delegate != nil)
        {
            delegate!.chartAnimatorUpdated(self);
        }
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easing an easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        stop();
        
        _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"));
        
        _startTime = CACurrentMediaTime();
        _xDuration = xAxisDuration;
        _yDuration = yAxisDuration;
        _endTimeX = _startTime + xAxisDuration;
        _endTimeY = _startTime + yAxisDuration;
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY;
        _enabledX = xAxisDuration > 0.0;
        _enabledY = yAxisDuration > 0.0;
        
        _easing = easing;
        
        if (_enabledX || _enabledY)
        {
            _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
        }
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easingOption the easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption));
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: .EaseInOutSine);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: easing an easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: 0.0, easing: easing);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: easingOption the easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: 0.0, easing: easingFunctionFromOption(easingOption));
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    public func animate(#xAxisDuration: NSTimeInterval)
    {
        animate(xAxisDuration: xAxisDuration, yAxisDuration: 0.0, easingOption: .EaseInOutSine);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easing an easing function for the animation
    public func animate(#yAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        animate(xAxisDuration: 0.0, yAxisDuration: yAxisDuration, easing: easing);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easingOption the easing function for the animation
    public func animate(#yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        animate(xAxisDuration: 0.0, yAxisDuration: yAxisDuration, easing: easingFunctionFromOption(easingOption));
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    public func animate(#yAxisDuration: NSTimeInterval)
    {
        animate(xAxisDuration: 0.0, yAxisDuration: yAxisDuration, easingOption: .EaseInOutSine);
    }
}