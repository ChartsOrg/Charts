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

@objc
public protocol IPieChartDataSet: IChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// the space that is left out between the piechart-slices, default: 0°
    /// --> no space, maximum 45, minimum 0 (no space)
    var sliceSpace: CGFloat { get set }
    
    /// indicates the selection distance of a pie slice
    var selectionShift: CGFloat { get set }
}
