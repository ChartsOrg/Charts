//
//  Clamped.swift
//  Charts
//
//  Created by Jacob Christie on 2021-01-26.
//

import Foundation

@propertyWrapper
public struct Clamped<Value: Comparable> {
    private var storage: Value

    let range: ClosedRange<Value>

    public var wrappedValue: Value {
        get { storage }
        set { storage = max(range.lowerBound, min(storage, range.upperBound)) }
    }

    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(value))
        self.storage = value
        self.range = range
    }
}

extension Clamped where Value: Strideable, Value.Stride: SignedInteger {
    public init(wrappedValue value: Value, _ range: Swift.Range<Value>) {
        self.init(wrappedValue: value, ClosedRange(range))
    }
}
