import Quick

class FBSnapshotTestConfiguration: QuickConfiguration {

    override class func configure(configuration: Configuration) {
        configuration.beforeEach { (exampleMetadata: ExampleMetadata) -> () in
            FBSnapshotTest.sharedInstance.currentExampleMetadata = exampleMetadata
        }
    }
}
