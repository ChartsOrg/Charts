//
//  IBubbleChartDataSet.swift
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

@objc
public protocol IBubbleChartDataSet: IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    var maxSize: CGFloat { get }
    var isNormalizeSizeEnabled: Bool { get }
    
    // MARK: - Styling functions and accessors
    
    /// Sets wether highlighted circle will be fully filled or surrounded with another circle
    var highlightCircleFillEnabled: Bool { get set }
    
    var isHighlightCircleFillEnabled: Bool { get }
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    var highlightCircleWidth: CGFloat { get set }
}
