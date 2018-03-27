//
//  SWFTBarChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public struct SWFTBarChartDataEntry: DataEntryProtocol {

    public let y: Double

    public let x: Double

    public var data: Any?

    public var icon: NSUIImage?

    /// the values the stacked barchart holds
    public private(set) var yValues: [Double]?

    /// the values the stacked barchart holds
    public var isStacked: Bool { return yValues != nil }

    /// the ranges for the individual stack values - automatically calculated
    public private(set) var ranges: [ClosedRange<Double>]?

    /// the sum of all negative values this entry (if stacked) contains
    public private(set) var negativeSum = 0.0

    /// the sum of all positive values this entry (if stacked) contains
    public private(set) var positiveSum = 0.0

    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    public init(x: Double, y: Double, icon: NSUIImage? = nil, data: Any? = nil) {
        self.x = x
        self.y = y
        self.icon = icon
        self.data = data
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    public init(x: Double, yValues: [Double], icon: NSUIImage? = nil, data: Any? = nil) {
        self.init(x: x, y: yValues.sum(), icon: icon, data: data)
        self.yValues = yValues
        (positiveSum, negativeSum) = calculatePositiveAndNegativeSums(from: yValues)
        ranges = makeRanges(from: yValues)
    }

    public func sumBelow(stackIndex: Int) -> Double {
        guard let yVals = yValues else {
            assertionFailure("\(self) is not stacked")
            return 0
        }

        let sum = yVals[(stackIndex + 1)...].sum()
        return Double(sum)
    }

    public func calculatePositiveAndNegativeSums(from values: [Double]) -> (postive: Double,  negative: Double) {
        var positiveSum = 0.0
        var negativeSum = 0.0

        for val in values {
            if y < 0 {
                negativeSum += abs(val)
            } else {
                positiveSum += val
            }
        }

        return (positiveSum, negativeSum)
    }

    /// Splits up the stack-values of the given bar-entry into Range objects.
    public func makeRanges(from values: [Double]) -> [ClosedRange<Double>] {
        var ranges = [ClosedRange<Double>]()
        ranges.reserveCapacity(values.count)

        var (negRemain, posRemain) = (-negativeSum, 0.0)

        for value in values {
            if value < 0 {
                ranges.append(negRemain...negRemain - value)
                negRemain -= value
            } else {
                ranges.append(posRemain...posRemain - value)
                posRemain += value
            }
        }

        return ranges
    }
}
