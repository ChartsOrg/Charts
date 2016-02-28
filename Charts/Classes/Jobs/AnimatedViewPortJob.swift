//
//  AnimatedViewPortJob.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

public class AnimatedViewPortJob: ChartViewPortJob
{
    internal var phase: CGFloat = 1.0
    internal var xOrigin: CGFloat = 0.0
    internal var yOrigin: CGFloat = 0.0
    
    private var _startTime: NSTimeInterval = 0.0
    private var _displayLink: NSUIDisplayLink!
    private var _duration: NSTimeInterval = 0.0
    private var _endTime: NSTimeInterval = 0.0
    
    private var _easing: ChartEasingFunctionBlock?
    
    public init(
        viewPortHandler: ChartViewPortHandler,
        xIndex: CGFloat,
        yValue: Double,
        transformer: ChartTransformer,
        view: ChartViewBase,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        duration: NSTimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        super.init(viewPortHandler: viewPortHandler,
            xIndex: xIndex,
            yValue: yValue,
            transformer: transformer,
            view: view)
        
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self._duration = duration
        self._easing = easing
    }
    
    deinit
    {
        stop(finish: false)
    }
    
    public override func doJob()
    {
        start()
    }
    
    public func start()
    {
        _startTime = CACurrentMediaTime()
        _endTime = _startTime + _duration
        _endTime = _endTime > _endTime ? _endTime : _endTime
        
        updateAnimationPhase(_startTime)
        
        _displayLink = NSUIDisplayLink(target: self, selector: Selector("animationLoop"))
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    public func stop(finish finish: Bool)
    {
        if (_displayLink != nil)
        {
            _displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            _displayLink = nil
            
            if finish
            {
                if phase != 1.0
                {
                    phase = 1.0
                    phase = 1.0
                    
                    animationUpdate()
                }
                
                animationEnd()
            }
        }
    }
    
    private func updateAnimationPhase(currentTime: NSTimeInterval)
    {
        let elapsedTime: NSTimeInterval = currentTime - _startTime
        let duration: NSTimeInterval = _duration
        var elapsed: NSTimeInterval = elapsedTime
        if elapsed > duration
        {
            elapsed = duration
        }
        
        if _easing != nil
        {
            phase = _easing!(elapsed: elapsed, duration: duration)
        }
        else
        {
            phase = CGFloat(elapsed / duration)
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: NSTimeInterval = CACurrentMediaTime()
        
        updateAnimationPhase(currentTime)
        
        animationUpdate()
        
        if (currentTime >= _endTime)
        {
            stop(finish: true)
        }
    }
    
    internal func animationUpdate()
    {
        // Override this
    }
    
    internal func animationEnd()
    {
        // Override this
    }
}