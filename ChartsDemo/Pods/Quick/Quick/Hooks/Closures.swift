// MARK: Example Hooks

/**
    A closure executed before an example is run.
*/
public typealias BeforeExampleClosure = () -> ()

/**
    A closure executed before an example is run. The closure is given example metadata,
    which contains information about the example that is about to be run.
*/
public typealias BeforeExampleWithMetadataClosure = (exampleMetadata: ExampleMetadata) -> ()

/**
    A closure executed after an example is run.
*/
public typealias AfterExampleClosure = BeforeExampleClosure

/**
    A closure executed after an example is run. The closure is given example metadata,
    which contains information about the example that has just finished running.
*/
public typealias AfterExampleWithMetadataClosure = BeforeExampleWithMetadataClosure

// MARK: Suite Hooks

/**
    A closure executed before any examples are run.
*/
public typealias BeforeSuiteClosure = () -> ()

/**
    A closure executed after all examples have finished running.
*/
public typealias AfterSuiteClosure = BeforeSuiteClosure
