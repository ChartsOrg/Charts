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

public class PieChartDataEntry: ChartDataEntry
{
    public required init()
    {
        super.init()
    }
    
    /// - parameter value: The value on the y-axis.
    /// - parameter label: The label for the x-axis
    /// - parameter data: Spot for additional data this Entry represents.
    public init(value: Double, label: String?, data: AnyObject?)
    {
        super.init(x: 0.0, y: value, data: data)
        
        self.label = label
    }
    
    /// - parameter value: The value on the y-axis.
    /// - parameter label: The label for the x-axis
    public convenience init(value: Double, label: String?)
    {
        self.init(value: value, label: label, data: nil)
    }
    
    /// - parameter value: The value on the y-axis.
    /// - parameter data: Spot for additional data this Entry represents.
    public convenience init(value: Double, data: AnyObject?)
    {
        self.init(value: value, label: nil, data: data)
    }
    
    /// - parameter value: The value on the y-axis.
    public convenience init(value: Double)
    {
        self.init(value: value, label: nil, data: nil)
    }
    
    // MARK: Data property accessors
    
    public var label: String?
    
    public var value: Double
    {
        get { return y }
        set { y = value }
    }
    
    @available(*, deprecated=1.0, message="Pie entries do not have x values")
    public override var x: Double
    {
        get
        {
            print("Pie entries do not have x values");
            return super.x
        }
        set
        {
            super.x = newValue
            print("Pie entries do not have x values");
        }
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! PieChartDataEntry
        copy.label = label
        return copy
    }
}