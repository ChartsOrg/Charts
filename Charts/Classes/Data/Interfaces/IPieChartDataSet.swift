//
//  IPieChartDataSet.swift
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

#if !os(OSX)
    import UIKit
#endif

@objc
public protocol IPieChartDataSet: IChartDataSet
{
    // MARK: - Styling functions and accessors
    
    /// the space in pixels between the pie-slices
    /// **default**: 0
    /// **maximum**: 20
    var sliceSpace: CGFloat { get set }
    
    /// indicates the selection distance of a pie slice
    var selectionShift: CGFloat { get set }
}
