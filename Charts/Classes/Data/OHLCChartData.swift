//
//  OHLCChartData.swift
//  Charts
//
//  Created by John Casley on 10/22/15.
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation

public class OHLCChartData: BarLineScatterCandleBubbleChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(xVals: [String?]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
}