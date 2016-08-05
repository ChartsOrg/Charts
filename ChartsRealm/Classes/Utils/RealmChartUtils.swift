//
//  RealmChartUtils.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 1/17/16.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import Realm

public class RealmChartUtils: NSObject
{
    /// Transforms the given Realm-ResultSet into an xValue array, using the specified xValueField
    public static func toXVals(results: RLMResults<RLMObject>, xValueField: String) -> [String]
    {
        let addedValues = NSMutableSet()
        var xVals = [String]()
        
        for object in results
        {
            let xVal = (object as! RLMObject)[xValueField] as! String!
            if !addedValues.contains(xVal!)
            {
                addedValues.add(xVal!)
                xVals.append(xVal!)
            }
        }
        
        return xVals
    }
}

extension RLMResults: Sequence
{
    public func makeIterator() -> NSFastEnumerationIterator
    {
        return NSFastEnumerationIterator(self)
    }
}

extension RLMArray: Sequence
{
    public func makeIterator() -> NSFastEnumerationIterator
    {
        return NSFastEnumerationIterator(self)
    }
}
