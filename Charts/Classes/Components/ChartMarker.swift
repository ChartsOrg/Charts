//
//  ChartMarker.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class ChartMarker: NSObject
{
    /// The marker image to render
    open var image: NSUIImage?
    
    /// Use this to return the desired offset you wish the MarkerView to have on the x-axis.
    open var offset: CGPoint = CGPoint()
    
    /// The marker's size
    open var size: CGSize
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
    
    /// Returns the offset for drawing at the specific `point`
    ///
    /// - parameter point: This is the point at which the marker wants to be drawn. You can adjust the offset conditionally based on this argument.
    /// - By default returns the self.offset property. You can return any other value to override that.
    open func offsetForDrawingAtPos(_ point: CGPoint) -> CGPoint
    {
        return offset
    }
    
    /// Draws the ChartMarker on the given position on the given context
    open func draw(context: CGContext, point: CGPoint)
    {
        let offset = self.offsetForDrawingAtPos(point)
        let size = self.size
        
        let rect = CGRect(x: point.x + offset.x, y: point.y + offset.y, width: size.width, height: size.height)
        
        NSUIGraphicsPushContext(context)
        image!.draw(in: rect)
        NSUIGraphicsPopContext()
    }
    
    /// This method enables a custom ChartMarker to update it's content everytime the MarkerView is redrawn according to the data entry it points to.
    ///
    /// - parameter highlight: the highlight object contains information about the highlighted value such as it's dataset-index, the selected range or stack-index (only stacked bar entries).
    open func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
    {
        // Do nothing here...
    }
}
