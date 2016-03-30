//
//  ScatterChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
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
public class ScatterChartView: BarLineChartViewBase, ScatterChartDataProvider
{
    public override func initialize()
    {
        super.initialize()
        
        renderer = ScatterChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxis._axisMinimum = -0.5
    }

    public override func calcMinMax()
    {
        super.calcMinMax()
        guard let data = _data else { return }

        if _xAxis.axisRange == 0.0 && data.yValCount > 0
        {
            _xAxis.axisRange = 1.0
        }
        
        _xAxis._axisMaximum += 0.5
        _xAxis.axisRange = abs(_xAxis._axisMaximum - _xAxis._axisMinimum)
    }
    
    // MARK: - ScatterChartDataProbider
    
    public var scatterData: ScatterChartData? { return _data as? ScatterChartData }
}