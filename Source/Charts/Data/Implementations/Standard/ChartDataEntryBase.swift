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

open class ChartDataEntryBase: NSObject
{
    /// the y value
    open var y = Double(0.0)
    
    /// optional spot for additional data this Entry represents
    open var data: AnyObject?
    
    /// optional icon image
    open var icon: NSUIImage?
    
    public override required init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter y: the y value (the actual value of the entry)
    public init(y: Double)
    {
        super.init()
        
        self.y = y
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(y: Double, data: AnyObject?)
    {
        super.init()
        
        self.y = y
        self.data = data
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    public init(y: Double, icon: NSUIImage?)
    {
        super.init()
        
        self.y = y
        self.icon = icon
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init()
        
        self.y = y
        self.icon = icon
        self.data = data
    }
    
    // MARK: NSObject
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        guard let object = object as? ChartDataEntryBase else { return false }
        return self == object
    }
    
    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
}

// MARK: Equatable
extension ChartDataEntryBase/*: Equatable*/ {
    public static func ==(lhs: ChartDataEntryBase, rhs: ChartDataEntryBase) -> Bool
    {
        if lhs === rhs
        {
            return true
        }
        return lhs.isKind(of: type(of: rhs))
            && (lhs.data?.isEqual(rhs.data) ?? true)
            && lhs.y == rhs.y
    }
}
