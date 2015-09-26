![](http://f.cl.ly/items/0r1E192C1R0b2g2Q3h2w/QuickLogo_Color.png)

Quick is a behavior-driven development framework for Swift and Objective-C.
Inspired by [RSpec](https://github.com/rspec/rspec), [Specta](https://github.com/specta/specta), and [Ginkgo](https://github.com/onsi/ginkgo).

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/QuickSpec%20screenshot.png)

```swift
// Swift

import Quick
import Nimble

class TableOfContentsSpec: QuickSpec {
  override func spec() {
    describe("the 'Documentation' directory") {
      it("has everything you need to get started") {
        let sections = Directory("Documentation").sections
        expect(sections).to(contain("Organized Tests with Quick Examples and Example Groups"))
        expect(sections).to(contain("Installing Quick"))
      }

      context("if it doesn't have what you're looking for") {
        it("needs to be updated") {
          let you = You(awesome: true)
          expect{you.submittedAnIssue}.toEventually(beTruthy())
        }
      }
    }
  }
}
```
#### Nimble
Quick comes together with [Nimble](https://github.com/Quick/Nimble) — a matcher framework for your tests. You can learn why `XCTAssert()` statements make your expectations unclear and how to fix that using Nimble assertions [here](./Documentation/NimbleAssertions.md).

## Documentation

All documentation can be found in the [Documentation folder](./Documentation), including [detailed installation instructions](./Documentation/InstallingQuick.md) for CocoaPods, Carthage, Git submodules, and more. For example, you can install Quick and [Nimble](https://github.com/Quick/Nimble) using CocoaPods by adding the following to your Podfile:

```rb
# Podfile

use_frameworks!

def testing_pods
    # If you're using Xcode 7 / Swift 2
    pod 'Quick', '~> 0.5.0'
    pod 'Nimble', '2.0.0-rc.2'

    # If you're using Xcode 6 / Swift 1.2
    pod 'Quick', '~> 0.3.0'
    pod 'Nimble', '~> 1.0.0'
end

target 'MyTests' do
    testing_pods
end

target 'MyUITests' do
    testing_pods
end
```

## License

Apache 2.0 license. See the `LICENSE` file for details.
