//
//  TimeLineChartData.swift
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

/// Data object that encapsulates all data associated with a TimeLineChart.
public class TimeLineChartData: LineChartData
{
    // TODO: Not yet used but will be needed for scaling purposes
    internal var _xNumericValMax = Double(0.0)
    internal var _xNumericValMin = Double(0.0)

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

    /// calc minimum and maximum y value over all datasets
    /// TODO: Add calculations for minimum and maximum xNumericValue as well to support scaling
    internal override func calcMinMax(start start: Int, end: Int)
    {
        // This will need to be changed to find Min and Max for xNumericVals for scaling purposes
        super.calcMinMax(start: start, end: end)
    }
}
