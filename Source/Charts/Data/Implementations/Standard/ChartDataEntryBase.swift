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
    @objc open var y = Double(0.0)
    
    /// optional spot for additional data this Entry represents
    @objc open var data: AnyObject?
    
    /// optional icon image
    @objc open var icon: NSUIImage?
    
    public override required init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter y: the y value (the actual value of the entry)
    @objc public init(y: Double)
    {
        super.init()
        
        self.y = y
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(y: Double, data: AnyObject?)
    {
        super.init()
        
        self.y = y
        self.data = data
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    @objc public init(y: Double, icon: NSUIImage?)
    {
        super.init()
        
        self.y = y
        self.icon = icon
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init()
        
        self.y = y
        self.icon = icon
        self.data = data
    }

    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
}

// MARK: Equatable
extension ChartDataEntryBase/*: Equatable*/ {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ChartDataEntryBase else { return false }

        if self === object
        {
            return true
        }

        return ((data == nil && object.data == nil) || (data?.isEqual(object.data) ?? false))
            && y == object.y
    }
}
