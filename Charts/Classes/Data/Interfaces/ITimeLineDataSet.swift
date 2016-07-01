//
//  ITimeLineDataSet.swift
//  Charts
//
//  Created by 迅牛 on 16/6/30.
//  Copyright © 2016年 dcg. All rights reserved.
//

import Foundation
import CoreGraphics


@objc
public protocol ITimeLineDataSet: ILineChartDataSet {
    
    var mainLineDataSets:[LineChartDataSet] { get }

    var qulificationBarDataSets:[BarChartDataSet] { get }
    
    /// color for open > close
    var increasingColor: NSUIColor { get set }
    
    /// color for open < close
    var decreasingColor: NSUIColor { get set }
    
    var avgColor:NSUIColor  { get set }
    
    var yMinRange:Double { get }
    var yMaxRange:Double { get }
}
