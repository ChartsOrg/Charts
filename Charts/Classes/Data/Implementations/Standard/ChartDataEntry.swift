//
//  ChartDataEntry.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class ChartDataEntry: NSObject
{
    /// the actual value (y axis)
    public var value = Double(0.0)
    
    /// the index on the x-axis
    public var xIndex = Int(0)
    
    /// optional spot for additional data this Entry represents
    public var data: AnyObject?
    
    public override required init()
    {
        super.init()
    }
    
    public init(value: Double, xIndex: Int)
    {
        super.init()
        
        self.value = value
        self.xIndex = xIndex
    }
    
    public init(value: Double, xIndex: Int, data: AnyObject?)
    {
        super.init()
        
        self.value = value
        self.xIndex = xIndex
        self.data = data
    }
    
    // MARK: NSObject
    
    public override func isEqual(_ object: AnyObject?) -> Bool
    {
        if (object === nil)
        {
            return false
        }
        
        if (!object!.isKind(of: self.dynamicType))
        {
            return false
        }

		if let d = object as? ChartDataEntry where d.data !== self.data || !d.isEqual(self.data)
		{
			return false
		}
        
        if (object!.xIndex != xIndex)
        {
            return false
        }
        
        if (fabs(object!.value - value) > 0.00001)
        {
            return false
        }
        
        return true
    }
    
    // MARK: NSObject
    
    public override var description: String
    {
        return "ChartDataEntry, xIndex: \(xIndex), value \(value)"
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = self.dynamicType.init()
        
        copy.value = value
        copy.xIndex = xIndex
        copy.data = data
        
        return copy
    }
}

public func ==(lhs: ChartDataEntry, rhs: ChartDataEntry) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKind(of: rhs.dynamicType))
    {
        return false
    }
    
    if (lhs.data !== rhs.data && !lhs.data!.isEqual(rhs.data))
    {
        return false
    }
    
    if (lhs.xIndex != rhs.xIndex)
    {
        return false
    }
    
    if (fabs(lhs.value - rhs.value) > 0.00001)
    {
        return false
    }
    
    return true
}
