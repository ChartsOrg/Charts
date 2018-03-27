//
//  SWFTPieChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public struct SWFTPieChartDataEntry: DataEntryProtocol {

    public let y: Double

    public let x: Double = .nan

    public var data: Any?

    public var icon: NSUIImage?

    public let label: String?

    public var value: Double { return y }

    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    public init(value: Double, label: String?, icon: NSUIImage? = nil, data: AnyObject? = nil) {
        self.y = value
        self.icon = icon
        self.data = data
        self.label = label
    }

    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    public init(value: Double, icon: NSUIImage? = nil, data: AnyObject? = nil) {
        self.init(value: value, label: nil, icon: icon, data: data)
    }
}
