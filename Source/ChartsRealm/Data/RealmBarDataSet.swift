//
//  RealmBarDataSet.swift
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

open class RealmBarDataSet: RealmBarLineScatterCandleBubbleDataSet, IBarChartDataSet
{
    open override func initialize()
    {
        self.highlightColor = NSUIColor.black
    }
    
    public required init()
    {
        super.init()
    }
    
    public override init(results: RLMResults<RLMObject>?, xValueField: String?, yValueField: String, label: String?)
    {
        super.init(results: results, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public init(results: RLMResults<RLMObject>?, xValueField: String?, yValueField: String, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(results: results, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: Results<Object>?, xValueField: String?, yValueField: String, stackValueField: String, label: String?)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, xValueField: xValueField, yValueField: yValueField, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, xValueField: String?, yValueField: String, stackValueField: String)
    {
        self.init(results: results, xValueField: xValueField, yValueField: yValueField, stackValueField: stackValueField, label: "DataSet")
    }
    
    public convenience init(results: Results<Object>?, xValueField: String?, yValueField: String, stackValueField: String)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, xValueField: xValueField, yValueField: yValueField, stackValueField: stackValueField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, stackValueField: String, label: String)
    {
        self.init(results: results, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(results: Results<Object>?, yValueField: String, stackValueField: String, label: String)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, yValueField: yValueField, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, stackValueField: String)
    {
        self.init(results: results, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField)
    }
    
    public convenience init(results: Results<Object>?, yValueField: String, stackValueField: String)
    {
        var converted: RLMResults<RLMObject>?
        
        if results != nil
        {
            converted = ObjectiveCSupport.convert(object: results!)
        }
        
        self.init(results: converted, yValueField: yValueField, stackValueField: stackValueField)
    }
    
    public override init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(realm: Realm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, stackValueField: String, label: String?)
    {
        var converted: RLMRealm?
        
        if realm != nil
        {
            converted = ObjectiveCSupport.convert(object: realm!)
        }
        
        self.init(realm: converted, modelName: modelName, resultsWhere: resultsWhere, xValueField: xValueField, yValueField: yValueField, label: label)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, stackValueField: String)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField)
    }
    
    public convenience init(realm: Realm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, stackValueField: String)
    {
        var converted: RLMRealm?
        
        if realm != nil
        {
            converted = ObjectiveCSupport.convert(object: realm!)
        }
        
        self.init(realm: converted, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String, label: String?)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(realm: Realm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String, label: String?)
    {
        var converted: RLMRealm?
        
        if realm != nil
        {
            converted = ObjectiveCSupport.convert(object: realm!)
        }
        
        self.init(realm: converted, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField, label: nil)
    }
    
    public convenience init(realm: Realm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String)
    {
        var converted: RLMRealm?
        
        if realm != nil
        {
            converted = ObjectiveCSupport.convert(object: realm!)
        }
        
        self.init(realm: converted, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, stackValueField: stackValueField, label: nil)
    }
    
    open override func notifyDataSetChanged()
    {
        super.notifyDataSetChanged()
        self.calcStackSize(entries: _cache as! [BarChartDataEntry])
    }
    
    // MARK: - Data functions and accessors
    
    internal var _stackValueField: String?
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    fileprivate var _stackSize = 1
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, x: Double) -> ChartDataEntry
    {
        let value = object[_yValueField!]
        let entry: BarChartDataEntry
        
        if value is RLMArray
        {
            var values = [Double]()
            let iterator = NSFastEnumerationIterator(value as! RLMArray)
            while let val = iterator.next()
            {
                values.append((val as! RLMObject)[_stackValueField!] as! Double)
            }
            entry = BarChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, yValues: values)
        }
        else
        {
            entry = BarChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, y: value as! Double)
        }
        
        return entry
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    fileprivate func calcStackSize(entries: [BarChartDataEntry])
    {
        for i in 0 ..< entries.count
        {
            if let vals = entries[i].yValues
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
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
        
        for e in _cache as! [BarChartDataEntry]
        {
            if !e.y.isNaN
            {
                if e.yValues == nil
                {
                    if e.y < _yMin
                    {
                        _yMin = e.y
                    }
                    
                    if e.y > _yMax
                    {
                        _yMax = e.y
                    }
                }
                else
                {
                    if -e.negativeSum < _yMin
                    {
                        _yMin = -e.negativeSum
                    }
                    
                    if e.positiveSum > _yMax
                    {
                        _yMax = e.positiveSum
                    }
                }
                
                if e.x < _xMin
                {
                    _xMin = e.x
                }
                if e.x > _xMax
                {
                    _xMax = e.x
                }
            }
        }
    }
    
    /// - returns: The maximum number of bars that can be stacked upon another in this DataSet.
    open var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: `true` if this DataSet is stacked (stacksize > 1) or not.
    open var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// array of labels used to describe the different values of the stacked bars
    open var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    open var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    open var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    open var barBorderColor = NSUIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    open var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBarDataSet
        copy._stackSize = _stackSize
        copy.stackLabels = stackLabels
        copy.barShadowColor = barShadowColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}
