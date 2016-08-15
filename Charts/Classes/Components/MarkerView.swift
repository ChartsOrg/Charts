//
//  ChartMarkerView.swift
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

@objc(ChartMarkerView)
public class MarkerView: NSUIView, IMarker
{
    public var offset: CGPoint = CGPoint()
    
    public weak var chartView: ChartViewBase?
    
    public func offsetForDrawingAtPos(point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        
        let chart = self.chartView
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        if point.x + offset.x < 0.0
        {
            offset.x = -point.x
        }
        else if chart != nil && point.x + width + offset.x > chart!.bounds.size.width
        {
            offset.x = chart!.bounds.size.width - point.x - width
        }
        
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if chart != nil && point.y + height + offset.y > chart!.bounds.size.height
        {
            offset.y = chart!.bounds.size.height - point.y - height
        }
        
        return offset
    }
    
    public func refreshContent(entry entry: ChartDataEntry, highlight: Highlight)
    {
        // Do nothing here...
    }
    
    public func draw(context context: CGContext, point: CGPoint)
    {
        let offset = self.offsetForDrawingAtPos(point)
        
        CGContextSaveGState(context)
        CGContextTranslateCTM(context,
                              point.x + offset.x,
                              point.y + offset.y)
        NSUIGraphicsPushContext(context)
        self.nsuiLayer?.renderInContext(context)
        NSUIGraphicsPopContext()
        CGContextRestoreGState(context)
    }
    
    @objc
    public class func viewFromXib() -> MarkerView?
    {
        #if !os(OSX)
            return NSBundle.mainBundle().loadNibNamed(
                String(self),
                owner: nil,
                options: nil)[0] as? MarkerView
        #else
            
            let loadedObjects = AutoreleasingUnsafeMutablePointer<NSArray?>(nilLiteral: ())
            
            if NSBundle.mainBundle().loadNibNamed(
                String(self),
                owner: nil,
                topLevelObjects: loadedObjects)
            {
                return loadedObjects.memory?[0] as? MarkerView
            }
            
            return nil
        #endif
    }
    
}