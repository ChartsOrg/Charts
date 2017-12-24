//
//  Highlight.swift
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

@objc(ChartHighlight)
open class Highlight: NSObject
{
    /// the x-value of the highlighted value
    @objc open private(set) var x = Double.nan
    
    /// the y-value of the highlighted value
    @objc open private(set) var y = Double.nan
    
    /// the x-pixel of the highlight
    @objc open private(set) var xPx = CGFloat.nan
    
    /// the y-pixel of the highlight
    @objc open private(set) var yPx = CGFloat.nan
    
    /// the index of the data object - in case it refers to more than one
    @objc open var dataIndex = -1
    
    /// the index of the dataset the highlighted value is in
    @objc open private(set) var dataSetIndex = 0
    
    /// index which value of a stacked bar entry is highlighted
    /// 
    /// **default**: -1
    @objc open private(set) var stackIndex = -1
    
    /// the axis the highlighted value belongs to
    @objc open private(set) var axis: YAxis.AxisDependency = .left
    
    /// the x-position (pixels) on which this highlight object was last drawn
    @objc open var drawX: CGFloat = 0.0
    
    /// the y-position (pixels) on which this highlight object was last drawn
    @objc open var drawY: CGFloat = 0.0
    
    public override init()
    {
        super.init()
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    @objc public init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataIndex: Int,
        dataSetIndex: Int,
        stackIndex: Int,
        axis: YAxis.AxisDependency)
    {
        super.init()
        
        self.x = x
        self.y = y
        self.xPx = xPx
        self.yPx = yPx
        self.dataIndex = dataIndex
        self.dataSetIndex = dataSetIndex
        self.stackIndex = stackIndex
        self.axis = axis
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    @objc public convenience init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataSetIndex: Int,
        stackIndex: Int,
        axis: YAxis.AxisDependency)
    {
        self.init(x: x, y: y, xPx: xPx, yPx: yPx,
                  dataIndex: 0,
                  dataSetIndex: dataSetIndex,
                  stackIndex: stackIndex,
                  axis: axis)
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    @objc public init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataSetIndex: Int,
        axis: YAxis.AxisDependency)
    {
        super.init()
        
        self.x = x
        self.y = y
        self.xPx = xPx
        self.yPx = yPx
        self.dataSetIndex = dataSetIndex
        self.axis = axis
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    @objc public init(x: Double, y: Double, dataSetIndex: Int)
    {
        self.x = x
        self.y = y
        self.dataSetIndex = dataSetIndex
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    @objc public convenience init(x: Double, dataSetIndex: Int, stackIndex: Int)
    {
        self.init(x: x, y: .nan, dataSetIndex: dataSetIndex)
        self.stackIndex = stackIndex
    }

    @objc open var isStacked: Bool { return stackIndex >= 0 }
    
    /// Sets the x- and y-position (pixels) where this highlight was last drawn.
    @objc open func setDraw(x: CGFloat, y: CGFloat)
    {
        self.drawX = x
        self.drawY = y
    }
    
    /// Sets the x- and y-position (pixels) where this highlight was last drawn.
    @objc open func setDraw(pt: CGPoint)
    {
        self.drawX = pt.x
        self.drawY = pt.y
    }

    // MARK: NSObject
    
    open override var description: String
    {
        return "Highlight, x: \(x), y: \(y), dataIndex (combined charts): \(dataIndex), dataSetIndex: \(dataSetIndex), stackIndex (only stacked barentry): \(stackIndex)"
    }
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        if object == nil
        {
            return false
        }
        
        if !(object! as AnyObject).isKind(of: type(of: self))
        {
            return false
        }
        
        if (object! as AnyObject).x != x
        {
            return false
        }
        
        if (object! as AnyObject).y != y
        {
            return false
        }
        
        if (object! as AnyObject).dataIndex != dataIndex
        {
            return false
        }
        
        if (object! as AnyObject).dataSetIndex != dataSetIndex
        {
            return false
        }
        
        if (object! as AnyObject).stackIndex != stackIndex
        {
            return false
        }
        
        return true
    }
}

func ==(lhs: Highlight, rhs: Highlight) -> Bool
{
    if lhs === rhs
    {
        return true
    }
    
    if !lhs.isKind(of: type(of: rhs))
    {
        return false
    }
    
    if lhs.x != rhs.x
    {
        return false
    }
    
    if lhs.y != rhs.y
    {
        return false
    }
    
    if lhs.dataIndex != rhs.dataIndex
    {
        return false
    }
    
    if lhs.dataSetIndex != rhs.dataSetIndex
    {
        return false
    }
    
    if lhs.stackIndex != rhs.stackIndex
    {
        return false
    }
    
    return true
}
