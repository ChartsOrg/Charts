/*
*  Copyright (c) 2015, Facebook, Inc.
*  All rights reserved.
*
*  This source code is licensed under the BSD-style license found in the
*  LICENSE file in the root directory of this source tree. An additional grant
*  of patent rights can be found in the PATENTS file in the same directory.
*
*/

public extension FBSnapshotTestCase {
  public func FBSnapshotVerifyView(view: UIView, identifier: String = "", suffixes: NSOrderedSet = FBSnapshotTestCaseDefaultSuffixes(), file: String = __FILE__, line: UInt = __LINE__) {
    FBSnapshotVerifyViewOrLayer(view, identifier: identifier, suffixes: suffixes)
  }

  public func FBSnapshotVerifyLayer(layer: CALayer, identifier: String = "", suffixes: NSOrderedSet = FBSnapshotTestCaseDefaultSuffixes(), file: String = __FILE__, line: UInt = __LINE__) {
    FBSnapshotVerifyViewOrLayer(layer, identifier: identifier, suffixes: suffixes)
  }

  private func FBSnapshotVerifyViewOrLayer(viewOrLayer: AnyObject, identifier: String = "", suffixes: NSOrderedSet = FBSnapshotTestCaseDefaultSuffixes(), file: String = __FILE__, line: UInt = __LINE__) {
    let envReferenceImageDirectory = self.getReferenceImageDirectoryWithDefault(FB_REFERENCE_IMAGE_DIR)
    var error: NSError?
    var comparisonSuccess = false

    if let envReferenceImageDirectory = envReferenceImageDirectory {
      for suffix in suffixes {
        let referenceImagesDirectory = "\(envReferenceImageDirectory)\(suffix)"
        if viewOrLayer.isKindOfClass(UIView) {
          do {
            try compareSnapshotOfView(viewOrLayer as! UIView, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, tolerance: 0)
            comparisonSuccess = true
          } catch let error1 as NSError {
            error = error1
            comparisonSuccess = false
          }
        } else if viewOrLayer.isKindOfClass(CALayer) {
          do {
            try compareSnapshotOfLayer(viewOrLayer as! CALayer, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, tolerance: 0)
            comparisonSuccess = true
          } catch let error1 as NSError {
            error = error1
            comparisonSuccess = false
          }
        } else {
          assertionFailure("Only UIView and CALayer classes can be snapshotted")
        }

        assert(recordMode == false, message: "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!", file: file, line: line)

        if comparisonSuccess || recordMode {
          break
        }

        assert(comparisonSuccess, message: "Snapshot comparison failed: \(error)", file: file, line: line)
      }
    } else {
      XCTFail("Missing value for referenceImagesDirectory - Set FB_REFERENCE_IMAGE_DIR as Environment variable in your scheme.")
    }
  }

  func assert(assertion: Bool, message: String, file: String, line: UInt) {
    if !assertion {
      XCTFail(message, file: file, line: line)
    }
  }
}
