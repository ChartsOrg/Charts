<!-- Hiding until we have Swift 2 on CI: [![Build Status](https://travis-ci.org/ashfurrow/Nimble-Snapshots.svg)](https://travis-ci.org/ashfurrow/Nimble-Snapshots) -->

Nimble-Snapshots
=============================

[Nimble](https://github.com/Quick/Nimble) matchers for [FBSnapshotTestCase](https://github.com/facebook/ios-snapshot-test-case).
Highly derivative of [Expecta Matchers for FBSnapshotTestCase](https://github.com/dblock/ios-snapshot-test-case-expecta). 

<p align="center">
<img src="http://gifs.ashfurrow.com/click.gif" />
</p>

Installing
----------

You need to be using CocoaPods 0.36 Beta 1 or higher. Your podfile should look
something like the following.

```rb
platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

# Whichever pods you need for your app go here.

target 'YOUR_APP_NAME_HERE_Tests', :exclusive => true do
  pod 'Nimble-Snapshots'
end
```

Then run `pod install`. 

Use
---

Your tests will look something like the following.

```swift
import Quick
import Nimble
import Nimble_Snapshots
import UIKit

class MySpec: QuickSpec {
    override func spec() {
        describe("in some context", { () -> () in
            it("has valid snapshot") {
                let view = ... // some view you want to test
                expect(view).to( haveValidSnapshot() )
            }
        });
    }
}
```

There are some options for testing the validity of snapshots. Snapshots can be
given a name:

```swift
expect(view).to( haveValidSnapshot(named: "some custom name") )
```

We also have a prettier syntax for custom-named snapshots:

```swift
expect(view) == snapshot("some custom name")
```

To record snapshots, just replace `haveValidSnapshot()` with `recordSnapshot()`
and `haveValidSnapshot(named:)` with `recordSnapshot(named:)`. We also have a 
handy emoji operator. 

```swift
📷(view)
📷(view, "some custom name")
```

If you have any questions or run into any trouble, feel free to open an issue
on this repo. 
