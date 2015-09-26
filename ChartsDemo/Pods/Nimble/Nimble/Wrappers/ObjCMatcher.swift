import Foundation

public typealias MatcherBlock = (actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool
public typealias FullMatcherBlock = (actualExpression: Expression<NSObject>, failureMessage: FailureMessage, shouldNotMatch: Bool) -> Bool
public class NMBObjCMatcher : NSObject, NMBMatcher {
    let _match: MatcherBlock
    let _doesNotMatch: MatcherBlock
    let canMatchNil: Bool

    public init(canMatchNil: Bool, matcher: MatcherBlock, notMatcher: MatcherBlock) {
        self.canMatchNil = canMatchNil
        self._match = matcher
        self._doesNotMatch = notMatcher
    }

    public convenience init(matcher: MatcherBlock) {
        self.init(canMatchNil: true, matcher: matcher)
    }

    public convenience init(canMatchNil: Bool, matcher: MatcherBlock) {
        self.init(canMatchNil: canMatchNil, matcher: matcher, notMatcher: ({ actualExpression, failureMessage in
            return !matcher(actualExpression: actualExpression, failureMessage: failureMessage)
        }))
    }

    public convenience init(matcher: FullMatcherBlock) {
        self.init(canMatchNil: true, matcher: matcher)
    }

    public convenience init(canMatchNil: Bool, matcher: FullMatcherBlock) {
        self.init(canMatchNil: canMatchNil, matcher: ({ actualExpression, failureMessage in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, shouldNotMatch: false)
        }), notMatcher: ({ actualExpression, failureMessage in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, shouldNotMatch: true)
        }))
    }

    private func canMatch(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        do {
            if !canMatchNil {
                if try actualExpression.evaluate() == nil {
                    failureMessage.postfixActual = " (use beNil() to match nils)"
                    return false
                }
            }
        } catch let error {
            failureMessage.actualValue = "an unexpected error thrown: \(error)"
            return false
        }
        return true
    }

    public func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let expr = Expression(expression: actualBlock, location: location)
        let result = _match(
            actualExpression: expr,
            failureMessage: failureMessage)
        if self.canMatch(Expression(expression: actualBlock, location: location), failureMessage: failureMessage) {
            return result
        } else {
            return false
        }
    }

    public func doesNotMatch(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let expr = Expression(expression: actualBlock, location: location)
        let result = _doesNotMatch(
            actualExpression: expr,
            failureMessage: failureMessage)
        if self.canMatch(Expression(expression: actualBlock, location: location), failureMessage: failureMessage) {
            return result
        } else {
            return false
        }
    }
}

