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
    
    /// - Returns: The maximum shape-size across all DataSets.
    @objc open func getGreatestShapeSize() -> CGFloat
    {
        var max = CGFloat(0.0)
        
        for set in _dataSets
        {
            let scatterDataSet = set as? IScatterChartDataSet
            
            if scatterDataSet == nil
            {
                print("ScatterChartData: Found a DataSet which is not a ScatterChartDataSet", terminator: "\n")
            }
            else if let size = scatterDataSet?.scatterShapeSize, size > max
            {
                max = size
            }
        }
        
        return max
    }
}
