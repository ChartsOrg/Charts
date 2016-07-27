//
//  ChartSelectionDetail.swift
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

public class ChartSelectionDetail: NSObject
{
    private var _y = CGFloat.NaN
    private var _value = Double(0)
    private var _dataIndex = Int(0)
    private var _dataSetIndex = Int(0)
    private var _dataSet: IChartDataSet!
    
    public override init()
    {
        super.init()
    }
    
    public init(y: CGFloat, value: Double, dataIndex: Int, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        super.init()
        
        _y = y
        _value = value
        _dataIndex = dataIndex
        _dataSetIndex = dataSetIndex
        _dataSet = dataSet
    }
    
    public convenience init(y: CGFloat, value: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(y: y, value: value, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    public convenience init(value: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(y: CGFloat.NaN, value: value, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    public var y: CGFloat
    {
        return _y
    }
    
    public var value: Double
    {
        return _value
    }
    
    public var dataIndex: Int
    {
        return _dataIndex
    }
    
    public var dataSetIndex: Int
    {
        return _dataSetIndex
    }
    
    public var dataSet: IChartDataSet?
    {
        return _dataSet
    }
    
    // MARK: NSObject
    
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
        
        if (object!.value != _value)
        {
            return false
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object!.dataSet !== _dataSet)
        {
            return false
        }
        
        return true
    }
}

public func ==(lhs: ChartSelectionDetail, rhs: ChartSelectionDetail) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKindOfClass(rhs.dynamicType))
    {
        return false
    }
    
    if (lhs.value != rhs.value)
    {
        return false
    }
    
    if (lhs.dataSetIndex != rhs.dataSetIndex)
    {
        return false
    }
    
    if (lhs.dataSet !== rhs.dataSet)
    {
        return false
    }
    
    return true
}