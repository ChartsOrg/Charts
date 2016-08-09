//
//  CombinedChartData.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
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
    
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public var lineData: LineChartData!
    {
        get
        {
            return _lineData
        }
        set
        {
            if newValue == nil {
                return
            }
            _lineData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueCount()
            
            calcXValAverageLength()
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
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueCount()
            
            calcXValAverageLength()
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
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueCount()
        
            calcXValAverageLength()
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
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            
            calcYValueCount()
            
            calcXValAverageLength()
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
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueCount()
            
            calcXValAverageLength()
        }
    }
    
    /// - returns: all data objects in row: line-bar-scatter-candle-bubble if not null.
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
    
    override func calcMinMax(start start: Int, end: Int) {
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        _leftAxisMin =  DBL_MAX
        _leftAxisMax = -DBL_MAX
        _rightAxisMax = -DBL_MAX
        _rightAxisMin = DBL_MAX
        
        if (_lineData !== nil)
        {
            _lineData.calcMinMax(start: start, end: end)
            
            if lineData.yMin < _yMin {
                _yMin = lineData.yMin
                _yMinXIndex = lineData.yMinXIndex
            }
            
            if lineData.yMax > _yMax {
                _yMax = lineData.yMax
                _yMaxXIndex = lineData.yMaxXIndex
            }
            _leftAxisMin = min(_lineData._leftAxisMin, _leftAxisMin);
            _leftAxisMax = max(_lineData._leftAxisMax, _leftAxisMax);
            _rightAxisMin = min(_lineData._rightAxisMin, _rightAxisMin);
            _rightAxisMax = max(_lineData._rightAxisMax, _rightAxisMax);
        }
        if (_barData !== nil)
        {
            _barData.calcMinMax(start: start, end: end)
            
            if _barData.yMin < _yMin {
                _yMin = _barData.yMin
                _yMinXIndex = _barData.yMinXIndex
            }
            
            if _barData.yMax > _yMax {
                _yMax = _barData.yMax
                _yMaxXIndex = _barData.yMaxXIndex
            }
            
            _leftAxisMin = min(_barData._leftAxisMin, _leftAxisMin);
            _leftAxisMax = max(_barData._leftAxisMax, _leftAxisMax);
            _rightAxisMin = min(_barData._rightAxisMin, _rightAxisMin);
            _rightAxisMax = max(_barData._rightAxisMax, _rightAxisMax);
        }
        if (_scatterData !== nil)
        {
            _scatterData.calcMinMax(start: start, end: end)
            
            if _scatterData.yMin < _yMin {
                _yMin = _scatterData.yMin
                _yMinXIndex = _scatterData.yMinXIndex
            }
            
            if _scatterData.yMax > _yMax {
                _yMax = _scatterData.yMax
                _yMaxXIndex = _scatterData.yMaxXIndex
            }
            
            _leftAxisMin = min(_scatterData._leftAxisMin, _leftAxisMin);
            _leftAxisMax = max(_scatterData._leftAxisMax, _leftAxisMax);
            _rightAxisMin = min(_scatterData._rightAxisMin, _rightAxisMin);
            _rightAxisMax = max(_scatterData._rightAxisMax, _rightAxisMax);
        }
        if (_candleData !== nil)
        {
            _candleData.calcMinMax(start: start, end: end)
            
            if _candleData.yMin < _yMin {
                _yMin = _candleData.yMin
                _yMinXIndex = _candleData.yMinXIndex
            }
            
            if _candleData.yMax > _yMax {
                _yMax = _candleData.yMax
                _yMaxXIndex = _candleData.yMaxXIndex
            }
            
            _leftAxisMin = min(_candleData._leftAxisMin, _leftAxisMin);
            _leftAxisMax = max(_candleData._leftAxisMax, _leftAxisMax);
            _rightAxisMin = min(_candleData._rightAxisMin, _rightAxisMin);
            _rightAxisMax = max(_candleData._rightAxisMax, _rightAxisMax);
        }
        if (_bubbleData !== nil)
        {
            _bubbleData.calcMinMax(start: start, end: end)
            
            if _bubbleData.yMin < _yMin {
                _yMin = _bubbleData.yMin
                _yMinXIndex = _bubbleData.yMinXIndex
            }
            
            if _bubbleData.yMax > _yMax {
                _yMax = _bubbleData.yMax
                _yMaxXIndex = _bubbleData.yMaxXIndex
            }
            
            _leftAxisMin = min(_bubbleData._leftAxisMin, _leftAxisMin);
            _leftAxisMax = max(_bubbleData._leftAxisMax, _leftAxisMax);
            _rightAxisMin = min(_bubbleData._rightAxisMin, _rightAxisMin);
            _rightAxisMax = max(_bubbleData._rightAxisMax, _rightAxisMax);
        }
        
//        _leftAxisMin = min(_lin, <#T##y: T##T#>, <#T##z: T##T#>, <#T##rest: T...##T#>)
//            handleEmptyAxis(firstLeft, firstRight: firstRight)
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
    /// - returns: the entry that is highlighted
    public override func getEntryForHighlight(highlight: ChartHighlight) -> ChartDataEntry?
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
            
            let entries = data.getDataSetByIndex(highlight.dataSetIndex).entriesForXIndex(highlight.xIndex)
            for e in entries
            {
                if e.value == highlight.value || isnan(highlight.value)
                {
                    return e
                }
            }
            
            return nil
        }
    }
}
