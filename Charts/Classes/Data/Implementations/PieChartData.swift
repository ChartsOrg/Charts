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
    private var _yValueSum = Double(0.0)
    
    public override init()
    {
        super.init()
        calcYValueSum()
    }
    
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
        calcYValueSum()
    }

    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
        calcYValueSum()
    }

    var dataSet: PieChartDataSet?
    {
        get
        {
            return dataSets.count > 0 ? dataSets[0] as? PieChartDataSet : nil
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
    
    /// calculates the sum of all y-values in all datasets
    internal func calcYValueSum()
    {
        _yValueSum = 0
        
        if (_dataSets == nil)
        {
            return
        }
        
        for (var i = 0; i < _dataSets.count; i++)
        {
            _yValueSum += fabs((_dataSets[i] as! IPieChartDataSet).yValueSum)
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
    
    /// Adds an Entry to the DataSet at the specified index. Entries are added to the end of the list.
    public override func addEntry(e: ChartDataEntry, dataSetIndex: Int)
    {
        super.addEntry(e, dataSetIndex: dataSetIndex)
        
        if _dataSets != nil && _dataSets.count > dataSetIndex && dataSetIndex >= 0
        {
            _yValueSum += e.value
        }
    }
    
    /// Removes the given Entry object from the DataSet at the specified index.
    public override func removeEntry(entry: ChartDataEntry!, dataSetIndex: Int) -> Bool
    {
        if super.removeEntry(entry, dataSetIndex: dataSetIndex)
        {
            _yValueSum -= entry.value
            return true
        }
        
        return false
    }
    
    public override func addDataSet(d: IChartDataSet!)
    {
        if (_dataSets == nil)
        {
            return
        }
        
        super.addDataSet(d);
        
        if let d = d as? IPieChartDataSet
        {
            _yValueSum += d.yValueSum
        }
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
        
        var sum = 0.0
        
        if let d = _dataSets[index] as? IPieChartDataSet
        {
            sum = d.yValueSum
        }
        
        if super.removeDataSetByIndex(index)
        {
            _yValueSum -= sum
        }
        
        return false
    }
    
    /// - returns: the total y-value sum across all DataSet objects the this object represents.
    public var yValueSum: Double
    {
        return _yValueSum
    }
    
    /// - returns: the average value across all entries in this Data object (all entries from the DataSets this data object holds)
    public var average: Double
    {
        return yValueSum / Double(yValCount)
    }
}
