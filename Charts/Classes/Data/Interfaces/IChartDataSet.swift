//
//  IChartDataSet.swift
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
public protocol IChartDataSet
{
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    func notifyDataSetChanged()
    
    /// This is an opportunity to calculate the minimum and maximum y value in the specified range.
    /// If your data is in an array, you might loop over them to find the values.
    /// If your data is in a database, you might query for the min/max and put them in variables.
    /// - parameter start: the index of the first y entry to calculate
    /// - parameter end: the index of the last y entry to calculate
    func calcMinMax(start start: Int, end: Int)
    
    /// - returns: the minimum y-value this DataSet holds
    var yMin: Double { get }
    
    /// - returns: the maximum y-value this DataSet holds
    var yMax: Double { get }
    
    /// - returns: the number of y-values this DataSet represents
    var entryCount: Int { get }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    func yValForXIndex(x: Int) -> Double
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    func entryForIndex(i: Int) -> ChartDataEntry?
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    func entryForXIndex(x: Int) -> ChartDataEntry?
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    func entryIndex(xIndex x: Int) -> Int
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    func entryIndex(entry e: ChartDataEntry) -> Int
    
    /// Adds an Entry to the DataSet dynamically.
    ///
    /// *optional feature, can return false or throw*
    ///
    /// Entries are added to the end of the list.
    /// - parameter e: the entry to add
    /// - returns: true if the entry was added successfully, else if this feature is not supported
    func addEntry(e: ChartDataEntry) -> Bool
    
    /// Removes an Entry from the DataSet dynamically.
    ///
    /// *optional feature, can return false or throw*
    ///
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist or if this feature is not supported
    func removeEntry(entry: ChartDataEntry) -> Bool
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    func contains(e: ChartDataEntry) -> Bool
    
    // MARK: - Styling functions and accessors
    
    /// The label string that describes the DataSet.
    var label: String? { get }
    
    /// The axis this DataSet should be plotted against.
    var axisDependency: ChartYAxis.AxisDependency { get }
    
    /// All the colors that are set for this DataSet
    var colors: [UIColor] { get }
    
    /// - returns: the color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    func colorAt(var index: Int) -> UIColor
    
    func resetColors()
    
    func addColor(color: UIColor)
    
    func setColor(color: UIColor)
    
    /// if true, value highlighting is enabled
    var highlightEnabled: Bool { get set }
    
    /// - returns: true if value highlighting is enabled for this dataset
    var isHighlightEnabled: Bool { get }
    
    /// The formatter used to customly format the values
    var valueFormatter: NSNumberFormatter? { get set }
    
    /// the color used for the value-text
    var valueTextColor: UIColor { get set }
    
    /// the font for the value-text labels
    var valueFont: UIFont { get set }
    
    /// Set this to true to draw y-values on the chart
    var drawValuesEnabled: Bool { get set }
    
    /// Returns true if y-value drawing is enabled, false if not
    var isDrawValuesEnabled: Bool { get }
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    var visible: Bool { get set }
    
    /// Returns true if this DataSet is visible inside the chart, or false if it is currently hidden.
    var isVisible: Bool { get }
}
