import Foundation

/// A Nimble matcher that succeeds when the actual sequence contains the expected value.
public func contain<S: SequenceType, T: Equatable where S.Generator.Element == T>(items: T...) -> NonNilMatcherFunc<S> {
    return contain(items)
}

private func contain<S: SequenceType, T: Equatable where S.Generator.Element == T>(items: [T]) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(arrayAsString(items))>"
        if let actual = try actualExpression.evaluate() {
            return all(items) {
                return actual.contains($0)
            }
        }
        return false
    }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring.
public func contain(substrings: String...) -> NonNilMatcherFunc<String> {
    return contain(substrings)
}

private func contain(substrings: [String]) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(arrayAsString(substrings))>"
        if let actual = try actualExpression.evaluate() {
            return all(substrings) {
                let scanRange = Range(start: actual.startIndex, end: actual.endIndex)
                let range = actual.rangeOfString($0, options: [], range: scanRange, locale: nil)
                return range != nil && !range!.isEmpty
            }
        }
        return false
    }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring.
public func contain(substrings: NSString...) -> NonNilMatcherFunc<NSString> {
    return contain(substrings)
}

private func contain(substrings: [NSString]) -> NonNilMatcherFunc<NSString> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(arrayAsString(substrings))>"
        if let actual = try actualExpression.evaluate() {
            return all(substrings) { actual.rangeOfString($0.description).length != 0 }
        }
        return false
    }
}

/// A Nimble matcher that succeeds when the actual collection contains the expected object.
public func contain(items: AnyObject?...) -> NonNilMatcherFunc<NMBContainer> {
    return contain(items)
}

private func contain(items: [AnyObject?]) -> NonNilMatcherFunc<NMBContainer> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(arrayAsString(items))>"
        let actual = try actualExpression.evaluate()
        return all(items) { item in
            return actual != nil && actual!.containsObject(item)
        }
    }
}

extension NMBObjCMatcher {
    public class func containMatcher(expected: [NSObject]) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            if let value = actualValue as? NMBContainer {
                let expr = Expression(expression: ({ value as NMBContainer }), location: location)

                // A straightforward cast on the array causes this to crash, so we have to cast the individual items
                let expectedOptionals: [AnyObject?] = expected.map({ $0 as AnyObject? })
                return try! contain(expectedOptionals).matches(expr, failureMessage: failureMessage)
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                return try! contain(expected as! [String]).matches(expr, failureMessage: failureMessage)
            } else if actualValue != nil {
                failureMessage.postfixMessage = "contain <\(arrayAsString(expected))> (only works for NSArrays, NSSets, NSHashTables, and NSStrings)"
            } else {
                failureMessage.postfixMessage = "contain <\(arrayAsString(expected))>"
            }
            return false
        }
    }
}
