//
//  ScatterChartView.swift
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

/// The ScatterChart. Draws dots, triangles, squares and custom shapes into the chartview.
public class ScatterChartView: BarLineChartViewBase, ScatterChartDataProvider
{
    public override func initialize()
    {
        super.initialize()
        
        renderer = ScatterChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    // MARK: - ScatterChartDataProbider
    
    public var scatterData: ScatterChartData? { return _data as? ScatterChartData }
}