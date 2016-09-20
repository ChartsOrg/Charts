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
//  https://github.com/danielgindi/Charts
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
    
    /// - returns: all of the y values of the Entry objects at the given xIndex. Returns NaN if no value is at the given x-index.
    func yValsForXIndex(x: Int) -> [Double]
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    func entryForIndex(i: Int) -> ChartDataEntry?
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    func entryForXIndex(x: Int, rounding: ChartDataSetRounding) -> ChartDataEntry?
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    func entryForXIndex(x: Int) -> ChartDataEntry?
    
    /// - returns: all Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    func entriesForXIndex(x: Int) -> [ChartDataEntry]
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    /// - parameter rounding: x-index of the entry to search for
    func entryIndex(xIndex x: Int, rounding: ChartDataSetRounding) -> Int
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    func entryIndex(entry e: ChartDataEntry) -> Int
    
    /// Adds an Entry to the DataSet dynamically.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// Entries are added to the end of the list.
    /// - parameter e: the entry to add
    /// - returns: true if the entry was added successfully, false if this feature is not supported
    func addEntry(e: ChartDataEntry) -> Bool
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// Entries are added to the end of the list.
    /// - parameter e: the entry to add
    /// - returns: true if the entry was added successfully, false if this feature is not supported
    func addEntryOrdered(e: ChartDataEntry) -> Bool
    
    /// Removes an Entry from the DataSet dynamically.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, false if the entry does not exist or if this feature is not supported
    func removeEntry(entry: ChartDataEntry) -> Bool
    
    /// Removes the Entry object that has the given xIndex from the DataSet.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// - parameter xIndex: the xIndex to remove
    /// - returns: true if the entry was removed successfully, false if the entry does not exist or if this feature is not supported
    func removeEntry(xIndex xIndex: Int) -> Bool
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// - returns: true if the entry was removed successfully, false if the entry does not exist or if this feature is not supported
    func removeFirst() -> Bool
    
    /// Removes the last Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return false if not implemented*
    ///
    /// - returns: true if the entry was removed successfully, false if the entry does not exist or if this feature is not supported
    func removeLast() -> Bool
    
    /// Checks if this DataSet contains the specified Entry.
    ///
    /// - returns: true if contains the entry, false if not.
    func contains(e: ChartDataEntry) -> Bool
    
    /// Removes all values from this DataSet and does all necessary recalculations.
    ///
    /// *optional feature, could throw if not implemented*
    func clear()
    
    // MARK: - Styling functions and accessors
    
    /// The label string that describes the DataSet.
    var label: String? { get }
    
    /// The axis this DataSet should be plotted against.
    var axisDependency: ChartYAxis.AxisDependency { get }
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    var valueColors: [NSUIColor] { get }
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    var colors: [NSUIColor] { get }
    
    /// - returns: the color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    func colorAt(index: Int) -> NSUIColor
    
    func resetColors()
    
    func addColor(color: NSUIColor)
    
    func setColor(color: NSUIColor)
    
    /// if true, value highlighting is enabled
    var highlightEnabled: Bool { get set }
    
    /// - returns: true if value highlighting is enabled for this dataset
    var isHighlightEnabled: Bool { get }
    
    /// The formatter used to customly format the values
    var valueFormatter: NSNumberFormatter? { get set }
    
    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    var valueTextColor: NSUIColor { get set }
    
    /// - returns: the color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    func valueTextColorAt(index: Int) -> NSUIColor
    
    /// the font for the value-text labels
    var valueFont: NSUIFont { get set }
    
    /// Set this to true to draw y-values on the chart
    var drawValuesEnabled: Bool { get set }
    
    /// Returns true if y-value drawing is enabled, false if not
    var isDrawValuesEnabled: Bool { get }
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    var visible: Bool { get set }
    
    /// Returns true if this DataSet is visible inside the chart, or false if it is currently hidden.
    var isVisible: Bool { get }
}
