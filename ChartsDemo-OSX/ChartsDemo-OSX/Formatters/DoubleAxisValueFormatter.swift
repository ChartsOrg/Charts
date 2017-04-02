//
//  DoubleAxisValueFormatter.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Foundation
import Charts

/// Called when a value from an axis is formatted before being drawn.
///
/// For performance reasons, avoid excessive calculations and memory allocations inside this method.
///
/// - returns: The customized label that is drawn on the x-axis.
/// - parameter value:           the value that is currently being drawn
/// - parameter axis:            the axis that the value belongs to
///

open class DoubleAxisValueFormatter : NSObject, IAxisValueFormatter
{
    open var postFixe :String = ""
    
    public init(postFixe: String)
    {
        self.postFixe = postFixe
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if value > -1 && value < 1
        {
            //            let nb = abs(order(input: value) ) - 1
            formatter.minimumFractionDigits = 4
            formatter.maximumFractionDigits = 4
        } else
        {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            
        }
        formatter.localizesFormat = true
        let num = NSDecimalNumber(value: value)
        let strVal = formatter.string( from: num)
        
        let str = strVal! + " " + postFixe
        return str
    }
    
    func order(input: Double) -> (Int)
    {
        guard input != 0 else { return 0}
        var order = 0
        var temp = abs(input)
        if temp < 10 {
            while temp < 10
            {
                temp *= 10
                order -= 1
            }
        } else if temp > 1 {
            while temp > 1 {
                temp /= 10
                order += 1
            }
        }
        return order
    }
    
}
