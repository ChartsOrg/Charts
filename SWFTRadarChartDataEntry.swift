//
//  SWFTRadarChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public struct SWFTRadarChartDataEntry: DataEntryProtocol {

    public let y: Double

    public let x: Double = .nan

    public var data: Any?

    /// Unavailable in Radar Charts
    public var icon: NSUIImage? = nil

    public var value: Double { return y }

    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    public init(value: Double, data: Any? = nil) {
        self.y = value
        self.data = data
    }
}
