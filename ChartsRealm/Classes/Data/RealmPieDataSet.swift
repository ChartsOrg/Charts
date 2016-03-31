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
//  https://github.com/danielgindi/ios-charts
//

import Foundation

import Charts
import Realm
import Realm.Dynamic

public class RealmPieDataSet: RealmBaseDataSet, IPieChartDataSet
{
    public override func initialize()
    {
        self.valueTextColor = NSUIColor.whiteColor()
        self.valueFont = NSUIFont.systemFontOfSize(13.0)
    }
    
    // MARK: - Styling functions and accessors
    
    private var _sliceSpace = CGFloat(0.0)
    
    /// the space in pixels between the pie-slices
    /// **default**: 0
    /// **maximum**: 20
    public var sliceSpace: CGFloat
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
    public var selectionShift = CGFloat(18.0)
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmPieDataSet
        copy._sliceSpace = _sliceSpace
        copy.selectionShift = selectionShift
        return copy
    }
    
    private var _needLineForLabel = Bool(false)
    
    /// the  draw the value outside the slice
    public var needLineForLabel: Bool
        {
        get
        {
            return _needLineForLabel
        }
        set
        {
            _needLineForLabel = newValue
        }
    }
    
    private var _needLabelColorSameAsSlice = Bool(false)
    
    /// the  draw the value the same color as slice
    public var needLabelColorSameAsSlice: Bool
        {
        get
        {
            return _needLabelColorSameAsSlice
        }
        set
        {
            _needLabelColorSameAsSlice = newValue
        }
    }
}