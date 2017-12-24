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

open class CombinedChartData: BarLineScatterCandleBubbleChartData
{
    @objc open var lineData: LineChartData! {
        didSet {
            notifyDataChanged()
        }
    }

    @objc open var barData: BarChartData! {
        didSet {
            notifyDataChanged()
        }
    }

    @objc open var scatterData: ScatterChartData! {
        didSet {
            notifyDataChanged()
        }
    }

    @objc open var candleData: CandleChartData! {
        didSet {
            notifyDataChanged()
        }
    }

    @objc open var bubbleData: BubbleChartData! {
        didSet {
            notifyDataChanged()
        }
    }

    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }

    open override func calcMinMax()
    {
        dataSets.removeAll()
        
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        xMax = -Double.greatestFiniteMagnitude
        xMin = Double.greatestFiniteMagnitude
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            let sets = data.dataSets
            dataSets.append(contentsOf: sets)
            
            if data.yMax > yMax
            {
                yMax = data.yMax
            }
            
            if data.yMin < yMin
            {
                yMin = data.yMin
            }
            
            if data.xMax > xMax
            {
                xMax = data.xMax
            }
            
            if data.xMin < xMin
            {
                xMin = data.xMin
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
    @objc open var allData: [ChartData]
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
    
    @objc open func dataByIndex(_ index: Int) -> ChartData
    {
        return allData[index]
    }
    
    open func dataIndex(_ data: ChartData) -> Int?
    {
        return allData.index(of: data)
    }
    
    open override func removeDataSet(_ dataSet: IChartDataSet!) -> Bool
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
    
    open override func removeDataSetByIndex(_ index: Int) -> Bool
    {
        print("removeDataSet(index) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func removeEntry(_ entry: ChartDataEntry, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(entry, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func removeEntry(xValue: Double, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(xValue, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func notifyDataChanged()
    {
        if lineData !== nil
        {
            lineData.notifyDataChanged()
        }
        if barData !== nil
        {
            barData.notifyDataChanged()
        }
        if scatterData !== nil
        {
            scatterData.notifyDataChanged()
        }
        if candleData !== nil
        {
            candleData.notifyDataChanged()
        }
        if bubbleData !== nil
        {
            bubbleData.notifyDataChanged()
        }
        
        super.notifyDataChanged() // recalculate everything
    }
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    open override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        if highlight.dataIndex >= allData.count
        {
            return nil
        }
        
        let data = dataByIndex(highlight.dataIndex)
        
        if highlight.dataSetIndex >= data.dataSetCount
        {
            return nil
        }
        
        // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
        let entries = data.getDataSetByIndex(highlight.dataSetIndex).entriesForXValue(highlight.x)
        for e in entries
        {
            if e.y == highlight.y || highlight.y.isNaN
            {
                return e
            }
        }
        return nil
    }
    
    /// Get dataset for highlight
    ///
    /// - Parameter highlight: current highlight
    /// - Returns: dataset related to highlight
    @objc open func getDataSetByHighlight(_ highlight: Highlight) -> IChartDataSet!
    {  
        if highlight.dataIndex >= allData.count
        {
            return nil
        }
        
        let data = dataByIndex(highlight.dataIndex)
        
        if highlight.dataSetIndex >= data.dataSetCount
        {
            return nil
        }
        
        return data.dataSets[highlight.dataSetIndex]
    }
}
