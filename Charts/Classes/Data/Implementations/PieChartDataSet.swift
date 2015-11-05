//
//  PieChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 24/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

public class PieChartDataSet: ChartDataSet, IPieChartDataSet
{
    public required init()
    {
        super.init()
        
        self.valueTextColor = UIColor.whiteColor()
        self.valueFont = UIFont.systemFontOfSize(13.0)
        
        self.calcYValueSum()
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        
        self.valueTextColor = UIColor.whiteColor()
        self.valueFont = UIFont.systemFontOfSize(13.0)
        
        self.calcYValueSum()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _yValueSum = Double(0.0)
    
    public var yValueSum: Double { return _yValueSum }
    
    /// - returns: the average value across all entries in this DataSet.
    public var average: Double
    {
        return yValueSum / Double(valueCount)
    }
    
    private func calcYValueSum()
    {
        _yValueSum = 0
        
        for var i = 0; i < _yVals.count; i++
        {
            _yValueSum += fabs(_yVals[i].value)
        }
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        super.notifyDataSetChanged()
        calcYValueSum()
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public override func addEntry(e: ChartDataEntry) -> Bool
    {
        if super.addEntry(e)
        {
            _yValueSum += e.value
            return true
        }
        
        return false
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public override func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        if super.addEntryOrdered(e)
        {
            _yValueSum += e.value
            return true
        }
        
        return false
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public override func removeEntry(entry: ChartDataEntry) -> Bool
    {
        if super.removeEntry(entry)
        {
            _yValueSum -= entry.value
            return true
        }
        
        return false
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter xIndex: the xIndex of the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public override func removeEntry(xIndex xIndex: Int) -> Bool
    {
        let index = self.entryIndex(xIndex: xIndex)
        if index > -1
        {
            let e = _yVals[index]
            
            if super.removeEntry(e)
            {
                _yValueSum -= e.value
                return true;
            }
        }
        
        return false
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeFirst() -> Bool
    {
        if let entry: ChartDataEntry = _yVals.isEmpty ? nil : _yVals.first
        {
            if super.removeFirst()
            {
                _yValueSum -= entry.value
                return true
            }
        }
        
        return false
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeLast() -> Bool
    {
        if let entry: ChartDataEntry = _yVals.isEmpty ? nil : _yVals.last
        {
            if super.removeLast()
            {
                _yValueSum -= entry.value
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Styling functions and accessors
    
    private var _sliceSpace = CGFloat(0.0)
    
    /// the space that is left out between the piechart-slices, default: 0°
    /// --> no space, maximum 45, minimum 0 (no space)
    public var sliceSpace: CGFloat
    {
        get
        {
            return _sliceSpace
        }
        set
        {
            _sliceSpace = newValue
            if (_sliceSpace > 45.0)
            {
                _sliceSpace = 45.0
            }
            if (_sliceSpace < 0.0)
            {
                _sliceSpace = 0.0
            }
        }
    }
    
    /// indicates the selection distance of a pie slice
    public var selectionShift = CGFloat(18.0)
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! PieChartDataSet
        copy._yValueSum = _yValueSum
        copy._sliceSpace = _sliceSpace
        copy.selectionShift = selectionShift
        return copy
    }
}