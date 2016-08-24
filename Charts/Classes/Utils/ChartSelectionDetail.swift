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

open class ChartSelectionDetail: NSObject
{
    private var _y = CGFloat.nan
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
        self.init(y: CGFloat.nan, value: value, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    open var y: CGFloat
    {
        return _y
    }
    
    open var value: Double
    {
        return _value
    }
    
    open var dataIndex: Int
    {
        return _dataIndex
    }
    
    open var dataSetIndex: Int
    {
        return _dataSetIndex
    }
    
    open var dataSet: IChartDataSet?
    {
        return _dataSet
    }
    
    // MARK: NSObject
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        if (object == nil)
        {
            return false
        }

		let object = object as AnyObject
        
        if (!object.isKind(of: type(of: self)))
        {
            return false
        }
        
        if (object.value != _value)
        {
            return false
        }
        
        if (object.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object.dataSet !== _dataSet)
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
    
    if (!lhs.isKind(of: type(of: rhs)))
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
