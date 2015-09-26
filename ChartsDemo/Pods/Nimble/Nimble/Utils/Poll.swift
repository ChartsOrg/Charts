import Foundation

internal enum PollResult : BooleanType {
    case Success, Failure, Timeout
    case ErrorThrown(ErrorType)

    var boolValue : Bool {
        switch (self) {
        case .Success:
            return true
        default:
            return false
        }
    }
}

internal class RunPromise {
    var token: dispatch_once_t = 0
    var didFinish = false
    var didFail = false

    init() {}

    func succeed() {
        dispatch_once(&self.token) {
            self.didFinish = false
        }
    }

    func fail(block: () -> Void) {
        dispatch_once(&self.token) {
            self.didFail = true
            block()
        }
    }
}

let killQueue = dispatch_queue_create("nimble.waitUntil.queue", DISPATCH_QUEUE_SERIAL)

internal func stopRunLoop(runLoop: NSRunLoop, delay: NSTimeInterval) -> RunPromise {
    let promise = RunPromise()
    let killTimeOffset = Int64(CDouble(delay) * CDouble(NSEC_PER_SEC))
    let killTime = dispatch_time(DISPATCH_TIME_NOW, killTimeOffset)
    dispatch_after(killTime, killQueue) {
        promise.fail {
            CFRunLoopStop(runLoop.getCFRunLoop())
        }
    }
    return promise
}

internal func pollBlock(pollInterval pollInterval: NSTimeInterval, timeoutInterval: NSTimeInterval, expression: () throws -> Bool) -> PollResult {
    let runLoop = NSRunLoop.mainRunLoop()

    let promise = stopRunLoop(runLoop, delay: min(timeoutInterval, 0.2))

    let startDate = NSDate()

    // trigger run loop to make sure enqueued tasks don't block our assertion polling
    // the stop run loop task above will abort us if necessary
    runLoop.runUntilDate(startDate)
    dispatch_sync(killQueue) {
        promise.succeed()
    }

    if promise.didFail {
        return .Timeout
    }

    var pass = false
    do {
        repeat {
            pass = try expression()
            if pass {
                break
            }

            let runDate = NSDate().dateByAddingTimeInterval(pollInterval)
            runLoop.runUntilDate(runDate)
        } while(NSDate().timeIntervalSinceDate(startDate) < timeoutInterval)
    } catch let error {
        return .ErrorThrown(error)
    }

    return pass ? .Success : .Failure
}
