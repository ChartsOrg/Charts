//
//  CHRTScatterChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTScatterChartView: ScatterChartView {
    open override var scatterData: ScatterChartData? {
        data as? ScatterChartData
    }
}
