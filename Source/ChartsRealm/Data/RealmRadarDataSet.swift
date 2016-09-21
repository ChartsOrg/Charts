//
//  RealmRadarDataSet.swift
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

open class RealmRadarDataSet: RealmLineRadarDataSet, IRadarChartDataSet
{
    open override func initialize()
    {
        self.valueFont = NSUIFont.systemFont(ofSize: 13.0)
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults<RLMObject>?, yValueField: String, label: String?)
    {
        super.init(results: results, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String)
    {
        self.init(results: results, yValueField: yValueField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, x: Double) -> ChartDataEntry
    {
        return RadarChartDataEntry(value: object[_yValueField!] as! Double)
    }
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// **default**: false
    open var drawHighlightCircleEnabled: Bool = false
    
    /// - returns: `true` if highlight circle should be drawn, `false` ifnot
    open var isDrawHighlightCircleEnabled: Bool { return drawHighlightCircleEnabled }
    
    open var highlightCircleFillColor: NSUIColor? = NSUIColor.white
    
    /// The stroke color for highlight circle.
    /// If `nil`, the color of the dataset is taken.
    open var highlightCircleStrokeColor: NSUIColor?
    
    open var highlightCircleStrokeAlpha: CGFloat = 0.3
    
    open var highlightCircleInnerRadius: CGFloat = 3.0
    
    open var highlightCircleOuterRadius: CGFloat = 4.0
    
    open var highlightCircleStrokeWidth: CGFloat = 2.0
}
