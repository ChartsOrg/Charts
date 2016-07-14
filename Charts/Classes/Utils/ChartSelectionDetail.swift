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
import CoreGraphics

public class ChartSelectionDetail: NSObject
{
    public var x = CGFloat.NaN
    public var y = CGFloat.NaN
    public var xValue = Double(0)
    public var yValue = Double(0)
    public var dataIndex = Int(0)
    public var dataSetIndex = Int(0)
    public var dataSet: IChartDataSet!
    
    public override init()
    {
        super.init()
    }
    
    public init(x: CGFloat, y: CGFloat, xValue: Double, yValue: Double, dataIndex: Int, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        super.init()
        
        self.x = x
        self.y = y
        self.xValue = xValue
        self.yValue = yValue
        self.dataIndex = dataIndex
        self.dataSetIndex = dataSetIndex
        self.dataSet = dataSet
    }
    
    public convenience init(x: CGFloat, y: CGFloat, xValue: Double, yValue: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(x: x, y: y, xValue: xValue, yValue: yValue, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    public convenience init(xValue: Double, yValue: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(x: CGFloat.NaN, y: CGFloat.NaN, xValue: xValue, yValue: yValue, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
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
        
        if (object!.xValue != self.xValue)
        {
            return false
        }
        
        if (object!.yValue != self.yValue)
        {
            return false
        }
        
        if (object!.dataSetIndex != self.dataSetIndex)
        {
            return false
        }
        
        if (object!.dataSet !== self.dataSet)
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
    
    if (lhs.xValue != rhs.xValue)
    {
        return false
    }
    
    if (lhs.yValue != rhs.yValue)
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
