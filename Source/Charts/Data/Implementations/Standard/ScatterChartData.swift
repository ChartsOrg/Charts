//
//  ScatterChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class ScatterChartData: BarLineScatterCandleBubbleChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    /// - returns: The maximum shape-size across all DataSets.
    open func getGreatestShapeSize() -> CGFloat
    {
        var max = CGFloat(0.0)
        
        for case let set as IScatterChartDataSet in _dataSets
        {
            let size = set.scatterShapeSize

            if size > max
            {
                max = size
            }
        }

        return max
    }
}
