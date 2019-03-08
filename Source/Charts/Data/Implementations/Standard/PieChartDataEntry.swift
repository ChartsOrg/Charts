//
//  PieChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class PieChartDataEntry: ChartDataEntry
{
    public required init()
    {
        super.init()
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    @objc public convenience init(value: Double, label: String?)
    {
        self.init(value: value, label: label, icon: nil, data: nil)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, label: String?, data: AnyObject?)
    {
        self.init(value: value, label: label, icon: nil, data: data)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - icon: icon image
    @objc public convenience init(value: Double, label: String?, icon: NSUIImage?)
    {
        self.init(value: value, label: label, icon: icon, data: nil)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents
    @objc public init(value: Double, label: String?, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: 0.0, y: value, icon: icon, data: data)
        
        self.label = label
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    @objc public convenience init(value: Double)
    {
        self.init(value: value, label: nil, icon: nil, data: nil)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, data: AnyObject?)
    {
        self.init(value: value, label: nil, icon: nil, data: data)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - icon: icon image
    @objc public convenience init(value: Double, icon: NSUIImage?)
    {
        self.init(value: value, label: nil, icon: icon, data: nil)
    }
    
    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents
    @objc public convenience init(value: Double, icon: NSUIImage?, data: AnyObject?)
    {
        self.init(value: value, label: nil, icon: icon, data: data)
    }
    
    // MARK: Data property accessors
    
    @objc open var label: String?
    
    @objc open var value: Double
    {
        get { return y }
        set { y = newValue }
    }
        
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! PieChartDataEntry
        copy.label = label
        return copy
    }
}
