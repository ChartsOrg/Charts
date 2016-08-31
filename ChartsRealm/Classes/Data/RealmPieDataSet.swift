//
//  RealmPieDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

import Charts
import Realm
import Realm.Dynamic

open class RealmPieDataSet: RealmBaseDataSet, IPieChartDataSet
{
    open override func initialize()
    {
        self.valueTextColor = NSUIColor.white
        self.valueFont = NSUIFont.systemFont(ofSize: 13.0)
    }
    
    // MARK: - Styling functions and accessors
    
    private var _sliceSpace = CGFloat(0.0)
    
    /// the space in pixels between the pie-slices
    /// **default**: 0
    /// **maximum**: 20
    open var sliceSpace: CGFloat
    {
        get
        {
            return _sliceSpace
        }
        set
        {
            var space = newValue
            if (space > 20.0)
            {
                space = 20.0
            }
            if (space < 0.0)
            {
                space = 0.0
            }
            _sliceSpace = space
        }
    }
    
    /// indicates the selection distance of a pie slice
    open var selectionShift = CGFloat(18.0)
    
    open var xValuePosition: PieChartDataSet.ValuePosition = .insideSlice
    open var yValuePosition: PieChartDataSet.ValuePosition = .insideSlice
    
    /// When valuePosition is OutsideSlice, indicates line color
    open var valueLineColor: NSUIColor? = NSUIColor.black
    
    /// When valuePosition is OutsideSlice, indicates line width
    open var valueLineWidth: CGFloat = 1.0
    
    /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
    open var valueLinePart1OffsetPercentage: CGFloat = 0.75
    
    /// When valuePosition is OutsideSlice, indicates length of first half of the line
    open var valueLinePart1Length: CGFloat = 0.3
    
    /// When valuePosition is OutsideSlice, indicates length of second half of the line
    open var valueLinePart2Length: CGFloat = 0.4
    
    /// When valuePosition is OutsideSlice, this allows variable line length
    open var valueLineVariableLength: Bool = true
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! RealmPieDataSet
        copy._sliceSpace = _sliceSpace
        copy.selectionShift = selectionShift
        return copy
    }
}
