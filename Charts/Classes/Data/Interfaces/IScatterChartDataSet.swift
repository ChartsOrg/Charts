//
//  IScatterChartDataSet.swift
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

@objc
public protocol IScatterChartDataSet: ILineScatterCandleChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    var scatterShapeSize: CGFloat { get set }
    var scatterShape: ScatterChartDataSet.ScatterShape { get set }
    var customScatterShape: CGPath? { get set }
}
