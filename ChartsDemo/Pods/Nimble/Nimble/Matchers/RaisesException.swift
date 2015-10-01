import Foundation

/// A Nimble matcher that succeeds when the actual expression raises an
/// exception with the specified name, reason, and/or userInfo.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the raised exception. The closure only gets called when an exception
/// is raised.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func raiseException(
    named named: String? = nil,
    reason: String? = nil,
    userInfo: NSDictionary? = nil,
    closure: ((NSException) -> Void)? = nil) -> MatcherFunc<Any> {
        return MatcherFunc { actualExpression, failureMessage in

            var exception: NSException?
            let capture = NMBExceptionCapture(handler: ({ e in
                exception = e
            }), finally: nil)

            capture.tryBlock {
                try! actualExpression.evaluate()
                return
            }

            setFailureMessageForException(failureMessage, exception: exception, named: named, reason: reason, userInfo: userInfo, closure: closure)
            return exceptionMatchesNonNilFieldsOrClosure(exception, named: named, reason: reason, userInfo: userInfo, closure: closure)
        }
}

internal func setFailureMessageForException(
    failureMessage: FailureMessage,
    exception: NSException?,
    named: String?,
    reason: String?,
    userInfo: NSDictionary?,
    closure: ((NSException) -> Void)?) {
        failureMessage.postfixMessage = "raise exception"

        if let named = named {
            failureMessage.postfixMessage += " with name <\(named)>"
        }
        if let reason = reason {
            failureMessage.postfixMessage += " with reason <\(reason)>"
        }
        if let userInfo = userInfo {
            failureMessage.postfixMessage += " with userInfo <\(userInfo)>"
        }
        if let _ = closure {
            failureMessage.postfixMessage += " that satisfies block"
        }
        if named == nil && reason == nil && userInfo == nil && closure == nil {
            failureMessage.postfixMessage = "raise any exception"
        }

        if let exception = exception {
            failureMessage.actualValue = "\(NSStringFromClass(exception.dynamicType)) { name=\(exception.name), reason='\(stringify(exception.reason))', userInfo=\(stringify(exception.userInfo)) }"
        } else {
            failureMessage.actualValue = "no exception"
        }
}

internal func exceptionMatchesNonNilFieldsOrClosure(
    exception: NSException?,
    named: String?,
    reason: String?,
    userInfo: NSDictionary?,
    closure: ((NSException) -> Void)?) -> Bool {
        var matches = false

        if let exception = exception {
            matches = true

            if named != nil && exception.name != named {
                matches = false
            }
            if reason != nil && exception.reason != reason {
                matches = false
            }
            if userInfo != nil && exception.userInfo != userInfo {
                matches = false
            }
            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(exception)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }
        
        return matches
}

public class NMBObjCRaiseExceptionMatcher : NSObject, NMBMatcher {
    internal var _name: String?
    internal var _reason: String?
    internal var _userInfo: NSDictionary?
    internal var _block: ((NSException) -> Void)?

    internal init(name: String?, reason: String?, userInfo: NSDictionary?, block: ((NSException) -> Void)?) {
        _name = name
        _reason = reason
        _userInfo = userInfo
        _block = block
    }

    public func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let block: () -> Any? = ({ actualBlock(); return nil })
        let expr = Expression(expression: block, location: location)

        return try! raiseException(
            named: _name,
            reason: _reason,
            userInfo: _userInfo,
            closure: _block
        ).matches(expr, failureMessage: failureMessage)
    }

    public func doesNotMatch(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        return !matches(actualBlock, failureMessage: failureMessage, location: location)
    }

    public var named: (name: String) -> NMBObjCRaiseExceptionMatcher {
        return ({ name in
            return NMBObjCRaiseExceptionMatcher(
                name: name,
                reason: self._reason,
                userInfo: self._userInfo,
                block: self._block
            )
        })
    }

    public var reason: (reason: String?) -> NMBObjCRaiseExceptionMatcher {
        return ({ reason in
            return NMBObjCRaiseExceptionMatcher(
                name: self._name,
                reason: reason,
                userInfo: self._userInfo,
                block: self._block
            )
        })
    }

    public var userInfo: (userInfo: NSDictionary?) -> NMBObjCRaiseExceptionMatcher {
        return ({ userInfo in
            return NMBObjCRaiseExceptionMatcher(
                name: self._name,
                reason: self._reason,
                userInfo: userInfo,
                block: self._block
            )
        })
    }

    public var satisfyingBlock: (block: ((NSException) -> Void)?) -> NMBObjCRaiseExceptionMatcher {
        return ({ block in
            return NMBObjCRaiseExceptionMatcher(
                name: self._name,
                reason: self._reason,
                userInfo: self._userInfo,
                block: block
            )
        })
    }
}

extension NMBObjCMatcher {
    public class func raiseExceptionMatcher() -> NMBObjCRaiseExceptionMatcher {
        return NMBObjCRaiseExceptionMatcher(name: nil, reason: nil, userInfo: nil, block: nil)
    }
}
