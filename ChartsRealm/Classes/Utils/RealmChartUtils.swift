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

open class RealmChartUtils: NSObject
{
    /// Transforms the given Realm-ResultSet into an xValue array, using the specified xValueField
    open static func toXVals(results: RLMResults<RLMObject>, xValueField: String) -> [String]
    {
        let addedValues = NSMutableSet()
        var xVals = [String]()
        
        for object in results
        {
            let xVal = object[xValueField] as! String!
            if !addedValues.contains(xVal!)
            {
                addedValues.add(xVal!)
                xVals.append(xVal!)
            }
        }
        
        return xVals
    }
}
extension RLMObject {
    // Swift query convenience functions
    public class func objects(where predicateFormat: String, _ args: CVarArg...) -> RLMResults<RLMObject> {
        return objects(with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }

    public class func objects(in realm: RLMRealm,
                              where predicateFormat: String,
                              _ args: CVarArg...) -> RLMResults<RLMObject> {
        return objects(in: realm, with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }
}

public final class RLMIterator: IteratorProtocol {
    private let iteratorBase: NSFastEnumerationIterator

    internal init(collection: RLMCollection) {
        iteratorBase = NSFastEnumerationIterator(collection)
    }

    public func next() -> RLMObject? {
        return iteratorBase.next() as! RLMObject?
    }
}

// Sequence conformance for RLMArray and RLMResults is provided by RLMCollection's
// `makeIterator()` implementation.
extension RLMArray: Sequence {}
extension RLMResults: Sequence {}

extension RLMCollection {
    // Support Sequence-style enumeration
    public func makeIterator() -> RLMIterator {
        return RLMIterator(collection: self)
    }
}
