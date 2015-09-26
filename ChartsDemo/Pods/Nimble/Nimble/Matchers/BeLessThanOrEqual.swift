import Foundation

/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: Comparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        return try actualExpression.evaluate() <= expectedValue
    }
}

/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: NMBComparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        return actualValue != nil && actualValue!.NMB_compare(expectedValue) != NSComparisonResult.OrderedDescending
    }
}

public func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

public func <=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

extension NMBObjCMatcher {
    public class func beLessThanOrEqualToMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil:false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beLessThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
