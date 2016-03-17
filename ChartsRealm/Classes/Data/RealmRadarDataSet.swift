//
//  RealmRadarDataSet.swift
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

public class RealmRadarDataSet: RealmLineRadarDataSet, IRadarChartDataSet
{
    public override func initialize()
    {
        self.valueFont = NSUIFont.systemFontOfSize(13.0)
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// - default: false
    public var drawHighlightCircleEnabled: Bool = false
    
    public var isDrawHighlightCircleEnabled: Bool { return drawHighlightCircleEnabled }
    
    public var highlightCircleFillColor: UIColor? = UIColor.whiteColor()
    
    /// The stroke color for highlight circle.
    /// If `nil`, the the color of the dataset is taken.
    public var highlightCircleStrokeColor: UIColor?
    
    public var highlightCircleStrokeAlpha: CGFloat = 0.3
    
    public var highlightCircleInnerRadius: CGFloat = 3.0
    
    public var highlightCircleOuterRadius: CGFloat = 4.0
    
    public var highlightCircleStrokeWidth: CGFloat = 2.0
}