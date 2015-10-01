import Foundation


/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: SequenceType>() -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualSeq = try actualExpression.evaluate()
        if actualSeq == nil {
            return true
        }
        var generator = actualSeq!.generate()
        return generator.next() == nil
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualString = try actualExpression.evaluate()
        return actualString == nil || (actualString! as NSString).length  == 0
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For NSString instances, it is an empty string.
public func beEmpty() -> NonNilMatcherFunc<NSString> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualString = try actualExpression.evaluate()
        return actualString == nil || actualString!.length == 0
    }
}

// Without specific overrides, beEmpty() is ambiguous for NSDictionary, NSArray,
// etc, since they conform to SequenceType as well as NMBCollection.

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> NonNilMatcherFunc<NSDictionary> {
	return NonNilMatcherFunc { actualExpression, failureMessage in
		failureMessage.postfixMessage = "be empty"
		let actualDictionary = try actualExpression.evaluate()
		return actualDictionary == nil || actualDictionary!.count == 0
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> NonNilMatcherFunc<NSArray> {
	return NonNilMatcherFunc { actualExpression, failureMessage in
		failureMessage.postfixMessage = "be empty"
		let actualArray = try actualExpression.evaluate()
		return actualArray == nil || actualArray!.count == 0
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> NonNilMatcherFunc<NMBCollection> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actual = try actualExpression.evaluate()
        return actual == nil || actual!.count == 0
    }
}

extension NMBObjCMatcher {
    public class func beEmptyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            failureMessage.postfixMessage = "be empty"
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection }), location: location)
                return try! beEmpty().matches(expr, failureMessage: failureMessage)
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                return try! beEmpty().matches(expr, failureMessage: failureMessage)
            } else if let actualValue = actualValue {
                failureMessage.postfixMessage = "be empty (only works for NSArrays, NSSets, NSDictionaries, NSHashTables, and NSStrings)"
                failureMessage.actualValue = "\(NSStringFromClass(actualValue.dynamicType)) type"
            }
            return false
        }
    }
}
