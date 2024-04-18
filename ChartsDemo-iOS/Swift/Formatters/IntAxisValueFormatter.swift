//
//  IntAxisValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import DGCharts

public class IntAxisValueFormatter: NSObject, AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))"
    }
}
