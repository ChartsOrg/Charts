//
//  CombinedChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class CombinedChartData: BarLineScatterCandleBubbleChartData
{
    private var _lineData: LineChartData!
    private var _barData: BarChartData!
    private var _scatterData: ScatterChartData!
    private var _candleData: CandleChartData!
    private var _bubbleData: BubbleChartData!
    
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    public var lineData: LineChartData!
    {
        get
        {
            return _lineData
        }
        set
        {
            _lineData = newValue
            notifyDataChanged()
        }
    }
    
    public var barData: BarChartData!
    {
        get
        {
            return _barData
        }
        set
        {
            _barData = newValue
            notifyDataChanged()
        }
    }
    
    public var scatterData: ScatterChartData!
    {
        get
        {
            return _scatterData
        }
        set
        {
            _scatterData = newValue
            notifyDataChanged()
        }
    }
    
    public var candleData: CandleChartData!
    {
        get
        {
            return _candleData
        }
        set
        {
            _candleData = newValue
            notifyDataChanged()
        }
    }
    
    public var bubbleData: BubbleChartData!
    {
        get
        {
            return _bubbleData
        }
        set
        {
            _bubbleData = newValue
            notifyDataChanged()
        }
    }
    
    public override func calcMinMax()
    {
        _dataSets.removeAll()
        
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        _xMax = -DBL_MAX
        _xMin = DBL_MAX
        
        _leftAxisMax = -DBL_MAX
        _leftAxisMin = DBL_MAX
        _rightAxisMax = -DBL_MAX
        _rightAxisMin = DBL_MAX
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            let sets = data.dataSets
            _dataSets.appendContentsOf(sets)
            
            if data.yMax > _yMax
            {
                _yMax = data.yMax
            }
            
            if data.yMin < _yMin
            {
                _yMin = data.yMin
            }
            
            if data.xMax > _xMax
            {
                _xMax = data.xMax
            }
            
            if data.xMin < _xMin
            {
                _xMin = data.xMin
            }
            
            if data.yMax > _leftAxisMax
            {
                _leftAxisMax = data.yMax
            }
            
            if data.yMin < _leftAxisMin
            {
                _leftAxisMin = data.yMin
            }
            
            if data.yMax > _rightAxisMax
            {
                _rightAxisMax = data.yMax
            }
            
            if data.yMin < _rightAxisMin
            {
                _rightAxisMin = data.yMin
            }
        }
    }
    
    /// - returns: All data objects in row: line-bar-scatter-candle-bubble if not null.
    public var allData: [ChartData]
    {
        var data = [ChartData]()
        
        if lineData !== nil
        {
            data.append(lineData)
        }
        if barData !== nil
        {
            data.append(barData)
        }
        if scatterData !== nil
        {
            data.append(scatterData)
        }
        if candleData !== nil
        {
            data.append(candleData)
        }
        if bubbleData !== nil
        {
            data.append(bubbleData)
        }
        
        return data
    }
    
    public func dataByIndex(index: Int) -> ChartData
    {
        return allData[index]
    }
    
    public func dataIndex(data: ChartData) -> Int?
    {
        return allData.indexOf(data)
    }
    
    public override func removeDataSet(dataSet: IChartDataSet!) -> Bool
    {
        let datas = allData
        
        var success = false
        
        for data in datas
        {
            success = data.removeDataSet(dataSet)
            
            if success
            {
                break
            }
        }
        
        return success
    }
    
    public override func removeDataSetByIndex(index: Int) -> Bool
    {
        print("removeDataSet(index) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func removeEntry(entry: ChartDataEntry, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(entry, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func removeEntry(xValue xValue: Double, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(xValue, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func notifyDataChanged()
    {
        if (_lineData !== nil)
        {
            _lineData.notifyDataChanged()
        }
        if (_barData !== nil)
        {
            _barData.notifyDataChanged()
        }
        if (_scatterData !== nil)
        {
            _scatterData.notifyDataChanged()
        }
        if (_candleData !== nil)
        {
            _candleData.notifyDataChanged()
        }
        if (_bubbleData !== nil)
        {
            _bubbleData.notifyDataChanged()
        }
        
        super.notifyDataChanged() // recalculate everything
    }
    
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    public override func entryForHighlight(highlight: Highlight) -> ChartDataEntry?
    {
        let dataObjects = allData
        
        if highlight.dataIndex >= dataObjects.count
        {
            return nil
        }
        
        let data = dataObjects[highlight.dataIndex]
        
        if highlight.dataSetIndex >= data.dataSetCount
        {
            return nil
        }
        else
        {
            // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
            let entries = data.getDataSetByIndex(highlight.dataSetIndex).entriesForXValue(highlight.x)
            for e in entries
            {
                if e.y == highlight.y || isnan(highlight.y)
                {
                    return e
                }
            }
            
            return nil
        }
    }
}
