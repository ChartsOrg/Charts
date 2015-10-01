import Foundation

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan<T: Comparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(stringify(expectedValue))>"
        return try actualExpression.evaluate() < expectedValue
    }
}

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan(expectedValue: NMBComparable?) -> NonNilMatcherFunc<NMBComparable> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == NSComparisonResult.OrderedAscending
        return matches
    }
}

public func <<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThan(rhs))
}

public func <(lhs: Expectation<NMBComparable>, rhs: NMBComparable?) {
    lhs.to(beLessThan(rhs))
}

extension NMBObjCMatcher {
    public class func beLessThanMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as! NMBComparable? }
            return try! beLessThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
