//
//  LineChartMaxMinView.swift
//  DGCharts
//
//  Created by Joy BIAN on 2023/12/4.
//

import UIKit

open class LineChartMaxMinView: BarLineChartViewBase, LineChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = LineChartMaxMinValueRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData? { return data as? LineChartData }
}
