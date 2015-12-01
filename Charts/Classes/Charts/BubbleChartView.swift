//
//  BubbleChartView.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public class BubbleChartView: BarLineChartViewBase, BubbleChartDataProvider
{
    public override func initialize()
    {
        super.initialize()
        
        renderer = BubbleChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    public override func calcMinMax()
    {
        super.calcMinMax()
        
        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0
        }
        
        _chartXMin = -0.5
        _chartXMax = Double(_data.xVals.count) - 0.5
        
        if renderer as? BubbleChartRenderer !== nil,
            let sets = _data.dataSets as? [BubbleChartDataSet]
        {
            for set in sets {
                
                let xmin = set.xMin
                let xmax = set.xMax
                
                if (xmin < _chartXMin)
                {
                    _chartXMin = xmin
                }
                
                if (xmax > _chartXMax)
                {
                    _chartXMax = xmax
                }
            }
        }
        
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    // MARK: - BubbleChartDataProbider
    
    public var bubbleData: BubbleChartData? { return _data as? BubbleChartData }
}