//
//  DateValueFormatter.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Foundation
import Charts

open class DateValueFormatter : NSObject, IAxisValueFormatter
{
    var dateFormatter : DateFormatter
    var miniTime: Double
    var interval: Double
    
    public init(miniTime: Double, interval: Double) {
        //super.init()
        self.miniTime = miniTime
        self.interval = interval
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MM HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as TimeZone!
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let date2 = Date(timeIntervalSince1970 : (value * interval ) + miniTime)
        return dateFormatter.string(from: date2)
    }
}
