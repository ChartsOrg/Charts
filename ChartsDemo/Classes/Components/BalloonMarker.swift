//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import Charts

@objc
public class BalloonMarker: MarkerImage
{
    public var color: UIColor?
    public var arrowSize = CGSize(width: 15, height: 11)
    public var font: UIFont?
    public var textColor: UIColor?
    public var insets = UIEdgeInsets()
    public var minimumSize = CGSize()
    
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    public override func offsetForDrawingAtPos(point: CGPoint) -> CGPoint
    {
        let size = self.size
        var point = point
        point.y -= size.height
        return super.offsetForDrawingAtPos(point)
    }
    
    public override func draw(context context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        let offset = self.offsetForDrawingAtPos(point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
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
    
    public override func refreshContent(entry entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(String(entry.y))
    }
    
    public func setLabel(label: String)
    {
        labelns = label as NSString
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        _drawAttributes[NSForegroundColorAttributeName] = self.textColor
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}