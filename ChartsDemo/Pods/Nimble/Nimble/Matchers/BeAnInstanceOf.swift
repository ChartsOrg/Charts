import Foundation

// A Nimble matcher that catches attempts to use beAnInstanceOf with non Objective-C types
public func beAnInstanceOf(expectedClass: Any) -> NonNilMatcherFunc<Any> {
    return NonNilMatcherFunc {actualExpression, failureMessage in
        failureMessage.stringValue = "beAnInstanceOf only works on Objective-C types since"
            + " the Swift compiler will automatically type check Swift-only types."
            + " This expectation is redundant."
        return false
    }
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAKindOf if you want to match against subclasses
public func beAnInstanceOf(expectedClass: AnyClass) -> NonNilMatcherFunc<NSObject> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(NSStringFromClass(validInstance.dynamicType)) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be an instance of \(NSStringFromClass(expectedClass))"
        return instance != nil && instance!.isMemberOfClass(expectedClass)
    }
}

extension NMBObjCMatcher {
    public class func beAnInstanceOfMatcher(expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAnInstanceOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
