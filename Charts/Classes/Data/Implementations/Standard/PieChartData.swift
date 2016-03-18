//
//  PieData.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 24/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class PieChartData: ChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }

    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }

    var dataSet: IPieChartDataSet?
    {
        get
        {
            return dataSets.count > 0 ? dataSets[0] as? IPieChartDataSet : nil
        }
        set
        {
            if (newValue != nil)
            {
                dataSets = [newValue!]
            }
            else
            {
                dataSets = []
            }
        }
    }
    
    public override func getDataSetByIndex(index: Int) -> IChartDataSet?
    {
        if (index != 0)
        {
            return nil
        }
        return super.getDataSetByIndex(index)
    }
    
    public override func getDataSetByLabel(label: String, ignorecase: Bool) -> IChartDataSet?
    {
        if (dataSets.count == 0 || dataSets[0].label == nil)
        {
            return nil
        }
        
        if (ignorecase)
        {
            if (label.caseInsensitiveCompare(dataSets[0].label!) == NSComparisonResult.OrderedSame)
            {
                return dataSets[0]
            }
        }
        else
        {
            if (label == dataSets[0].label)
            {
                return dataSets[0]
            }
        }
        return nil
    }
    
    public override func addDataSet(d: IChartDataSet!)
    {
        if (_dataSets == nil)
        {
            return
        }
        
        super.addDataSet(d)
    }
    
    /// Removes the DataSet at the given index in the DataSet array from the data object.
    /// Also recalculates all minimum and maximum values.
    ///
    /// - returns: true if a DataSet was removed, false if no DataSet could be removed.
    public override func removeDataSetByIndex(index: Int) -> Bool
    {
        if (_dataSets == nil || index >= _dataSets.count || index < 0)
        {
            return false
        }
        
        return false
    }
    
    /// - returns: the total y-value sum across all DataSet objects the this object represents.
    public var yValueSum: Double
    {
        guard let dataSet = dataSet else { return 0.0 }
        
        var yValueSum: Double = 0.0
        
        for i in 0..<dataSet.entryCount
        {
            yValueSum += dataSet.entryForIndex(i)?.value ?? 0.0
        }
        
        return yValueSum
    }
}
