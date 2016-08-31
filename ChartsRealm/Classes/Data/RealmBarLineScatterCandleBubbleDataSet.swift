//
//  RealmBarLineScatterCandleBubbleDataSet.swift
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

import Charts
import Realm
import Realm.Dynamic

open class RealmBarLineScatterCandleBubbleDataSet: RealmBaseDataSet, IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    open var highlightColor = NSUIColor(red: 255.0/255.0, green: 187.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    open var highlightLineWidth = CGFloat(0.5)
    open var highlightLineDashPhase = CGFloat(0.0)
    open var highlightLineDashLengths: [CGFloat]?
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! RealmBarLineScatterCandleBubbleDataSet
        copy.highlightColor = highlightColor
        copy.highlightLineWidth = highlightLineWidth
        copy.highlightLineDashPhase = highlightLineDashPhase
        copy.highlightLineDashLengths = highlightLineDashLengths
        return copy
    }
}
