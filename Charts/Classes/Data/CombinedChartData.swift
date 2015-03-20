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
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class CombinedChartData: BarLineScatterCandleChartData
{
    private var _lineData: LineChartData!
    private var _barData: BarChartData!
    private var _scatterData: ScatterChartData!
    private var _candleData: CandleChartData!
    
    public override init()
    {
        super.init();
    }
    
    public override init(xVals: [String]?)
    {
        super.init(xVals: xVals);
    }
    
    public var lineData: LineChartData!
    {
        get
        {
            return _lineData;
        }
        set
        {
            _lineData = newValue;
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet);
            }
            
            checkIsLegal(newValue.dataSets);
            
            calcMinMax();
            calcYValueSum();
            calcYValueCount();
            
            calcXValAverageLength();
        }
    }
    
    public var barData: BarChartData!
    {
        get
        {
            return _barData;
        }
        set
        {
            _barData = newValue;
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet);
            }
            
            checkIsLegal(newValue.dataSets);
            
            calcMinMax();
            calcYValueSum();
            calcYValueCount();
            
            calcXValAverageLength();
        }
    }
    
    public var scatterData: ScatterChartData!
    {
        get
        {
            return _scatterData;
        }
        set
        {
            _scatterData = newValue;
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet);
            }
            
            checkIsLegal(newValue.dataSets);
            
            calcMinMax();
            calcYValueSum();
            calcYValueCount();
        
            calcXValAverageLength();
        }
    }
    
    public var candleData: CandleChartData!
    {
        get
        {
            return _candleData;
        }
        set
        {
            _candleData = newValue;
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet);
            }
            
            checkIsLegal(newValue.dataSets);
            
            calcMinMax();
            calcYValueSum();
            calcYValueCount();
        
            calcXValAverageLength();
        }
    }
    
    public override func notifyDataChanged()
    {
        _lineData.notifyDataChanged();
        _barData.notifyDataChanged();
        _candleData.notifyDataChanged();
        _scatterData.notifyDataChanged();
    }
}
