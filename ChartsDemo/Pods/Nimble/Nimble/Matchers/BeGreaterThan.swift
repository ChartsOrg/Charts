import Foundation


/// A Nimble matcher that succeeds when the actual value is greater than the expected value.
public func beGreaterThan<T: Comparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(stringify(expectedValue))>"
        return try actualExpression.evaluate() > expectedValue
    }
}

/// A Nimble matcher that succeeds when the actual value is greater than the expected value.
public func beGreaterThan(expectedValue: NMBComparable?) -> NonNilMatcherFunc<NMBComparable> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == NSComparisonResult.OrderedDescending
        return matches
    }
}

public func ><T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThan(rhs))
}

public func >(lhs: Expectation<NMBComparable>, rhs: NMBComparable?) {
    lhs.to(beGreaterThan(rhs))
}

extension NMBObjCMatcher {
    public class func beGreaterThanMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beGreaterThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
