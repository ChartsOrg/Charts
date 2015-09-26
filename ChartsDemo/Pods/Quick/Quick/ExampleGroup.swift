/**
    Example groups are logical groupings of examples, defined with
    the `describe` and `context` functions. Example groups can share
    setup and teardown code.
*/
final public class ExampleGroup: NSObject {
    weak internal var parent: ExampleGroup?
    internal let hooks = ExampleHooks()

    private let internalDescription: String
    private let flags: FilterFlags
    private let isInternalRootExampleGroup: Bool
    private var childGroups = [ExampleGroup]()
    private var childExamples = [Example]()

    internal init(description: String, flags: FilterFlags, isInternalRootExampleGroup: Bool = false) {
        self.internalDescription = description
        self.flags = flags
        self.isInternalRootExampleGroup = isInternalRootExampleGroup
    }
    
    public override var description: String {
        return internalDescription
    }

    /**
        Returns a list of examples that belong to this example group,
        or to any of its descendant example groups.
    */
    public var examples: [Example] {
        var examples = childExamples
        for group in childGroups {
            examples.appendContentsOf(group.examples)
        }
        return examples
    }

    internal var name: String? {
        if let parent = parent {
            switch(parent.name) {
            case .Some(let name): return "\(name), \(description)"
            case .None: return description
            }
        } else {
            return isInternalRootExampleGroup ? nil : description
        }
    }

    internal var filterFlags: FilterFlags {
        var aggregateFlags = flags
        walkUp() { (group: ExampleGroup) -> () in
            for (key, value) in group.flags {
                aggregateFlags[key] = value
            }
        }
        return aggregateFlags
    }

    internal var befores: [BeforeExampleWithMetadataClosure] {
        var closures = Array(hooks.befores.reverse())
        walkUp() { (group: ExampleGroup) -> () in
            closures.appendContentsOf(Array(group.hooks.befores.reverse()))
        }
        return Array(closures.reverse())
    }

    internal var afters: [AfterExampleWithMetadataClosure] {
        var closures = hooks.afters
        walkUp() { (group: ExampleGroup) -> () in
            closures.appendContentsOf(group.hooks.afters)
        }
        return closures
    }

    internal func walkDownExamples(callback: (example: Example) -> ()) {
        for example in childExamples {
            callback(example: example)
        }
        for group in childGroups {
            group.walkDownExamples(callback)
        }
    }

    internal func appendExampleGroup(group: ExampleGroup) {
        group.parent = self
        childGroups.append(group)
    }

    internal func appendExample(example: Example) {
        example.group = self
        childExamples.append(example)
    }

    private func walkUp(callback: (group: ExampleGroup) -> ()) {
        var group = self
        while let parent = group.parent {
            callback(group: parent)
            group = parent
        }
    }
}
