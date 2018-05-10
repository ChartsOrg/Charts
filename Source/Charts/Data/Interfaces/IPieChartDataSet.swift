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

    /// When enabled, slice spacing will be 0.0 when the smallest value is going to be smaller than the slice spacing itself.
    var automaticallyDisableSliceSpacing: Bool { get set }

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

    /// the font for the slice-text labels
    var entryLabelFont: NSUIFont? { get set }

    /// the color for the slice-text labels
    var entryLabelColor: NSUIColor? { get set }

    /// get/sets the color for the highlighted sector
    var highlightColor: NSUIColor? { get set }

    // MARK: - Accessibility

    /// When the data entry labels for slices are generated identifiers, set this property to prepend a string before each identifier
    ///
    /// For example, if a label is "#3", settings this property to "Item" allows it to be spoken as "Item #3"
    var accessibilityEntryLabelPrefix: String? { get set }

    /// When the data entry value requires a unit, use this property to append the string representation of the unit to the value
    ///
    /// For example, if a value is "44.1", setting this property to "m" allows it to be spoken as "44.1 m"
    var accessibilityEntryLabelSuffix: String? { get set }

    /// If the data entry value is a count, set this to true to allow plurals and other grammatical changes
    /// **default**: false
    var accessibilityEntryLabelSuffixIsCount: Bool { get set }
}
