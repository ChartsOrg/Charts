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
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSetProtocol]?)
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...)
    {
        super.init(dataSets: elements)
    }
    
    /// - returns: The maximum shape-size across all DataSets.
    @objc open func getGreatestShapeSize() -> CGFloat
    {
        return reduce(0) { (max, set) -> CGFloat in
            guard let set = set as? ScatterChartDataSetProtocol else {
                print("ScatterChartData: Found a DataSet which is not a ScatterChartDataSet", terminator: "\n")

                return max
            }

            return Swift.max(max, set.scatterShapeSize)
        }
    }
}
