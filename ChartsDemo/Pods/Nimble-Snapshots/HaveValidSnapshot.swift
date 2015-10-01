import Foundation
import FBSnapshotTestCase
import UIKit
import Nimble
import QuartzCore
import Quick

@objc public protocol Snapshotable {
    var snapshotObject: UIView? { get }
}

extension UIViewController : Snapshotable {
    public var snapshotObject: UIView? {
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
        return view
    }
}

extension UIView : Snapshotable {
    public var snapshotObject: UIView? {
        return self
    }
}

@objc class FBSnapshotTest : NSObject {

    var currentExampleMetadata: ExampleMetadata?

    var referenceImagesDirectory: String?
    class var sharedInstance : FBSnapshotTest {
        struct Instance {
            static let instance: FBSnapshotTest = FBSnapshotTest()
        }
        return Instance.instance
    }

    class func setReferenceImagesDirectory(directory: String?) {
        sharedInstance.referenceImagesDirectory = directory
    }

    class func compareSnapshot(instance: Snapshotable, snapshot: String, record: Bool, referenceDirectory: String) -> Bool {
        let snapshotController: FBSnapshotTestController = FBSnapshotTestController(testName: _testFileName())
        snapshotController.recordMode = record
        snapshotController.referenceImagesDirectory = referenceDirectory

        assert(snapshotController.referenceImagesDirectory != nil, "Missing value for referenceImagesDirectory - Call FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")
        do {
            try snapshotController.compareSnapshotOfView(instance.snapshotObject, selector: Selector(snapshot), identifier: nil)
        }
        catch {
            return false;
        }
        return true;
    }
}

func _getDefaultReferenceDirectory(sourceFileName: String) -> String {
    if let globalReference = FBSnapshotTest.sharedInstance.referenceImagesDirectory {
        return globalReference
    }

    // Search the test file's path to find the first folder with the substring "tests"
    // then append "/ReferenceImages" and use that

    var result: NSString?

    let pathComponents: NSArray = (sourceFileName as NSString).pathComponents
    for folder in pathComponents {

        if (folder.lowercaseString as NSString).hasSuffix("tests") {
            let currentIndex = pathComponents.indexOfObject(folder) + 1
            let folderPathComponents: NSArray = pathComponents.subarrayWithRange(NSMakeRange(0, currentIndex))
            let folderPath = folderPathComponents.componentsJoinedByString("/")
            result = folderPath + "/ReferenceImages"
        }
    }

    assert(result != nil, "Could not infer reference image folder – You should provide a reference dir using FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")

    return result! as String
}

func _testFileName() -> String {
    let name = FBSnapshotTest.sharedInstance.currentExampleMetadata!.example.callsite.file as NSString
    let type = ".\(name.pathExtension)"
    let sanitizedName = name.lastPathComponent.stringByReplacingOccurrencesOfString(type, withString: "")

    return sanitizedName
}

func _sanitizedTestName() -> String {
    let quickExample = FBSnapshotTest.sharedInstance.currentExampleMetadata
    var filename = quickExample!.example.name
    filename = filename.stringByReplacingOccurrencesOfString("root example group, ", withString: "")
    let characterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    let components: NSArray = filename.componentsSeparatedByCharactersInSet(characterSet.invertedSet)

    return components.componentsJoinedByString("_")
}

func _clearFailureMessage(failureMessage: FailureMessage) {
    failureMessage.actualValue = ""
    failureMessage.expected = ""
    failureMessage.postfixMessage = ""
    failureMessage.to = ""
}

func _performSnapshotTest(name: String?, actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage) -> Bool {
    let instance = try! actualExpression.evaluate()!
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    let snapshotName = name ?? _sanitizedTestName()

    let result = FBSnapshotTest.compareSnapshot(instance, snapshot: snapshotName, record: false, referenceDirectory: referenceImageDirectory)

    if !result {
        _clearFailureMessage(failureMessage)
        failureMessage.actualValue = "expected a matching snapshot in \(name)"
    }

    return result

}

func _recordSnapshot(name: String?, actualExpression: Expression<Snapshotable>, failureMessage: FailureMessage) -> Bool {
    let instance = try! actualExpression.evaluate()!
    let testFileLocation = actualExpression.location.file
    let referenceImageDirectory = _getDefaultReferenceDirectory(testFileLocation)
    let snapshotName = name ?? _sanitizedTestName()

    _clearFailureMessage(failureMessage)

    if FBSnapshotTest.compareSnapshot(instance, snapshot: snapshotName, record: true, referenceDirectory: referenceImageDirectory) {
        failureMessage.actualValue = "snapshot \(name) successfully recorded, replace recordSnapshot with a check"
    } else {
        failureMessage.actualValue = "expected to record a snapshot in \(name)"
    }

    return false
}

internal var switchChecksWithRecords = false

public func haveValidSnapshot() -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        if (switchChecksWithRecords) {
            return _recordSnapshot(nil, actualExpression: actualExpression, failureMessage: failureMessage)
        }

        return _performSnapshotTest(nil, actualExpression: actualExpression, failureMessage: failureMessage)
    }
}

public func haveValidSnapshot(named name: String) -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        if (switchChecksWithRecords) {
            return _recordSnapshot(name, actualExpression: actualExpression, failureMessage: failureMessage)
        }

        return _performSnapshotTest(name, actualExpression: actualExpression, failureMessage: failureMessage)
    }
}

public func recordSnapshot() -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        return _recordSnapshot(nil, actualExpression: actualExpression, failureMessage: failureMessage)
    }
}

public func recordSnapshot(named name: String) -> MatcherFunc<Snapshotable> {
    return MatcherFunc { actualExpression, failureMessage in
        return _recordSnapshot(name, actualExpression: actualExpression, failureMessage: failureMessage)
    }
}
