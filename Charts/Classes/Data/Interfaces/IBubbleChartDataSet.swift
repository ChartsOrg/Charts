//
//  IBubbleChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc public enum NormalizeType : Int {
    case NoNormalize
    case SqrtNormalize
    case ExactNormalize
}

@objc
public protocol IBubbleChartDataSet: IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    var xMin: Double { get }
    var xMax: Double { get }
    var maxSize: CGFloat { get }
    var isTypeNormalizeSize: NormalizeType { get }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    var highlightCircleWidth: CGFloat { get set }
}
