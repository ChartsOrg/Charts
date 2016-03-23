//
//  IRadarChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

@objc
public protocol IRadarChartDataSet: ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// 绘制连接点为一个圆
    var drawCircleEnabled : Bool { get set }
    
    /// 连接点圆圈的半径
    var drawCircleRadius : CGFloat { get set }
    
    /// 连接点圆圈的边框颜色
    var drawCircleStrokeColor : UIColor {get set}
    
    ///连接点圆圈的填充色
    var drawCircleFillColor : UIColor {get set}
}
