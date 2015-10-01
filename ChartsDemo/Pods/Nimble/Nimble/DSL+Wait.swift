import Foundation

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
internal class NMBWait: NSObject {
    internal class func until(timeout timeout: NSTimeInterval, file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
        var completed = false
        var token: dispatch_once_t = 0
        let result = pollBlock(pollInterval: 0.01, timeoutInterval: timeout) {
            dispatch_once(&token) {
                dispatch_async(dispatch_get_main_queue()) {
                    action() { completed = true }
                }
            }
            return completed
        }
        switch (result) {
        case .Failure:
            let pluralize = (timeout == 1 ? "" : "s")
            fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
        case .Timeout:
            fail("Stall on main thread - too much enqueued on main run loop before waitUntil executes.", file: file, line: line)
        case let .ErrorThrown(error):
            // Technically, we can never reach this via a public API call
            fail("Unexpected error thrown: \(error)", file: file, line: line)
        case .Success:
            break
        }
    }

    @objc(untilFile:line:action:)
    internal class func until(file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
        until(timeout: 1, file: file, line: line, action: action)
    }
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(timeout timeout: NSTimeInterval, file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
    NMBWait.until(timeout: timeout, file: file, line: line, action: action)
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
    NMBWait.until(timeout: 1, file: file, line: line, action: action)
}