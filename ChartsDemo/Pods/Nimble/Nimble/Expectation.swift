import Foundation

internal func expressionMatches<T, U where U: Matcher, U.ValueType == T>(expression: Expression<T>, matcher: U, to: String, description: String?) -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let pass = try matcher.matches(expression, failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try expression.evaluate()))>"
        }
        return (pass, msg)
    } catch let error {
        msg.actualValue = "an unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

internal func expressionDoesNotMatch<T, U where U: Matcher, U.ValueType == T>(expression: Expression<T>, matcher: U, toNot: String, description: String?) -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = toNot
    do {
        let pass = try matcher.doesNotMatch(expression, failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try expression.evaluate()))>"
        }
        return (pass, msg)
    } catch let error {
        msg.actualValue = "an unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

public struct Expectation<T> {
    let expression: Expression<T>

    public func verify(pass: Bool, _ message: FailureMessage) {
        NimbleAssertionHandler.assert(pass, message: message, location: expression.location)
    }

    /// Tests the actual value using a matcher to match.
    public func to<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        let (pass, msg) = expressionMatches(expression, matcher: matcher, to: "to", description: description)
        verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    public func toNot<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        let (pass, msg) = expressionDoesNotMatch(expression, matcher: matcher, toNot: "to not", description: description)
        verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    public func notTo<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        toNot(matcher, description: description)
    }

    // see:
    // - AsyncMatcherWrapper for extension
    // - NMBExpectation for Objective-C interface
}
