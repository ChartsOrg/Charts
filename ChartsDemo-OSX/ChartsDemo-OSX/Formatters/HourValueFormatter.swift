//
//  FeedItem.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts


import Foundation
import Charts

open class HourValueFormatter : NSObject, IAxisValueFormatter
{
    var dateFormatter : DateFormatter
    
    public override init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as TimeZone!
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let date2 = Date(timeIntervalSince1970 : (value ))
        return dateFormatter.string(from: date2)
    }
}

