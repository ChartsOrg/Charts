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
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// **default**: false
    public var drawHighlightCircleEnabled: Bool = false
    
    /// - returns: true if highlight circle should be drawn, false if not
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