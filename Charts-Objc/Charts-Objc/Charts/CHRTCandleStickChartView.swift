//
//  CHRTCandleStickChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTCandleStickChartView: Charts.CandleStickChartView {
    open override var candleData: CandleChartData? {
        data as? CandleChartData
    }
}
