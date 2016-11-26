//
//  RealmPieDataSet.swift
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
#if NEEDS_CHARTS
import Charts
#endif
import Realm
import Realm.Dynamic

open class RealmPieDataSet: RealmBaseDataSet, IPieChartDataSet
{
    open override func initialize()
    {
        self.valueTextColor = NSUIColor.white
        self.valueFont = NSUIFont.systemFont(ofSize: 13.0)
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults<RLMObject>?, yValueField: String, labelField: String?)
    {
        _labelField = labelField
        
        super.init(results: results, xValueField: nil, yValueField: yValueField, label: nil)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _labelField: String?
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, x: Double) -> ChartDataEntry
    {
        if _labelField == nil
        {
            return PieChartDataEntry(value: object[_yValueField!] as! Double)
        }
        else
        {
            return PieChartDataEntry(value: object[_yValueField!] as! Double, label: object[_labelField!] as? String)
        }
    }
        
    // MARK: - Styling functions and accessors
    
    fileprivate var _sliceSpace = CGFloat(0.0)
    
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
            if space > 20.0
            {
                space = 20.0
            }
            if space < 0.0
            {
                space = 0.0
            }
            _sliceSpace = space
        }
    }
    
    /// When enabled, slice spacing will be 0.0 when the smallest value is going to be smaller than the slice spacing itself.
    open var automaticallyDisableSliceSpacing: Bool = false
    
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
    
    /// the font for the slice-text labels
    open var entryLabelFont: NSUIFont? = nil
    
    /// the color for the slice-text labels
    open var entryLabelColor: NSUIColor? = nil
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmPieDataSet
        copy._sliceSpace = _sliceSpace
        copy.selectionShift = selectionShift
        return copy
    }
}
