//
//  LineChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

/// Chart that draws lines, surfaces, circles, ...
public class LineChartView: BarLineChartViewBase, LineChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = LineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        guard let data = _data else { return }
        
        if _xAxis.axisRange == 0.0 && data.yValCount > 0
        {
            _xAxis.axisRange = 1.0
        }
    }
    
    // MARK: - LineChartDataProvider
    
    public var lineData: LineChartData? { return _data as? LineChartData }
}