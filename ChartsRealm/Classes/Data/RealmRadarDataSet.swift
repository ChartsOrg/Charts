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

import Charts
import Realm
import Realm.Dynamic

public class RealmRadarDataSet: RealmLineRadarDataSet, IRadarChartDataSet
{
    public override func initialize()
    {
        self.valueFont = NSUIFont.systemFontOfSize(13.0)
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults?, yValueField: String, label: String?)
    {
        super.init(results: results, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, yValueField: String)
    {
        self.init(results: results, yValueField: yValueField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal override func buildEntryFromResultObject(object: RLMObject, x: Double) -> ChartDataEntry
    {
        return RadarChartDataEntry(value: object[_yValueField!] as! Double)
    }
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// **default**: false
    public var drawHighlightCircleEnabled: Bool = false
    
    /// - returns: `true` if highlight circle should be drawn, `false` ifnot
    public var isDrawHighlightCircleEnabled: Bool { return drawHighlightCircleEnabled }
    
    public var highlightCircleFillColor: NSUIColor? = NSUIColor.whiteColor()
    
    /// The stroke color for highlight circle.
    /// If `nil`, the color of the dataset is taken.
    public var highlightCircleStrokeColor: NSUIColor?
    
    public var highlightCircleStrokeAlpha: CGFloat = 0.3
    
    public var highlightCircleInnerRadius: CGFloat = 3.0
    
    public var highlightCircleOuterRadius: CGFloat = 4.0
    
    public var highlightCircleStrokeWidth: CGFloat = 2.0
}