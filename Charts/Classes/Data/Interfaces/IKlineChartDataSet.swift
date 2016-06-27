//
//  IKlineChartDataSet.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import Foundation
import CoreGraphics

@objc
public protocol IKlineChartDataSet: ICandleChartDataSet
{
     var MA5Color: NSUIColor { get set }
     var MA10Color: NSUIColor { get set }
     var MA30Color: NSUIColor { get set }
    var KDJ_KColor: NSUIColor { get set }
    var KDJ_DColor: NSUIColor { get set }
    var KDJ_JColor: NSUIColor { get set }
    var MACD_DIFColor: NSUIColor { get set }
    var MACD_DEAColor: NSUIColor { get set }
    var MACD_Color: NSUIColor { get set }
    
}