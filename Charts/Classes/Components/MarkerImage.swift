//
//  ChartMarkerImage.swift
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

@objc(ChartMarkerImage)
public class MarkerImage: NSObject, IMarker
{
    /// The marker image to render
    public var image: NSUIImage?
    
    public var offset: CGPoint = CGPoint()
    
    public weak var chartView: ChartViewBase?
    
    /// As long as size is 0.0/0.0 - it will default to the image's size
    public var size: CGSize = CGSize()
    
    public override init()
    {
        super.init()
    }
    
    public func offsetForDrawingAtPos(point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        
        let chart = self.chartView
        
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image?.size.width ?? 0.0
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image?.size.height ?? 0.0
        }
        
        let width = size.width
        let height = size.height
        
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
        
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image?.size.width ?? 0.0
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image?.size.height ?? 0.0
        }
        
        let rect = CGRect(
            x: point.x + offset.x,
            y: point.y + offset.y,
            width: size.width,
            height: size.height)
        
        NSUIGraphicsPushContext(context)
        image!.drawInRect(rect)
        NSUIGraphicsPopContext()
    }
}