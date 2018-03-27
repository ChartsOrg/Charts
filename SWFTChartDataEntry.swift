//
//  SWFTChartDataEntry.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public protocol OneDimensionalData: Comparable {
    
    /// the y value
    var y: Double { get }
}

extension OneDimensionalData {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.y < rhs.y
    }
}

public protocol TwoDimensionalData: OneDimensionalData, CustomStringConvertible {
    
    /// the x value
    var x: Double { get }
}

extension TwoDimensionalData {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.x == rhs.x {
            return lhs.y < rhs.y
        } else {
            return lhs.x < rhs.x
        }
    }
}

extension TwoDimensionalData {
    
    public var description: String {
        return "\(Self.self), x: \(x), y \(y)"
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
    }
}

public protocol DataEntryProtocol: TwoDimensionalData {
    
    /// optional spot for additional data this Entry represents
    var data: Any? { get set }
    
    /// optional icon image
    var icon: NSUIImage? { get set }
}

public struct DataEntry: DataEntryProtocol {
    
    public let y: Double
    
    public let x: Double
    
    public var data: Any?
    
    public var icon: NSUIImage?
    
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
}
