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
        
        for set in _dataSets
        {
            let scatterDataSet = set as? IScatterChartDataSet
            
            if scatterDataSet == nil
            {
                print("ScatterChartData: Found a DataSet which is not a ScatterChartDataSet", terminator: "\n")
            }
            else
            {
                let size = scatterDataSet!.scatterShapeSize
                
                if size > max
                {
                    max = size
                }
            }
        }
        
        return max
    }
}
