//
//  CALayer+Extensions.swift
//  Charts
//
//  CALayer+Extensions implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import QuartzCore

extension CALayer {
    
    public func renderInOptionalContext(ctx: CGContext?) {
        
        guard let ctx = ctx else {
            return
        }
        
        renderInContext(ctx)
    }
}
