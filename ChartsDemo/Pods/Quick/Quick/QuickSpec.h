#import <XCTest/XCTest.h>

/**
 QuickSpec is a base class all specs written in Quick inherit from.
 They need to inherit from QuickSpec, a subclass of XCTestCase, in
 order to be discovered by the XCTest framework.

 XCTest automatically compiles a list of XCTestCase subclasses included
 in the test target. It iterates over each class in that list, and creates
 a new instance of that class for each test method. It then creates an
 "invocation" to execute that test method. The invocation is an instance of
 NSInvocation, which represents a single message send in Objective-C.
 The invocation is set on the XCTestCase instance, and the test is run.

 Most of the code in QuickSpec is dedicated to hooking into XCTest events.
 First, when the spec is first loaded and before it is sent any messages,
 the +[NSObject initialize] method is called. QuickSpec overrides this method
 to call +[QuickSpec spec]. This builds the example group stacks and
 registers them with Quick.World, a global register of examples.

 Then, XCTest queries QuickSpec for a list of test methods. Normally, XCTest
 automatically finds all methods whose selectors begin with the string "test".
 However, QuickSpec overrides this default behavior by implementing the
 +[XCTestCase testInvocations] method. This method iterates over each example
 registered in Quick.World, defines a new method for that example, and
 returns an invocation to call that method to XCTest. Those invocations are
 the tests that are run by XCTest. Their selector names are displayed in
 the Xcode test navigation bar.
 */
@interface QuickSpec : XCTestCase

/**
 Override this method in your spec to define a set of example groups
 and examples.

     override class func spec() {
         describe("winter") {
             it("is coming") {
                 // ...
             }
         }
     }

 See DSL.swift for more information on what syntax is available.
 */
- (void)spec;

@end
