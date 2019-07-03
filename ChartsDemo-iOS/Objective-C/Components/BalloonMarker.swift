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
//  https://github.com/danielgindi/ios-charts
//  https://github.com/danielgindi/Charts/blob/1788e53f22eb3de79eb4f08574d8ea4b54b5e417/ChartsDemo/Classes/Components/BalloonMarker.swift
//  Edit: Added textColor

import Foundation;

import Charts;

import SwiftyJSON;

open class BalloonMarker: MarkerView {
  open var color: UIColor?
  open var arrowSize = CGSize(width: 0, height: 0)
  open var font: UIFont?
  open var textColor: UIColor?
  open var minimumSize = CGSize()
  
  
  fileprivate var insets = UIEdgeInsets(top: 8.0,left: 0.0,bottom: 8.0,right: 0.0)
  fileprivate var topInsets = UIEdgeInsets(top: 20.0,left: 8.0,bottom: 8.0,right: 8.0)
  fileprivate var textInsets = UIEdgeInsets(top: 0.0,left: 10.0,bottom: 0.0,right: 10.0)
  
  fileprivate var labelns: NSString?
  fileprivate var labelnsRight: NSString?
  fileprivate var labelnsDate: NSString?
  fileprivate var _labelSize: CGSize = CGSize()
  fileprivate var _labelSizeRight: CGSize = CGSize()
  fileprivate var _labelSizeDate: CGSize = CGSize()
  fileprivate var _size: CGSize = CGSize()
  fileprivate var _paragraphStyle: NSMutableParagraphStyle?
  fileprivate var _paragraphStyleRight: NSMutableParagraphStyle?
  fileprivate var _paragraphStyleDate: NSMutableParagraphStyle?
  fileprivate var _drawAttributes = [NSAttributedString.Key: Any]()
  fileprivate var _drawAttributesRight = [NSAttributedString.Key: Any]()
  fileprivate var _drawAttributesDate = [NSAttributedString.Key: Any]()
  
  
  public init(color: UIColor, font: UIFont, textColor: UIColor) {
    super.init(frame: CGRect.zero);
    self.color = color
    self.font = UIFont.systemFont(ofSize: 10.0)
    self.textColor = textColor
    
    _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
    _paragraphStyle?.alignment = .left
    
    _paragraphStyleRight = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
    _paragraphStyleRight?.alignment = .right
    
    _paragraphStyleDate = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
    _paragraphStyleDate?.alignment = .center
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  }
  
  
  func drawRect(context: CGContext, point: CGPoint) -> CGRect{
    
    let chart = super.chartView
//
//    let width = _size.width
    
    
    var rect = CGRect(origin: point, size: _size)
    
//    if point.y - _size.height < 0 {
//
//      if point.x - _size.width / 2.0 < 0 {
//        drawTopLeftRect(context: context, rect: rect)
//      } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
//        rect.origin.x -= _size.width
//        drawTopRightRect(context: context, rect: rect)
//      } else {
//        rect.origin.x -= _size.width / 2.0
//        drawTopCenterRect(context: context, rect: rect)
//      }
//
//      rect.origin.y += self.topInsets.top
//      rect.size.height -= self.topInsets.top + self.topInsets.bottom
//
//    } else {
    
      rect.origin.y = (chart?.bounds.height ?? 0.0) / 2.0 - _size.height / 2.0
      
      //            if point.x - _size.width / 2.0 < 0 {
      //                drawLeftRect(context: context, rect: rect)
      //            } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
      //                rect.origin.x -= _size.width
      //                drawRightRect(context: context, rect: rect)
      //            } else {
      //                rect.origin.x -= _size.width / 2.0
      //                drawCenterRect(context: context, rect: rect)
      //            }
      
      if point.x - _size.width - 10.0 < 0 {
        rect.origin.x += 10.0
        drawLeftRect(context: context, rect: rect)
      } else {
        rect.origin.x -= _size.width + 10.0
        drawRightRect(context: context, rect: rect)
      }
      rect.origin.y += self.insets.top
      rect.size.height -= self.insets.top + self.insets.bottom
      
//    }
    
    return rect
  }
  
//  func drawCenterRect(context: CGContext, rect: CGRect) {
//
//    context.setFillColor((color?.cgColor)!)
//    context.beginPath()
//    context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
//    context.fillPath()
//
//  }
  
  func drawLeftRect(context: CGContext, rect: CGRect) {
    UIGraphicsPushContext(context)
    
    let bezierPath = UIBezierPath(roundedRect: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height), cornerRadius: 2.0)
    UIColor.init(cgColor: (color?.cgColor)!).setFill()
    bezierPath.fill()

    UIGraphicsPopContext()
  }
  
  func drawRightRect(context: CGContext, rect: CGRect) {
    UIGraphicsPushContext(context)
    
    let bezierPath = UIBezierPath(roundedRect: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height), cornerRadius: 2.0)
    UIColor.init(cgColor: (color?.cgColor)!).setFill()
    bezierPath.fill()
    
    UIGraphicsPopContext()
    
  }
  
//  func drawTopCenterRect(context: CGContext, rect: CGRect) {
//
//    context.setFillColor((color?.cgColor)!)
//    context.beginPath()
//    context.move(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
//    context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
//    context.fillPath()
//
//  }
//
//  func drawTopLeftRect(context: CGContext, rect: CGRect) {
//    context.setFillColor((color?.cgColor)!)
//    context.beginPath()
//    context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
//    context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
//    context.fillPath()
//
//  }
//
//  func drawTopRightRect(context: CGContext, rect: CGRect) {
//    context.setFillColor((color?.cgColor)!)
//    context.beginPath()
//    context.move(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
//    context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - arrowSize.height / 2.0, y: rect.origin.y + arrowSize.height))
//    context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
//    context.fillPath()
//
//  }
  
  
  
  open override func draw(context: CGContext, point: CGPoint) {
    if (labelns == nil || labelns?.length == 0) {
      return
    }
    
    context.saveGState()
    
    let rect = drawRect(context: context, point: point)
    
    UIGraphicsPushContext(context)
    
    labelnsDate?.draw(in: rect.inset(by: textInsets), withAttributes: _drawAttributesDate)
    labelns?.draw(in: rect.inset(by: textInsets), withAttributes: _drawAttributes)
    labelnsRight?.draw(in: rect.inset(by: textInsets), withAttributes: _drawAttributesRight)
    
    UIGraphicsPopContext()
    
    context.restoreGState()
  }
  
  open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
    
    var label : String;
    
    if let candleEntry = entry as? CandleChartDataEntry {
      
      label = candleEntry.close.description
    } else {
      label = entry.y.description
    }
    
    if let object = entry.data as? JSON {
      if object["marker"].exists() {
        label = object["marker"].stringValue;
        
        if highlight.stackIndex != -1 && object["marker"].array != nil {
          label = object["marker"].arrayValue[highlight.stackIndex].stringValue
        }
      }
    }
    
    let labelsArr = label.components(separatedBy: "|")
    let labelRef = labelsArr[0] as NSString
    let labelRefRight = labelsArr[1] as NSString
    let labelRefDate = labelsArr[2] as NSString
    labelns = labelsArr[0] as NSString
    labelnsRight = labelsArr[1] as NSString
    labelnsDate = labelsArr[2] as NSString
    
    _drawAttributes.removeAll()
    _drawAttributes[NSAttributedString.Key.font] = self.font
    _drawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
    _drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor
    
    
    _drawAttributesRight.removeAll()
    _drawAttributesRight[NSAttributedString.Key.font] = self.font
    _drawAttributesRight[NSAttributedString.Key.paragraphStyle] = _paragraphStyleRight
    _drawAttributesRight[NSAttributedString.Key.foregroundColor] = self.textColor
    
    _drawAttributesDate.removeAll()
    _drawAttributesDate[NSAttributedString.Key.font] = self.font
    _drawAttributesDate[NSAttributedString.Key.paragraphStyle] = _paragraphStyleDate
    _drawAttributesDate[NSAttributedString.Key.foregroundColor] = self.textColor
    
    _labelSize = labelRef.size(withAttributes: _drawAttributes)
    _labelSizeRight = labelRefRight.size(withAttributes: _drawAttributesRight)
    _labelSizeDate = labelRefRight.size(withAttributes: _drawAttributesDate)
    
    _size.width = _labelSize.width + _labelSizeRight.width + self.insets.left + self.insets.right + self.textInsets.left + self.textInsets.right + 10.0
    _size.height = _labelSize.height + self.insets.top + self.insets.bottom
    _size.width = max(minimumSize.width, _size.width)
    _size.height = max(minimumSize.height, _size.height)
    
  }
}

