//
//  CHRTLineChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTLineChartView: Charts.LineChartView {
    open override var lineData: LineChartData? {
        data as? LineChartData
    }
}
