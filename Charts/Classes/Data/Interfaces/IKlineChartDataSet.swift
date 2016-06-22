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
     var MA5Color: NSUIColor? { get set }
     var MA10Color: NSUIColor? { get set }
     var MA30Color: NSUIColor? { get set }
}