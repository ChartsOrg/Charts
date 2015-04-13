//
//  BubbleChartView.swift
//  Charts
//
//  Created by Pierre-Marc Airoldi on 2015-04-07.
//  Copyright (c) 2015 Pierre-Marc Airoldi. All rights reserved.
//

import Foundation

public class BubbleChartView: BarLineChartViewBase, BubbleChartRendererDelegate
{
    public override func initialize()
    {
        super.initialize();
        
        renderer = BubbleChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler);
    }
    
    public override func calcMinMax()
    {
        super.calcMinMax();
        
        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0;
        }
        
        _chartXMin = -0.5
        _chartXMax = Float(_data.xVals.count) - 0.5
        
        if let r = renderer as? BubbleChartRenderer, sets = bubbleChartRendererData(r).dataSets as? [BubbleChartDataSet]
        {
            for set in sets {
                
                let xmin = set.xMin
                let xmax = set.xMax
                
                if (xmin < _chartXMin)
                {
                    _chartXMin = xmin;
                }
                
                if (xmax > _chartXMax)
                {
                    _chartXMax = xmax;
                }
            }
        }
        
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin));
    }

    // MARK: - BubbleChartRendererDelegate
    
    public func bubbleChartRendererData(renderer: BubbleChartRenderer) -> BubbleChartData!
    {
        return _data as! BubbleChartData!;
    }
    
    public func bubbleChartRenderer(renderer: BubbleChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which);
    }
    
    public func bubbleChartDefaultRendererValueFormatter(renderer: BubbleChartRenderer) -> NSNumberFormatter!
    {
        return self._defaultValueFormatter;
    }
    
    public func bubbleChartRendererChartYMax(renderer: BubbleChartRenderer) -> Float
    {
        return self.chartYMax;
    }
    
    public func bubbleChartRendererChartYMin(renderer: BubbleChartRenderer) -> Float
    {
        return self.chartYMin;
    }
    
    public func bubbleChartRendererChartXMax(renderer: BubbleChartRenderer) -> Float
    {
        return self.chartXMax;
    }
    
    public func bubbleChartRendererChartXMin(renderer: BubbleChartRenderer) -> Float
    {
        return self.chartXMin;
    }
    
    public func bubbleChartRendererMaxVisibleValueCount(renderer: BubbleChartRenderer) -> Int
    {
        return self.maxVisibleValueCount;
    }
}