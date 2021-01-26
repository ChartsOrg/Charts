//
//  Clamped.swift
//  Charts
//
//  Created by Jacob Christie on 2021-01-26.
//

import Foundation

@propertyWrapper
struct Clamped<Value: Comparable> {
    private var storage: Value

    let range: ClosedRange<Value>

    var wrappedValue: Value {
        get { storage }
        set { storage = newValue.clamped(to: range) }
    }

    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(value), "Initial value provided is outside of `range`")
        self.storage = value
        self.range = range
    }
}

extension Clamped where Value: Strideable, Value.Stride: SignedInteger {
    init(wrappedValue value: Value, _ range: Swift.Range<Value>) {
        self.init(wrappedValue: value, ClosedRange(range))
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
}
