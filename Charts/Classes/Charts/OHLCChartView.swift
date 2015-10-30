//
//  OHLCChartView.swift
//  Charts
//
//  Created by John Casley on 10/23/15.
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation
import CoreGraphics

public class OHLCChartView: BarLineChartViewBase, OHLCChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        renderer = OHLCChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _chartXMin = -0.5
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        _chartXMax += 0.5
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    public var ohlcData: OHLCChartData?
    {
        return _data as? OHLCChartData
    }
}