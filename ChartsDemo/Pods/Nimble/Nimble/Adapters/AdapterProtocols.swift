import Foundation

/// Protocol for the assertion handler that Nimble uses for all expectations.
public protocol AssertionHandler {
    func assert(assertion: Bool, message: FailureMessage, location: SourceLocation)
}

/// Global backing interface for assertions that Nimble creates.
/// Defaults to a private test handler that passes through to XCTest.
///
/// @see AssertionHandler
public var NimbleAssertionHandler: AssertionHandler = NimbleXCTestHandler()
