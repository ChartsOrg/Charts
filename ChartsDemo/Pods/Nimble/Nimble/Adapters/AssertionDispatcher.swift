
/// AssertionDispatcher allows multiple AssertionHandlers to receive
/// assertion messages.
///
/// @warning Does not fully dispatch if one of the handlers raises an exception.
///          This is possible with XCTest-based assertion handlers.
///
public class AssertionDispatcher: AssertionHandler {
    let handlers: [AssertionHandler]

    public init(handlers: [AssertionHandler]) {
        self.handlers = handlers
    }

    public func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
        for handler in handlers {
            handler.assert(assertion, message: message, location: location)
        }
    }
}
