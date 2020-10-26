//
//  CHRTBubbleChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTBubbleChartView: Charts.BubbleChartView {
    open override var bubbleData: BubbleChartData? {
        data as? BubbleChartData
    }

    open override func initialize() {
        super.initialize()
    }
}
