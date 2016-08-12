//
//  RealmBubbleDataSet.swift
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

import Charts
import Realm
import Realm.Dynamic

public class RealmBubbleDataSet: RealmBarLineScatterCandleBubbleDataSet, IBubbleChartDataSet
{
    public override func initialize()
    {
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults?, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(results: results, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, xValueField: String, yValueField: String, sizeField: String)
    {
        self.init(results: results, xValueField: xValueField, yValueField: yValueField, sizeField: sizeField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _sizeField: String?
    
    internal var _maxSize = CGFloat(0.0)
    
    public var maxSize: CGFloat { return _maxSize }
    public var normalizeSizeEnabled: Bool = true
    public var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    internal override func buildEntryFromResultObject(object: RLMObject, x: Double) -> ChartDataEntry
    {
        let entry = BubbleChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, y: object[_yValueField!] as! Double, size: object[_sizeField!] as! CGFloat)
        
        return entry
    }
    
    public override func calcMinMax()
    {
        if _cache.count == 0
        {
            return
        }
        
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        _xMax = -DBL_MAX
        _xMin = DBL_MAX
        
        for e in _cache as! [BubbleChartDataEntry]
        {
            calcMinMax(entry: e)
            
            let size = e.size
            
            if size > _maxSize
            {
                _maxSize = size
            }
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    public var highlightCircleWidth: CGFloat = 2.5
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBubbleDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}