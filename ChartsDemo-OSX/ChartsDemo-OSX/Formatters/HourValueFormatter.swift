//
//  DateValueFormatter.swift
//  graphPG
//
//  Created by thierryH24A on 20/09/2016.
//  Copyright © 2016 thierryH24A. All rights reserved.
//

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

