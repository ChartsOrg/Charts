//
//  TimeLineChartView.swift
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

/// Chart that do all that line charts do and also support using the x axis to represent time
public class TimeLineChartView: LineChartView, TimeLineChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = TimeLineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    internal override func calcMinMax()
    {
        // TODO: I'm not sure how this factors in yet.  It appears to mainly use y values and axis data
        super.calcMinMax()
        guard let data = _data else { return }
        
        if (_deltaX == 0.0 && data.yValCount > 0)
        {
            _deltaX = 1.0
        }
    }
    
    // MARK: - TimeLineChartDataProvider
    
    public var timeLineData: TimeLineChartData? { return _data as? TimeLineChartData }
}