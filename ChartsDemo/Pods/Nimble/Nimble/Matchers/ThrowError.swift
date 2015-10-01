import Foundation

/// A Nimble matcher that succeeds when the actual expression throws an
/// error of the specified type or from the specified case.
///
/// Errors are tried to be compared by their implementation of Equatable,
/// otherwise they fallback to comparision by _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError<T: ErrorType>(
    error: T? = nil,
    errorType: T.Type? = nil,
    closure: ((T) -> Void)? = nil) -> MatcherFunc<Any> {
        return MatcherFunc { actualExpression, failureMessage in

            var actualError: ErrorType?
            do {
                try actualExpression.evaluate()
            } catch let catchedError {
                actualError = catchedError
            }

            setFailureMessageForError(failureMessage, actualError: actualError, error: error, errorType: errorType, closure: closure)
            return errorMatchesNonNilFieldsOrClosure(actualError, error: error, errorType: errorType, closure: closure)
        }
}

internal func setFailureMessageForError<T: ErrorType>(
    failureMessage: FailureMessage,
    actualError: ErrorType?,
    error: T?,
    errorType: T.Type? = nil,
    closure: ((T) -> Void)?) {
        failureMessage.postfixMessage = "throw error"

        if let error = error {
            if let error = error as? CustomDebugStringConvertible {
                failureMessage.postfixMessage += " <\(error.debugDescription)>"
            } else {
                failureMessage.postfixMessage += " <\(error)>"
            }
        } else if errorType != nil || closure != nil {
            failureMessage.postfixMessage += " from type <\(T.self)>"
        }
        if let _ = closure {
            failureMessage.postfixMessage += " that satisfies block"
        }
        if error == nil && errorType == nil && closure == nil {
            failureMessage.postfixMessage = "throw any error"
        }

        if let actualError = actualError {
            failureMessage.actualValue = "<\(actualError)>"
        } else {
            failureMessage.actualValue = "no error"
        }
}

internal func errorMatchesExpectedError<T: ErrorType>(
    actualError: ErrorType,
    expectedError: T) -> Bool {
        return actualError._domain == expectedError._domain
            && actualError._code   == expectedError._code
}

internal func errorMatchesExpectedError<T: ErrorType where T: Equatable>(
    actualError: ErrorType,
    expectedError: T) -> Bool {
        if let actualError = actualError as? T {
            return actualError == expectedError
        }
        return false
}

internal func errorMatchesNonNilFieldsOrClosure<T: ErrorType>(
    actualError: ErrorType?,
    error: T?,
    errorType: T.Type?,
    closure: ((T) -> Void)?) -> Bool {
        var matches = false

        if let actualError = actualError {
            matches = true

            if let error = error {
                if !errorMatchesExpectedError(actualError, expectedError: error) {
                    matches = false
                }
            }
            if let actualError = actualError as? T {
                if let closure = closure {
                    let assertions = gatherFailingExpectations {
                        closure(actualError as T)
                    }
                    let messages = assertions.map { $0.message }
                    if messages.count > 0 {
                        matches = false
                    }
                }
            } else if errorType != nil && closure != nil {
                // The closure expects another ErrorType as argument, so this
                // is _supposed_ to fail, so that it becomes more obvious.
                let assertions = gatherExpectations {
                    expect(actualError is T).to(equal(true))
                }
                precondition(assertions.map { $0.message }.count > 0)
                matches = false
            }
        }
        
        return matches
}


/// A Nimble matcher that succeeds when the actual expression throws any
/// error or when the passed closures' arbitrary custom matching succeeds.
///
/// This duplication to it's generic adequate is required to allow to receive
/// values of the existential type ErrorType in the closure.
///
/// The closure only gets called when an error was thrown.
public func throwError(
    closure closure: ((ErrorType) -> Void)? = nil) -> MatcherFunc<Any> {
        return MatcherFunc { actualExpression, failureMessage in
            
            var actualError: ErrorType?
            do {
                try actualExpression.evaluate()
            } catch let catchedError {
                actualError = catchedError
            }
            
            setFailureMessageForError(failureMessage, actualError: actualError, closure: closure)
            return errorMatchesNonNilFieldsOrClosure(actualError, closure: closure)
        }
}

internal func setFailureMessageForError(
    failureMessage: FailureMessage,
    actualError: ErrorType?,
    closure: ((ErrorType) -> Void)?) {
        failureMessage.postfixMessage = "throw error"

        if let _ = closure {
            failureMessage.postfixMessage += " that satisfies block"
        } else {
            failureMessage.postfixMessage = "throw any error"
        }

        if let actualError = actualError {
            failureMessage.actualValue = "<\(actualError)>"
        } else {
            failureMessage.actualValue = "no error"
        }
}

internal func errorMatchesNonNilFieldsOrClosure(
    actualError: ErrorType?,
    closure: ((ErrorType) -> Void)?) -> Bool {
        var matches = false

        if let actualError = actualError {
            matches = true

            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(actualError)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }
        
        return matches
}
