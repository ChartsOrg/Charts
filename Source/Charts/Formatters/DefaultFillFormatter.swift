//
//  DefaultFillFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

/// Default formatter that calculates the position of the filled line.
@objc(ChartDefaultFillFormatter)
open class DefaultFillFormatter: NSObject, IFillFormatter
{
    public typealias Block = (
        _ dataSet: ILineChartDataSet,
        _ dataProvider: LineChartDataProvider) -> CGFloat
    
    open var block: Block?
    
    public override init()
    {
        
    }
    
    public init(block: @escaping Block)
    {
        self.block = block
    }
    
    public static func with(block: @escaping Block) -> DefaultFillFormatter?
    {
        return DefaultFillFormatter(block: block)
    }
    
    open func getFillLinePosition(
        dataSet: ILineChartDataSet,
        dataProvider: LineChartDataProvider) -> CGFloat
    {
        if block != nil
        {
            return block!(dataSet, dataProvider)
        }
        else
        {
            var fillMin = CGFloat(0.0)
            
            if dataSet.yMax > 0.0 && dataSet.yMin < 0.0
            {
                fillMin = 0.0
            }
            else
            {
                if let data = dataProvider.data
                {
                    var max: Double, min: Double
                    
                    if data.yMax > 0.0
                    {
                        max = 0.0
                    }
                    else
                    {
                        max = dataProvider.chartYMax
                    }
                    
                    if data.yMin < 0.0
                    {
                        min = 0.0
                    }
                    else
                    {
                        min = dataProvider.chartYMin
                    }
                    
                    fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max)
                }
            }
            
            return fillMin
        }
    }
}
