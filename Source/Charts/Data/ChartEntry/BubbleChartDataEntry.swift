//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

open class BubbleChartDataEntry: ChartDataEntry {
    /// The size of the bubble.
    open var size = CGFloat(0.0)

    public required init() {
        super.init()
    }

    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    public init(x: Double, y: Double, size: CGFloat) {
        super.init(x: x, y: y)

        self.size = size
    }

    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - data: Spot for additional data this Entry represents.
    public convenience init(x: Double, y: Double, size: CGFloat, data: Any?) {
        self.init(x: x, y: y, size: size)
        self.data = data
    }

    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - icon: icon image
    public convenience init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?) {
        self.init(x: x, y: y, size: size)
        self.icon = icon
    }

    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents.
    public convenience init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?, data: Any?) {
        self.init(x: x, y: y, size: size)
        self.icon = icon
        self.data = data
    }

    // MARK: NSCopying

    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! BubbleChartDataEntry
        copy.size = size
        return copy
    }
}
