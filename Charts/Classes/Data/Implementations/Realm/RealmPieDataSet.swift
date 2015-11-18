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
import UIKit
import Realm
import Realm.Dynamic

public class RealmPieDataSet: RealmDataSet, IPieChartDataSet
{
    private func initialize()
    {
        self.valueTextColor = UIColor.whiteColor()
        self.valueFont = UIFont.systemFontOfSize(13.0)
        
        self.calcYValueSum()
    }
    
    public required init()
    {
        super.init()
    }
    
    public override init(results: RLMResults?, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: "DataSet")
        initialize()
    }
    
    public override init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _yValueSum: Double?
    
    public var yValueSum: Double
    {
        if _yValueSum == nil
        {
            calcYValueSum()
        }
        
        return _yValueSum ?? 0.0
    }
    
    /// - returns: the average value across all entries in this DataSet.
    public var average: Double
    {
        return yValueSum / Double(entryCount)
    }
    
    private func calcYValueSum()
    {
        if _yValueField == nil
        {
            _yValueSum = 0.0
        }
        else
        {
            _yValueSum = _results?.sumOfProperty(_yValueField!).doubleValue
        }
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        super.notifyDataSetChanged()
        calcYValueSum()
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
        let copy = super.copyWithZone(zone) as! RealmPieDataSet
        copy._yValueSum = _yValueSum
        copy._sliceSpace = _sliceSpace
        copy.selectionShift = selectionShift
        return copy
    }
}