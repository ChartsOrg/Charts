//
//  CHRTCombinedChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
public enum CombinedChartDrawOrder: Int {
    case bar, bubble, candle, line, scatter

    internal var drawOrder: Charts.CombinedChartView.DrawOrder {
        switch self {
        case .bar: return .bar
        case .bubble: return .bubble
        case .candle: return .candle
        case .line: return .line
        case .scatter: return .scatter
        }
    }

    internal init(_ drawOrder: Charts.CombinedChartView.DrawOrder) {
        switch drawOrder {
        case .bar: self = .bar
        case .bubble: self = .bubble
        case .candle: self = .candle
        case .line: self = .line
        case .scatter: self = .scatter
        }
    }
}

@objc
@objcMembers
open class CHRTCombinedChartView: Charts.CombinedChartView {
    open override var data: ChartData? {
        get { super.data }
        set { super.data = newValue }
    }

    @objc(drawOrder)
    open var chartDrawOrder: [Int] {
        get { super.drawOrder.map(CombinedChartDrawOrder.init).map(\.rawValue) }
        set {
            super.drawOrder = newValue
                .compactMap(CombinedChartDrawOrder.init)
                .map(\.drawOrder)
        }
    }

    open override var fillFormatter: FillFormatter {
        get { super.fillFormatter }
        set { super.fillFormatter = newValue }
    }

    open override var drawValueAboveBarEnabled: Bool {
        get { super.drawValueAboveBarEnabled }
        set { super.drawValueAboveBarEnabled = newValue }
    }

    open override var drawBarShadowEnabled: Bool {
        get { super.drawBarShadowEnabled }
        set { super.drawBarShadowEnabled = newValue }
    }

    open override var highlightFullBarEnabled: Bool {
        get { super.highlightFullBarEnabled }
        set { super.highlightFullBarEnabled = newValue }
    }

    // MARK: - CombinedChartDataProvider

    open override var combinedData: CombinedChartData? {
        data as? CombinedChartData
    }

    open override var lineData: LineChartData? {
        combinedData?.lineData
    }

    open override var barData: BarChartData? {
        combinedData?.barData
    }

    open override var scatterData: ScatterChartData? {
        combinedData?.scatterData
    }

    open override var candleData: CandleChartData? {
        combinedData?.candleData
    }

    open override var bubbleData: BubbleChartData? {
        combinedData?.bubbleData
    }

    // MARK: - Methods

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        super.getHighlightByTouchPoint(pt)
    }
}
