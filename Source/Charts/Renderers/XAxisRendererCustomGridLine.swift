//
//  XAxisRendererCustomGridLine.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
#if canImport(UIKit)
import Foundation
import CoreGraphics
import Algorithms

open class XAxisRendererCustomGridLine: XAxisTitleRenderer
{
    open override func renderGridLines(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            axis.isEnabled,
            axis.isDrawGridLinesEnabled
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }

        context.clip(to: self.gridClippingRect)
        
        context.setShouldAntialias(axis.gridAntialiasEnabled)
        context.setStrokeColor(axis.gridColor.cgColor)
        context.setLineWidth(axis.gridLineWidth)
        context.setLineCap(axis.gridLineCap)
        
        if axis.gridLineDashLengths != nil
        {
            context.setLineDash(phase: axis.gridLineDashPhase, lengths: axis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint.zero
        
        let entries = axis.entries
        var index = 0
        while index < axis.labelCount
        {
            let entry = entries[index]
            position.x = CGFloat(entry)
            position.y = CGFloat(entry)
            index += 1
            if position.x == 0 && position.y == 0 { continue }
            position = position.applying(valueToPixelMatrix)
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
}
#endif
