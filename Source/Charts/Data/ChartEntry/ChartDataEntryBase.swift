//
//  ChartDataEntryBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartDataEntryBase: CustomStringConvertible
{
    /// the y value
    open var y = 0.0
    
    /// optional spot for additional data this Entry represents
    open var data: Any?
    
    /// optional icon image
    open var icon: NSUIImage?
    
    public required init()
    {
    }
    
    /// An Entry represents one single entry in the chart.
    ///
    /// - Parameters:
    ///   - y: the y value (the actual value of the entry)
    public init(y: Double)
    {        
        self.y = y
    }
    
    /// - Parameters:
    ///   - y: the y value (the actual value of the entry)
    ///   - data: Space for additional data this Entry represents.
    
    public convenience init(y: Double, data: Any?)
    {
        self.init(y: y)
        
        self.data = data
    }
    
    /// - Parameters:
    ///   - y: the y value (the actual value of the entry)
    ///   - icon: icon image
    
    public convenience init(y: Double, icon: NSUIImage?)
    {
        self.init(y: y)

        self.icon = icon
    }
    
    /// - Parameters:
    ///   - y: the y value (the actual value of the entry)
    ///   - icon: icon image
    ///   - data: Space for additional data this Entry represents.
    
    public convenience init(y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(y: y)

        self.icon = icon
        self.data = data
    }

    // MARK: - CustomStringConvertible

    open var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
}

// MARK: Equatable
extension ChartDataEntryBase: Equatable {
    public static func == (lhs: ChartDataEntryBase, rhs: ChartDataEntryBase) -> Bool {
        if lhs === rhs {
            return true
        }

        return lhs.y == rhs.y
    }
}
