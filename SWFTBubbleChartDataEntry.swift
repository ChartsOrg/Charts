//
//  SWFTBubbleChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public struct SWFTBubbleChartDataEntry: DataEntryProtocol {

    public let y: Double

    public let x: Double

    public var data: Any?

    public var icon: NSUIImage?

    /// The size of the bubble.
    public var size: CGFloat = 0

    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents.
    public init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?, data: Any?) {
        self.x = x
        self.y = y
        self.icon = icon
        self.data = data
        self.size = size
    }
}
