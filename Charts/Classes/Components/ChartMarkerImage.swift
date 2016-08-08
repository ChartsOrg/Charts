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


public class ChartMarkerImage: NSObject, IChartMarker
{
    /// The marker image to render
    public var image: NSUIImage?
    
    public var offset: CGPoint = CGPoint()
    
    public var size: CGSize
    {
        get
        {
            return image!.size
        }
    }
    
    public override init()
    {
        super.init()
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
        
        NSUIGraphicsPushContext(context)
        image!.drawInRect(rect)
        NSUIGraphicsPopContext()
    }
    
    public func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        // Do nothing here...
    }
}