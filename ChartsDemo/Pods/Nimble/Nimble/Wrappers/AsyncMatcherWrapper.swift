import Foundation

internal struct AsyncMatcherWrapper<T, U where U: Matcher, U.ValueType == T>: Matcher {
    let fullMatcher: U
    let timeoutInterval: NSTimeInterval
    let pollInterval: NSTimeInterval

    init(fullMatcher: U, timeoutInterval: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.01) {
      self.fullMatcher = fullMatcher
      self.timeoutInterval = timeoutInterval
      self.pollInterval = pollInterval
    }

    func matches(actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        let uncachedExpression = actualExpression.withoutCaching()
        let result = pollBlock(pollInterval: pollInterval, timeoutInterval: timeoutInterval) {
            try self.fullMatcher.matches(uncachedExpression, failureMessage: failureMessage)
        }
        switch (result) {
        case .Success: return true
        case .Failure: return false
        case let .ErrorThrown(error):
            failureMessage.actualValue = "an unexpected error thrown: <\(error)>"
            return false
        case .Timeout:
            failureMessage.postfixMessage += " (Stall on main thread)."
            return false
        }
    }

    func doesNotMatch(actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool  {
        let uncachedExpression = actualExpression.withoutCaching()
        let result = pollBlock(pollInterval: pollInterval, timeoutInterval: timeoutInterval) {
            try self.fullMatcher.doesNotMatch(uncachedExpression, failureMessage: failureMessage)
        }
        switch (result) {
        case .Success: return true
        case .Failure: return false
        case let .ErrorThrown(error):
            failureMessage.actualValue = "an unexpected error thrown: <\(error)>"
            return false
        case .Timeout:
            failureMessage.postfixMessage += " (Stall on main thread)."
            return false
        }
    }
}

private let toEventuallyRequiresClosureError = FailureMessage(stringValue: "expect(...).toEventually(...) requires an explicit closure (eg - expect { ... }.toEventually(...) )\nSwift 1.2 @autoclosure behavior has changed in an incompatible way for Nimble to function")


extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    public func toEventually<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.01, description: String? = nil) {
        if expression.isClosure {
            let (pass, msg) = expressionMatches(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                to: "to eventually",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    public func toEventuallyNot<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.01, description: String? = nil) {
        if expression.isClosure {
            let (pass, msg) = expressionDoesNotMatch(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                toNot: "to eventually not",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    public func toNotEventually<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.01, description: String? = nil) {
        return toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}
