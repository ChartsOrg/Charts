import Foundation

internal let DefaultDelta = 0.0001

internal func isCloseTo(actualValue: NMBDoubleConvertible?, expectedValue: NMBDoubleConvertible, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.postfixMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    if actualValue != nil {
        failureMessage.actualValue = "<\(stringify(actualValue!))>"
    } else {
        failureMessage.actualValue = "<nil>"
    }
    return actualValue != nil && abs(actualValue!.doubleValue - expectedValue.doubleValue) < delta
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo(expectedValue: Double, within delta: Double = DefaultDelta) -> NonNilMatcherFunc<Double> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta, failureMessage: failureMessage)
    }
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo(expectedValue: NMBDoubleConvertible, within delta: Double = DefaultDelta) -> NonNilMatcherFunc<NMBDoubleConvertible> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta, failureMessage: failureMessage)
    }
}

public class NMBObjCBeCloseToMatcher : NSObject, NMBMatcher {
    var _expected: NSNumber
    var _delta: CDouble
    init(expected: NSNumber, within: CDouble) {
        _expected = expected
        _delta = within
    }

    public func matches(actualExpression: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let actualBlock: () -> NMBDoubleConvertible? = ({
            return actualExpression() as? NMBDoubleConvertible
        })
        let expr = Expression(expression: actualBlock, location: location)
        let matcher = beCloseTo(self._expected, within: self._delta)
        return try! matcher.matches(expr, failureMessage: failureMessage)
    }

    public func doesNotMatch(actualExpression: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let actualBlock: () -> NMBDoubleConvertible? = ({
            return actualExpression() as? NMBDoubleConvertible
        })
        let expr = Expression(expression: actualBlock, location: location)
        let matcher = beCloseTo(self._expected, within: self._delta)
        return try! matcher.doesNotMatch(expr, failureMessage: failureMessage)
    }

    public var within: (CDouble) -> NMBObjCBeCloseToMatcher {
        return ({ delta in
            return NMBObjCBeCloseToMatcher(expected: self._expected, within: delta)
        })
    }
}

extension NMBObjCMatcher {
    public class func beCloseToMatcher(expected: NSNumber, within: CDouble) -> NMBObjCBeCloseToMatcher {
        return NMBObjCBeCloseToMatcher(expected: expected, within: within)
    }
}

public func beCloseTo(expectedValues: [Double], within delta: Double = DefaultDelta) -> NonNilMatcherFunc <[Double]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be close to <\(stringify(expectedValues))> (each within \(stringify(delta)))"
        if let actual = try actualExpression.evaluate() {
            if actual.count != expectedValues.count {
                return false
            } else {
                for (index, actualItem) in actual.enumerate() {
                    if fabs(actualItem - expectedValues[index]) > delta {
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
}

// MARK: - Operators

infix operator ≈ {
    associativity none
    precedence 130
}

public func ≈(lhs: Expectation<[Double]>, rhs: [Double]) {
    lhs.to(beCloseTo(rhs))
}

public func ≈(lhs: Expectation<Double>, rhs: Double) {
    lhs.to(beCloseTo(rhs))
}

public func ≈(lhs: Expectation<Double>, rhs: (expected: Double, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func ==(lhs: Expectation<Double>, rhs: (expected: Double, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

// make this higher precedence than exponents so the Doubles either end aren't pulled in
// unexpectantly
infix operator ± { precedence 170 }
public func ±(lhs: Double, rhs: Double) -> (expected: Double, delta: Double) {
    return (expected: lhs, delta: rhs)
}
