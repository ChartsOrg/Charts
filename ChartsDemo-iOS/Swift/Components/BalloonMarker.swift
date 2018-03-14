//
//  BalloonMarker.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class BalloonMarker: MarkerImage {
    public var color: UIColor
    public var arrowSize = CGSize(width: 15, height: 11)
    public var font: UIFont
    public var textColor: UIColor
    public var insets: UIEdgeInsets
    public var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedStringKey : AnyObject]()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    public override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let size = self.size
        var point = point
        point.x -= size.width / 2.0
        point.y -= size.height
        return super.offsetForDrawing(atPoint: point)
    }
    
    public override func draw(context: CGContext, point: CGPoint) {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()
        
        context.setFillColor(color.cgColor)
        context.beginPath()
        context.move(to: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y))
        context.addLine(to: CGPoint(
            x: rect.origin.x + rect.size.width,
            y: rect.origin.y))
        context.addLine(to: CGPoint(
            x: rect.origin.x + rect.size.width,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + rect.size.width / 2.0,
            y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y))
        context.fillPath()
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        setLabel(String(entry.y))
    }
    
    public func setLabel(_ newLabel: String) {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
    
}
