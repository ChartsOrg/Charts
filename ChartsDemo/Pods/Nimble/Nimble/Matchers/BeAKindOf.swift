import Foundation

// A Nimble matcher that catches attempts to use beAKindOf with non Objective-C types
public func beAKindOf(expectedClass: Any) -> NonNilMatcherFunc<Any> {
    return NonNilMatcherFunc {actualExpression, failureMessage in
        failureMessage.stringValue = "beAKindOf only works on Objective-C types since"
            + " the Swift compiler will automatically type check Swift-only types."
            + " This expectation is redundant."
        return false
    }
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAnInstanceOf if you want to match against the exact class
public func beAKindOf(expectedClass: AnyClass) -> NonNilMatcherFunc<NSObject> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(NSStringFromClass(validInstance.dynamicType)) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be a kind of \(NSStringFromClass(expectedClass))"
        return instance != nil && instance!.isKindOfClass(expectedClass)
    }
}

extension NMBObjCMatcher {
    public class func beAKindOfMatcher(expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAKindOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
