private var numberOfExamplesRun = 0

/**
    Examples, defined with the `it` function, use assertions to
    demonstrate how code should behave. These are like "tests" in XCTest.
*/
final public class Example: NSObject {
    /**
        A boolean indicating whether the example is a shared example;
        i.e.: whether it is an example defined with `itBehavesLike`.
    */
    public var isSharedExample = false

    /**
        The site at which the example is defined.
        This must be set correctly in order for Xcode to highlight
        the correct line in red when reporting a failure.
    */
    public var callsite: Callsite

    weak internal var group: ExampleGroup?

    private let internalDescription: String
    private let closure: () -> ()
    private let flags: FilterFlags

    internal init(description: String, callsite: Callsite, flags: FilterFlags, closure: () -> ()) {
        self.internalDescription = description
        self.closure = closure
        self.callsite = callsite
        self.flags = flags
    }
    
    public override var description: String {
        return internalDescription
    }

    /**
        The example name. A name is a concatenation of the name of
        the example group the example belongs to, followed by the
        description of the example itself.

        The example name is used to generate a test method selector
        to be displayed in Xcode's test navigator.
    */
    public var name: String {
        switch group!.name {
        case .Some(let groupName): return "\(groupName), \(description)"
        case .None: return description
        }
    }

    /**
        Executes the example closure, as well as all before and after
        closures defined in the its surrounding example groups.
    */
    public func run() {
        let world = World.sharedWorld()

        if numberOfExamplesRun == 0 {
            world.suiteHooks.executeBefores()
        }

        let exampleMetadata = ExampleMetadata(example: self, exampleIndex: numberOfExamplesRun)
        world.currentExampleMetadata = exampleMetadata

        world.exampleHooks.executeBefores(exampleMetadata)
        for before in group!.befores {
            before(exampleMetadata: exampleMetadata)
        }

        closure()

        for after in group!.afters {
            after(exampleMetadata: exampleMetadata)
        }
        world.exampleHooks.executeAfters(exampleMetadata)

        ++numberOfExamplesRun

        if !world.isRunningAdditionalSuites && numberOfExamplesRun >= world.exampleCount {
            world.suiteHooks.executeAfters()
        }
    }

    /**
        Evaluates the filter flags set on this example and on the example groups
        this example belongs to. Flags set on the example are trumped by flags on
        the example group it belongs to. Flags on inner example groups are trumped
        by flags on outer example groups.
    */
    internal var filterFlags: FilterFlags {
        var aggregateFlags = flags
        for (key, value) in group!.filterFlags {
            aggregateFlags[key] = value
        }
        return aggregateFlags
    }
}

/**
    Returns a boolean indicating whether two Example objects are equal.
    If two examples are defined at the exact same callsite, they must be equal.
*/
public func ==(lhs: Example, rhs: Example) -> Bool {
    return lhs.callsite == rhs.callsite
}
