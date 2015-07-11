//
//  ScatterChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//  derived from ScatterChart by Gerard J. Cerchio
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

/// The ScatterChart. Draws dots, triangles, squares and custom shapes into the chartview.
public class IndependentScatterChartView: BarLineChartViewBase, IndependentScatterChartRendererDelegate
{
    public override func initialize()
    {
        super.initialize()
        
        renderer = IndependentScatterChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _chartXMin = -0.5
    }

    public override func calcMinMax()
    {
        super.calcMinMax()

        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0
        }
        
        _chartXMax += 0.5
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    // MARK: - IndependentScatterChartRendererDelegate
    
    public func scatterChartRendererData(renderer: IndependentScatterChartRenderer) -> IndependentScatterChartData!
    {
        return _data as! IndependentScatterChartData!
    }
    
    public func scatterChartRenderer(renderer: IndependentScatterChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which)
    }
    
    public func scatterChartDefaultRendererValueFormatter(renderer: IndependentScatterChartRenderer) -> NSNumberFormatter!
    {
        return self._defaultValueFormatter
    }
    
    public func scatterChartRendererChartYMax(renderer: IndependentScatterChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    public func scatterChartRendererChartYMin(renderer: IndependentScatterChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    public func scatterChartRendererChartXMax(renderer: IndependentScatterChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    public func scatterChartRendererChartXMin(renderer: IndependentScatterChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    public func scatterChartRendererMaxVisibleValueCount(renderer: IndependentScatterChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
}