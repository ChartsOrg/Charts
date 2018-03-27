//
//  SWFTCandleChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public struct SWFTCandleChartDataEntry: DataEntryProtocol {

    public let y: Double

    public let x: Double

    public var data: Any?

    public var icon: NSUIImage?

    /// shadow-high value
    public var high = 0.0

    /// shadow-low value
    public var low = 0.0

    /// close value
    public var close = 0.0

    /// open value
    public var open = 0.0

    public init(x: Double, shadowH: Double, shadowL: Double, open: Double, close: Double, icon: NSUIImage? = nil, data: Any? = nil) {
        self.x = x
        self.y = (shadowH + shadowL) / 2
        self.icon = icon
        self.data = data

        self.high = shadowH
        self.low = shadowL
        self.open = open
        self.close = close
    }

    /// The overall range (difference) between shadow-high and shadow-low.
    public var shadowRange: Double {
        return abs(high - low)
    }

    /// The body size (difference between open and close).
    public var bodyRange: Double {
        return abs(open - close)
    }
}
