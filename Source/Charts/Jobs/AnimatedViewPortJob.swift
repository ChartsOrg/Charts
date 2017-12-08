//
//  AnimatedViewPortJob.swift
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

open class AnimatedViewPortJob: ViewPortJob
{
    internal var phase: CGFloat = 1.0
    internal var xOrigin: CGFloat = 0.0
    internal var yOrigin: CGFloat = 0.0
    
    private var _startTime: TimeInterval = 0.0
    private var _displayLink: NSUIDisplayLink!
    private var _duration: TimeInterval = 0.0
    private var _endTime: TimeInterval = 0.0
    
    private var _easing: ChartEasingFunctionBlock?
    
    @objc public init(
        viewPortHandler: ViewPortHandler,
        xValue: Double,
        yValue: Double,
        transformer: Transformer,
        view: ChartViewBase,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        super.init(viewPortHandler: viewPortHandler,
            xValue: xValue,
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
    
    open override func doJob()
    {
        start()
    }
    
    @objc open func start()
    {
        _startTime = CACurrentMediaTime()
        _endTime = _startTime + _duration
        _endTime = _endTime > _endTime ? _endTime : _endTime
        
        updateAnimationPhase(_startTime)
        
        _displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
        _displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    @objc open func stop(finish: Bool)
    {
        guard _displayLink != nil else { return }
        _displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        _displayLink = nil

        if finish
        {
            if phase != 1.0
            {
                phase = 1.0

                animationUpdate()
            }

            animationEnd()
        }
    }
    
    private func updateAnimationPhase(_ currentTime: TimeInterval)
    {
        let elapsedTime: TimeInterval = currentTime - _startTime
        let duration: TimeInterval = _duration
        var elapsed: TimeInterval = elapsedTime
        if elapsed > duration
        {
            elapsed = duration
        }
        
        if _easing != nil
        {
            phase = CGFloat(_easing!(elapsed, duration))
        }
        else
        {
            phase = CGFloat(elapsed / duration)
        }
    }
    
    @objc private func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhase(currentTime)
        
        animationUpdate()
        
        if currentTime >= _endTime
        {
            stop(finish: true)
        }
    }
    
    internal func animationUpdate()
    {
        fatalError("`animationUpdate()` must be overriden by subclasses")
    }
    
    internal func animationEnd()
    {
        fatalError("`animationEnd()` must be overriden by subclasses")
    }
}
