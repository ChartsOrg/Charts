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
    private var _endTimeX: NSTimeInterval = 0.0
    private var _endTimeY: NSTimeInterval = 0.0
    private var _endTime: NSTimeInterval = 0.0
    private var _enabledX: Bool = false
    private var _enabledY: Bool = false
    
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
        var currentTime = CACurrentMediaTime();
        if (_enabledX)
        {
            var duration = _endTimeX - _startTime;
            phaseX = duration == 0.0 ? 0.0 : CGFloat((currentTime - _startTime) / duration);
            if (phaseX > 1.0)
            {
                phaseX = 1.0;
            }
        }
        if (_enabledY)
        {
            var duration = _endTimeY - _startTime;
            phaseY = duration == 0.0 ? 0.0 : CGFloat((currentTime - _startTime) / duration);
            if (phaseY > 1.0)
            {
                phaseY = 1.0;
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
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with
    /// the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        stop();
        
        _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"));
        
        _startTime = CACurrentMediaTime();
        _endTimeX = _startTime + xAxisDuration;
        _endTimeY = _startTime + yAxisDuration;
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY;
        _enabledX = true;
        _enabledY = true;
        
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with
    /// the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    public func animate(#xAxisDuration: NSTimeInterval)
    {
        stop();
        
        _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"));
        
        _startTime = CACurrentMediaTime();
        _endTimeX = _startTime + xAxisDuration;
        _endTime = _endTimeX;
        _enabledX = true;
        _enabledY = false;
        
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with
    /// the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    public func animate(#yAxisDuration: NSTimeInterval)
    {
        stop();
        
        _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"));
        
        _startTime = CACurrentMediaTime();
        _endTimeY = _startTime + yAxisDuration;
        _endTime = _endTimeY;
        _enabledX = false;
        _enabledY = true;
        
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
    }
}