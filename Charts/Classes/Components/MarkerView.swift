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
    
    public var size: CGSize
    {
        get
        {
            return self.frame.size
        }
    }
    
    public func offsetForDrawingAtPos(point: CGPoint) -> CGPoint
    {
        return offset
    }
    
    public func draw(context context: CGContext, point: CGPoint)
    {
        let offset = self.offsetForDrawingAtPos(point)
        let size = self.size
        
        let rect = CGRect(x: point.x + offset.x, y: point.y + offset.y, width: size.width, height: size.height)
        
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y)
        NSUIGraphicsPushContext(context)
        self.nsuiLayer?.renderInContext(context)
        NSUIGraphicsPopContext()
        CGContextRestoreGState(context)
    }
    
    public func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        // Do nothing here...
    }
    
    @objc
    public class func viewFromXib() -> MarkerView
    {
        return NSBundle.mainBundle().loadNibNamed(
            String(self),
            owner: nil,
            options: nil)[0] as! MarkerView
    }
    
}