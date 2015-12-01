/*
*  Copyright (c) 2015, Facebook, Inc.
*  All rights reserved.
*
*  This source code is licensed under the BSD-style license found in the
*  LICENSE file in the root directory of this source tree. An additional grant
*  of patent rights can be found in the PATENTS file in the same directory.
*
*/

import FBSnapshotTestCase

class FBSnapshotTestCaseSwiftTest: FBSnapshotTestCase {
  override func setUp() {
    super.setUp()
    recordMode = false
  }

  func testExample() {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    view.backgroundColor = UIColor.blueColor()
    FBSnapshotVerifyView(view)
    FBSnapshotVerifyLayer(view.layer)
  }
}
