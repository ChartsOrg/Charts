//
//  IValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Interface that allows custom formatting of all values inside the chart before they are being drawn to the screen.
///
/// Simply create your own formatting class and let it implement ValueFormatter.
///
/// Then override the getFormattedValue(...) method and return whatever you want.
@objc(IChartValueFormatter)
public protocol IValueFormatter : NSObjectProtocol
{
    
    /// Called when a value (from labels inside the chart) is formatted before being drawn.
    ///
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns: The formatted label ready for being drawn
    ///
    /// - parameter value:           The value to be formatted
    ///
    /// - parameter axis:            The entry the value belongs to - in e.g. BarChart, this is of class BarEntry
    ///
    /// - parameter dataSetIndex:    The index of the DataSet the entry in focus belongs to
    ///
    /// - parameter viewPortHandler: provides information about the current chart state (scale, translation, ...)
    ///
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String
}
