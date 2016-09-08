//
//  IPieChartDataSet.swift
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
    
    var xValuePosition: PieChartDataSet.ValuePosition { get set }
    var yValuePosition: PieChartDataSet.ValuePosition { get set }
    
    /// When valuePosition is OutsideSlice, indicates line color
    var valueLineColor: NSUIColor? { get set }
    
    /// When valuePosition is OutsideSlice, indicates line width
    var valueLineWidth: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
    var valueLinePart1OffsetPercentage: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates length of first half of the line
    var valueLinePart1Length: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates length of second half of the line
    var valueLinePart2Length: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, this allows variable line length
    var valueLineVariableLength: Bool { get set }
}
