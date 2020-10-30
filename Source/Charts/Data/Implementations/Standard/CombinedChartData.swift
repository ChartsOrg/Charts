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
    private var _lineData: LineChartData!
    private var _barData: BarChartData!
    private var _scatterData: ScatterChartData!
    private var _candleData: CandleChartData!
    private var _bubbleData: BubbleChartData!
    
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSetProtocol])
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...)
    {
        super.init(dataSets: elements)
    }
    
    @objc open var lineData: LineChartData!
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
    
    @objc open var barData: BarChartData!
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
    
    @objc open var scatterData: ScatterChartData!
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
    
    @objc open var candleData: CandleChartData!
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
    
    @objc open var bubbleData: BubbleChartData!
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
    
    open override func calcMinMax()
    {
        _dataSets.removeAll()
        
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        xMax = -Double.greatestFiniteMagnitude
        xMin = Double.greatestFiniteMagnitude
        
        leftAxisMax = -Double.greatestFiniteMagnitude
        leftAxisMin = Double.greatestFiniteMagnitude
        rightAxisMax = -Double.greatestFiniteMagnitude
        rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            _dataSets.append(contentsOf: data)
            
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

            for set in data
            {
                if set.axisDependency == .left
                {
                    if set.yMax > leftAxisMax
                    {
                        leftAxisMax = set.yMax
                    }
                    if set.yMin < leftAxisMin
                    {
                        leftAxisMin = set.yMin
                    }
                }
                else
                {
                    if set.yMax > rightAxisMax
                    {
                        rightAxisMax = set.yMax
                    }
                    if set.yMin < rightAxisMin
                    {
                        rightAxisMin = set.yMin
                    }
                }
            }
        }
    }
    
    /// All data objects in row: line-bar-scatter-candle-bubble if not null.
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
        return allData.firstIndex(of: data)
    }
    
    open override func removeDataSet(_ dataSet: ChartDataSetProtocol) -> Element?
    {
        for data in allData
        {
            if let e = data.removeDataSet(dataSet)
            {
                return e
            }
        }
        
        return nil
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
        _lineData?.notifyDataChanged()
        _barData?.notifyDataChanged()
        _scatterData?.notifyDataChanged()
        _candleData?.notifyDataChanged()
        _bubbleData?.notifyDataChanged()

        super.notifyDataChanged() // recalculate everything
    }
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - Parameters:
    ///   - highlight:
    /// - Returns: The entry that is highlighted
    @objc override open func entry(for highlight: Highlight) -> ChartDataEntry?
    {
        // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
        getDataSetByHighlight(highlight)?
            .entriesForXValue(highlight.x)
            .first { $0.y == highlight.y || highlight.y.isNaN }
    }
    
    /// Get dataset for highlight
    ///
    /// - Parameters:
    ///   - highlight: current highlight
    /// - Returns: dataset related to highlight
    @objc open func getDataSetByHighlight(_ highlight: Highlight) -> ChartDataSetProtocol!
    {
        guard allData.indices.contains(highlight.dataIndex) else
        {
            return nil
        }

        let data = dataByIndex(highlight.dataIndex)

        guard data.indices.contains(highlight.dataSetIndex) else
        {
            return nil
        }

        // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
        return data[highlight.dataSetIndex]
    }

    // MARK: Unsupported Collection Methods

    public override func append(_ newElement: ChartData.Element) {
        fatalError("append(_:) not supported for CombinedData")
    }

    public override func remove(at i: Int) -> ChartDataSetProtocol {
        fatalError("remove(at:) not supported for CombinedData")
    }
}
