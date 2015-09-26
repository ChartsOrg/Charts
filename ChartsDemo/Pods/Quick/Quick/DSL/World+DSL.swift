/**
    Adds methods to World to support top-level DSL functions (Swift) and
    macros (Objective-C). These functions map directly to the DSL that test
    writers use in their specs.
*/
extension World {
    internal func beforeSuite(closure: BeforeSuiteClosure) {
        suiteHooks.appendBefore(closure)
    }

    internal func afterSuite(closure: AfterSuiteClosure) {
        suiteHooks.appendAfter(closure)
    }

    internal func sharedExamples(name: String, closure: SharedExampleClosure) {
        registerSharedExample(name, closure: closure)
    }

    internal func describe(description: String, flags: FilterFlags, closure: () -> ()) {
        let group = ExampleGroup(description: description, flags: flags)
        currentExampleGroup!.appendExampleGroup(group)
        currentExampleGroup = group
        closure()
        currentExampleGroup = group.parent
    }

    internal func context(description: String, flags: FilterFlags, closure: () -> ()) {
        self.describe(description, flags: flags, closure: closure)
    }

    internal func fdescribe(description: String, flags: FilterFlags, closure: () -> ()) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.describe(description, flags: focusedFlags, closure: closure)
    }

    internal func xdescribe(description: String, flags: FilterFlags, closure: () -> ()) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.describe(description, flags: pendingFlags, closure: closure)
    }

    internal func beforeEach(closure: BeforeExampleClosure) {
        currentExampleGroup!.hooks.appendBefore(closure)
    }

    @objc(beforeEachWithMetadata:)
    internal func beforeEach(closure closure: BeforeExampleWithMetadataClosure) {
        currentExampleGroup!.hooks.appendBefore(closure)
    }

    internal func afterEach(closure: AfterExampleClosure) {
        currentExampleGroup!.hooks.appendAfter(closure)
    }

    @objc(afterEachWithMetadata:)
    internal func afterEach(closure closure: AfterExampleWithMetadataClosure) {
        currentExampleGroup!.hooks.appendAfter(closure)
    }

    @objc(itWithDescription:flags:file:line:closure:)
    internal func it(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        let callsite = Callsite(file: file, line: line)
        let example = Example(description: description, callsite: callsite, flags: flags, closure: closure)
        currentExampleGroup!.appendExample(example)
    }

    @objc(fitWithDescription:flags:file:line:closure:)
    internal func fit(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.it(description, flags: focusedFlags, file: file, line: line, closure: closure)
    }

    @objc(xitWithDescription:flags:file:line:closure:)
    internal func xit(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.it(description, flags: pendingFlags, file: file, line: line, closure: closure)
    }

    @objc(itBehavesLikeSharedExampleNamed:sharedExampleContext:flags:file:line:)
    internal func itBehavesLike(name: String, sharedExampleContext: SharedExampleContext, flags: FilterFlags, file: String, line: UInt) {
        let callsite = Callsite(file: file, line: line)
        let closure = World.sharedWorld().sharedExample(name)

        let group = ExampleGroup(description: name, flags: flags)
        currentExampleGroup!.appendExampleGroup(group)
        currentExampleGroup = group
        closure(sharedExampleContext)
        currentExampleGroup!.walkDownExamples { (example: Example) in
            example.isSharedExample = true
            example.callsite = callsite
        }

        currentExampleGroup = group.parent
    }

    internal func pending(description: String, closure: () -> ()) {
        print("Pending: \(description)")
    }
}
