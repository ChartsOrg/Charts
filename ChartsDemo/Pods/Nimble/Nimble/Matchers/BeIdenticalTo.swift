import Foundation


/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
public func beIdenticalTo<T: AnyObject>(expected: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let actual = try actualExpression.evaluate()
        failureMessage.actualValue = "\(identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(identityAsString(expected))"
        return actual === expected && actual !== nil
    }
}

public func ===<T: AnyObject>(lhs: Expectation<T>, rhs: T?) {
    lhs.to(beIdenticalTo(rhs))
}
public func !==<T: AnyObject>(lhs: Expectation<T>, rhs: T?) {
    lhs.toNot(beIdenticalTo(rhs))
}

extension NMBObjCMatcher {
    public class func beIdenticalToMatcher(expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beIdenticalTo(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
