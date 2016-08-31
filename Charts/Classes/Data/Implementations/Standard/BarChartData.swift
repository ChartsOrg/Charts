//
//  BarChartData.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class BarChartData: BarLineScatterCandleBubbleChartData
{
    public override init()
    {
        super.init()
    }
    
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    private var _groupSpace = CGFloat(0.8)
    
    /// The spacing is relative to a full bar width
    open var groupSpace: CGFloat
    {
        get
        {
            if (_dataSets.count <= 1)
            {
                return 0.0
            }
            return _groupSpace
        }
        set
        {
            _groupSpace = newValue
        }
    }
    
    /// - returns: true if this BarData object contains grouped DataSets (more than 1 DataSet).
    open var isGrouped: Bool
    {
        return _dataSets.count > 1 ? true : false
    }
}
