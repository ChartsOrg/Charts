//
//  IBarLineScatterCandleBubbleChartDataSet.swift
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
import CoreGraphics

@objc
public protocol IBarLineScatterCandleBubbleChartDataSet: IChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    var highlightColor: NSUIColor { get set }
    var highlightLineWidth: CGFloat { get set }
    var highlightLineDashPhase: CGFloat { get set }
    var highlightLineDashLengths: [CGFloat]? { get set }
}
