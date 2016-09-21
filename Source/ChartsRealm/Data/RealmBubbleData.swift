//
//  RealmBubbleData.swift
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
#if NEEDS_CHARTS
import Charts
#endif
import Realm
import Realm.Dynamic

public class RealmBubbleData: BubbleChartData
{
    public init(results: RLMResults?, xValueField: String, dataSets: [IChartDataSet]?)
    {
        if results == nil
        {
            super.init(xVals: [String](), dataSets: dataSets)
        }
        else
        {
            super.init(xVals: RealmChartUtils.toXVals(results: results!, xValueField: xValueField), dataSets: dataSets)
        }
    }
}
