//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
;
import Charts;

public class BalloonMarker: ChartMarker
{
    public var color: UIColor?
    public var arrowSize = CGSize(width: 15, height: 11)
    public var font: UIFont?
    public var insets = UIEdgeInsets()
    public var minimumSize = CGSize()
    
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    public override var size: CGSize { return _size; }
    
    public override func draw(context context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        let offset = self.offsetForDrawingAtPos(point)
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: _size)
        rect.origin.x -= _size.width / 2.0
        rect.origin.y -= _size.height
        
        CGContextSaveGState(context)
        
        CGContextSetFillColorWithColor(context, color?.CGColor)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context,
            rect.origin.x,
            rect.origin.y)
        CGContextAddLineToPoint(context,
            rect.origin.x + rect.size.width,
            rect.origin.y)
        CGContextAddLineToPoint(context,
            rect.origin.x + rect.size.width,
            rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
            rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
            rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
            rect.origin.x + rect.size.width / 2.0,
            rect.origin.y + rect.size.height)
        CGContextAddLineToPoint(context,
            rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
            rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
            rect.origin.x,
            rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
            rect.origin.x,
            rect.origin.y)
        CGContextFillPath(context)
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        CGContextRestoreGState(context)
    }
    
    public override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let label = entry.value.description
        labelns = label as NSString
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}