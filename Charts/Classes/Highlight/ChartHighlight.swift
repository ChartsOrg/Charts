//
//  ChartHighlight.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class ChartHighlight: NSObject
{
    /// the x-index of the highlighted value
    private var _xIndex = Int(0)
    
    /// the y-value of the highlighted value
    private var _value = Double.NaN
    
    /// the index of the data object - in case it refers to more than one
    private var _dataIndex = Int(0)
    
    /// the index of the dataset the highlighted value is in
    private var _dataSetIndex = Int(0)
    
    /// index which value of a stacked bar entry is highlighted
    /// 
    /// **default**: -1
    private var _stackIndex = Int(-1)
    
    /// the range of the bar that is selected (only for stacked-barchart)
    private var _range: ChartRange?

    public override init()
    {
        super.init()
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter value: the y-value of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter range: the range the selected stack-value is in
    public init(xIndex x: Int, value: Double, dataIndex: Int, dataSetIndex: Int, stackIndex: Int, range: ChartRange?)
    {
        super.init()
        
        _xIndex = x
        _value = value
        _dataIndex = dataIndex
        _dataSetIndex = dataSetIndex
        _stackIndex = stackIndex
        _range = range
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter value: the y-value of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    public convenience init(xIndex x: Int, value: Double, dataIndex: Int, dataSetIndex: Int, stackIndex: Int)
    {
        self.init(xIndex: x, value: value, dataIndex: dataIndex, dataSetIndex: dataSetIndex, stackIndex: stackIndex, range: nil)
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter value: the y-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter range: the range the selected stack-value is in
    public convenience init(xIndex x: Int, value: Double, dataSetIndex: Int, stackIndex: Int, range: ChartRange?)
    {
        self.init(xIndex: x, value: value, dataIndex: 0, dataSetIndex: dataSetIndex, stackIndex: stackIndex, range: range)
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter value: the y-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter range: the range the selected stack-value is in
    public convenience init(xIndex x: Int, value: Double, dataSetIndex: Int, stackIndex: Int)
    {
        self.init(xIndex: x, value: value, dataIndex: 0, dataSetIndex: dataSetIndex, stackIndex: stackIndex, range: nil)
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    public convenience init(xIndex x: Int, dataSetIndex: Int, stackIndex: Int)
    {
        self.init(xIndex: x, value: Double.NaN, dataSetIndex: dataSetIndex, stackIndex: stackIndex, range: nil)
    }
    
    /// - parameter xIndex: the index of the highlighted value on the x-axis
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    public convenience init(xIndex x: Int, dataSetIndex: Int)
    {
        self.init(xIndex: x, value: Double.NaN, dataSetIndex: dataSetIndex, stackIndex: -1, range: nil)
    }
    
    public var xIndex: Int { return _xIndex }
    public var value: Double { return _value }
    public var dataIndex: Int { return _dataIndex }
    public var dataSetIndex: Int { return _dataSetIndex }
    public var stackIndex: Int { return _stackIndex }
    
    /// - returns: the range of values the selected value of a stacked bar is in. (this is only relevant for stacked-barchart)
    public var range: ChartRange? { return _range }

    // MARK: NSObject
    
    public override var description: String
    {
        return "Highlight, xIndex: \(_xIndex), dataIndex (combined charts): \(_dataIndex),dataSetIndex: \(_dataSetIndex), stackIndex (only stacked barentry): \(_stackIndex), value: \(_value)"
    }
    
    public override func isEqual(object: AnyObject?) -> Bool
    {
        if (object === nil)
        {
            return false
        }
        
        if (!object!.isKindOfClass(self.dynamicType))
        {
            return false
        }
        
        if (object!.xIndex != _xIndex)
        {
            return false
        }
        
        if (object!.dataIndex != dataIndex)
        {
            return false
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object!.stackIndex != _stackIndex)
        {
            return false
        }
        
        if (object!.value != value)
        {
            return false
        }
        
        return true
    }
}

func ==(lhs: ChartHighlight, rhs: ChartHighlight) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKindOfClass(rhs.dynamicType))
    {
        return false
    }
    
    if (lhs._xIndex != rhs._xIndex)
    {
        return false
    }
    
    if (lhs._dataIndex != rhs._dataIndex)
    {
        return false
    }
    
    if (lhs._dataSetIndex != rhs._dataSetIndex)
    {
        return false
    }
    
    if (lhs._stackIndex != rhs._stackIndex)
    {
        return false
    }
    
    if (lhs._value != rhs._value)
    {
        return false
    }
    
    return true
}