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
#if NEEDS_CHARTS
import Charts
#endif
import Realm
import RealmSwift
import Realm.Dynamic

open class RealmBubbleDataSet: RealmBarLineScatterCandleBubbleDataSet, IBubbleChartDataSet
{
    open override func initialize()
    {
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults<RLMObject>?, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(results: results, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: Results<Object>?, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, xValueField: xValueField, yValueField: yValueField, sizeField: sizeField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, xValueField: String, yValueField: String, sizeField: String)
    {
        self.init(results: results, xValueField: xValueField, yValueField: yValueField, sizeField: sizeField, label: "DataSet")
    }
    
    public convenience init(results: Results<Object>?, xValueField: String, yValueField: String, sizeField: String)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, xValueField: xValueField, yValueField: yValueField, sizeField: sizeField)
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(realm: Realm?, modelName: String, resultsWhere: String, xValueField: String, yValueField: String, sizeField: String, label: String?)
    {
        var converted: RLMRealm?
        
        if realm != nil
        {
            converted = ObjectiveCSupport.convert(object: realm!)
        }
        
        self.init(realm: converted, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, sizeField: sizeField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _sizeField: String?
    
    internal var _maxSize = CGFloat(0.0)
    
    open var maxSize: CGFloat { return _maxSize }
    open var normalizeSizeEnabled: Bool = true
    open var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, x: Double) -> ChartDataEntry
    {
        let entry = BubbleChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, y: object[_yValueField!] as! Double, size: object[_sizeField!] as! CGFloat)
        
        return entry
    }
    
    open override func calcMinMax()
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
    open var highlightCircleWidth: CGFloat = 2.5
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBubbleDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}
