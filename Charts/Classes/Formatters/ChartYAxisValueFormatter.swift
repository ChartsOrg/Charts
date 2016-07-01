//
//  ChartYAxisValueFormatter.swift
//  Charts
//
//  Created by 迅牛 on 16/6/30.
//  Copyright © 2016年 dcg. All rights reserved.
//

import Foundation

/// An interface for providing custom x-axis Strings.
@objc
public protocol ChartYAxisValueFormatter
{
    
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns: the customized label that is drawn on the x-axis.
    /// - parameter index:           the x-index that is currently being drawn
    /// - parameter original:        the original x-axis label to be drawn
    /// - parameter viewPortHandler: provides information about the current chart state (scale, translation, ...)
    ///
    func stringForNumber(number:NSNumber, xIndex: Int, max:Double) -> String
    
}