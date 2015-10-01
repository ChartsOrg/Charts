import Foundation

/// A data structure that stores information about an assertion when
/// AssertionRecorder is set as the Nimble assertion handler.
///
/// @see AssertionRecorder
/// @see AssertionHandler
public struct AssertionRecord: CustomStringConvertible {
    /// Whether the assertion succeeded or failed
    public let success: Bool
    /// The failure message the assertion would display on failure.
    public let message: FailureMessage
    /// The source location the expectation occurred on.
    public let location: SourceLocation

    public var description: String {
        return "AssertionRecord { success=\(success), message='\(message.stringValue)', location=\(location) }"
    }
}

/// An AssertionHandler that silently records assertions that Nimble makes.
/// This is useful for testing failure messages for matchers.
///
/// @see AssertionHandler
public class AssertionRecorder : AssertionHandler {
    /// All the assertions that were captured by this recorder
    public var assertions = [AssertionRecord]()

    public init() {}

    public func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
        assertions.append(
            AssertionRecord(
                success: assertion,
                message: message,
                location: location))
    }
}

/// Allows you to temporarily replace the current Nimble assertion handler with
/// the one provided for the scope of the closure.
///
/// Once the closure finishes, then the original Nimble assertion handler is restored.
///
/// @see AssertionHandler
public func withAssertionHandler(tempAssertionHandler: AssertionHandler, closure: () throws -> Void) {
    let oldRecorder = NimbleAssertionHandler
    let capturer = NMBExceptionCapture(handler: nil, finally: ({
        NimbleAssertionHandler = oldRecorder
    }))
    NimbleAssertionHandler = tempAssertionHandler
    capturer.tryBlock {
        try! closure()
    }
}

/// Captures expectations that occur in the given closure. Note that all
/// expectations will still go through to the default Nimble handler.
///
/// This can be useful if you want to gather information about expectations
/// that occur within a closure.
///
/// @param silently expectations are no longer send to the default Nimble 
///                 assertion handler when this is true. Defaults to false.
///
/// @see gatherFailingExpectations
public func gatherExpectations(silently silently: Bool = false, closure: () -> Void) -> [AssertionRecord] {
    let previousRecorder = NimbleAssertionHandler
    let recorder = AssertionRecorder()
    let handlers: [AssertionHandler]

    if silently {
        handlers = [recorder]
    } else {
        handlers = [recorder, previousRecorder]
    }

    let dispatcher = AssertionDispatcher(handlers: handlers)
    withAssertionHandler(dispatcher, closure: closure)
    return recorder.assertions
}

/// Captures failed expectations that occur in the given closure. Note that all
/// expectations will still go through to the default Nimble handler.
///
/// This can be useful if you want to gather information about failed
/// expectations that occur within a closure.
///
/// @param silently expectations are no longer send to the default Nimble
///                 assertion handler when this is true. Defaults to false.
///
/// @see gatherExpectations
/// @see raiseException source for an example use case.
public func gatherFailingExpectations(silently silently: Bool = false, closure: () -> Void) -> [AssertionRecord] {
    let assertions = gatherExpectations(silently: silently, closure: closure)
    return assertions.filter { assertion in
        !assertion.success
    }
}
