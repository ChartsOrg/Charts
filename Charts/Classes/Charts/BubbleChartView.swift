//
//  BubbleChartView.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class BubbleChartView: BarLineChartViewBase, BubbleChartDataProvider
{
    open override func initialize()
    {
        super.initialize()
        
        renderer = BubbleChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    open override func calcMinMax()
    {
        super.calcMinMax()
        guard let data = _data else { return }
        
        if _xAxis.axisRange == 0.0 && data.yValCount > 0
        {
            _xAxis.axisRange = 1.0
        }
        
        _xAxis._axisMinimum = -0.5
        _xAxis._axisMaximum = Double(data.xVals.count) - 0.5
        
        if renderer as? BubbleChartRenderer !== nil,
            let sets = data.dataSets as? [IBubbleChartDataSet]
        {
            for set in sets {
                
                let xmin = set.xMin
                let xmax = set.xMax
                
                if (xmin < _xAxis._axisMinimum)
                {
                    _xAxis._axisMinimum = xmin
                }
                
                if (xmax > _xAxis._axisMaximum)
                {
                    _xAxis._axisMaximum = xmax
                }
            }
        }
        
        _xAxis.axisRange = abs(_xAxis._axisMaximum - _xAxis._axisMinimum)
    }
    
    // MARK: - BubbleChartDataProbider
    
    open var bubbleData: BubbleChartData? { return _data as? BubbleChartData }
}
