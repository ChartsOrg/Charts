# Nimble

Use Nimble to express the expected outcomes of Swift
or Objective-C expressions. Inspired by
[Cedar](https://github.com/pivotal/cedar).

```swift
// Swift

expect(1 + 1).to(equal(2))
expect(1.2).to(beCloseTo(1.1, within: 0.1))
expect(3) > 2
expect("seahorse").to(contain("sea"))
expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
expect(ocean.isClean).toEventually(beTruthy())
```

# How to Use Nimble

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Some Background: Expressing Outcomes Using Assertions in XCTest](#some-background-expressing-outcomes-using-assertions-in-xctest)
- [Nimble: Expectations Using `expect(...).to`](#nimble-expectations-using-expectto)
  - [Type Checking](#type-checking)
  - [Operator Overloads](#operator-overloads)
  - [Lazily Computed Values](#lazily-computed-values)
  - [C Primitives](#c-primitives)
  - [Asynchronous Expectations](#asynchronous-expectations)
  - [Objective-C Support](#objective-c-support)
  - [Disabling Objective-C Shorthand](#disabling-objective-c-shorthand)
- [Built-in Matcher Functions](#built-in-matcher-functions)
  - [Equivalence](#equivalence)
  - [Identity](#identity)
  - [Comparisons](#comparisons)
  - [Types/Classes](#typesclasses)
  - [Truthiness](#truthiness)
  - [Exceptions](#exceptions)
  - [Collection Membership](#collection-membership)
  - [Strings](#strings)
  - [Checking if all elements of a collection pass a condition](#checking-if-all-elements-of-a-collection-pass-a-condition)
- [Writing Your Own Matchers](#writing-your-own-matchers)
  - [Lazy Evaluation](#lazy-evaluation)
  - [Type Checking via Swift Generics](#type-checking-via-swift-generics)
  - [Customizing Failure Messages](#customizing-failure-messages)
  - [Supporting Objective-C](#supporting-objective-c)
    - [Properly Handling `nil` in Objective-C Matchers](#properly-handling-nil-in-objective-c-matchers)
- [Installing Nimble](#installing-nimble)
  - [Installing Nimble as a Submodule](#installing-nimble-as-a-submodule)
  - [Installing Nimble via CocoaPods](#installing-nimble-via-cocoapods)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Some Background: Expressing Outcomes Using Assertions in XCTest

Apple's Xcode includes the XCTest framework, which provides
assertion macros to test whether code behaves properly.
For example, to assert that `1 + 1 = 2`, XCTest has you write:

```swift
// Swift

XCTAssertEqual(1 + 1, 2, "expected one plus one to equal two")
```

Or, in Objective-C:

```objc
// Objective-C

XCTAssertEqual(1 + 1, 2, @"expected one plus one to equal two");
```

XCTest assertions have a couple of drawbacks:

1. **Not enough macros.** There's no easy way to assert that a string
   contains a particular substring, or that a number is less than or
   equal to another.
2. **It's hard to write asynchronous tests.** XCTest forces you to write
   a lot of boilerplate code.

Nimble addresses these concerns.

# Nimble: Expectations Using `expect(...).to`

Nimble allows you to express expectations using a natural,
easily understood language:

```swift
// Swift

import Nimble

expect(seagull.squawk).to(equal("Squee!"))
```

```objc
// Objective-C

@import Nimble;

expect(seagull.squawk).to(equal(@"Squee!"));
```

> The `expect` function autocompletes to include `file:` and `line:`,
  but these parameters are optional. Use the default values to have
  Xcode highlight the correct line when an expectation is not met.

To perform the opposite expectation--to assert something is *not*
equal--use `toNot` or `notTo`:

```swift
// Swift

import Nimble

expect(seagull.squawk).toNot(equal("Oh, hello there!"))
expect(seagull.squawk).notTo(equal("Oh, hello there!"))
```

```objc
// Objective-C

@import Nimble;

expect(seagull.squawk).toNot(equal(@"Oh, hello there!"));
expect(seagull.squawk).notTo(equal(@"Oh, hello there!"));
```

## Custom Failure Messages

Would you like to add more information to the test's failure messages? Use the `description` optional argument to add your own text:

```swift
// Swift

expect(1 + 1).to(equal(3))
// failed - expected to equal <3>, got <2>

expect(1 + 1).to(equal(3), description: "Make sure libKindergartenMath is loaded")
// failed - Make sure libKindergartenMath is loaded
// expected to equal <3>, got <2>
```

Or the *WithDescription version in Objective-C:

```objc
// Objective-C

@import Nimble;

expect(@(1+1)).to(equal(@3));
// failed - expected to equal <3.0000>, got <2.0000>

expect(@(1+1)).toWithDescription(equal(@3), @"Make sure libKindergartenMath is loaded");
// failed - Make sure libKindergartenMath is loaded
// expected to equal <3.0000>, got <2.0000>
```

## Type Checking

Nimble makes sure you don't compare two types that don't match:

```swift
// Swift

// Does not compile:
expect(1 + 1).to(equal("Squee!"))
```

> Nimble uses generics--only available in Swift--to ensure
  type correctness. That means type checking is
  not available when using Nimble in Objective-C. :sob:

## Operator Overloads

Tired of so much typing? With Nimble, you can use overloaded operators
like `==` for equivalence, or `>` for comparisons:

```swift
// Swift

// Passes if squawk does not equal "Hi!":
expect(seagull.squawk) != "Hi!"

// Passes if 10 is greater than 2:
expect(10) > 2
```

> Operator overloads are only available in Swift, so you won't be able
  to use this syntax in Objective-C. :broken_heart:

## Lazily Computed Values

The `expect` function doesn't evalaute the value it's given until it's
time to match. So Nimble can test whether an expression raises an
exception once evaluated:

```swift
// Swift

// Note: Swift currently doesn't have exceptions.
//       Only Objective-C code can raise exceptions
//       that Nimble will catch.
let exception = NSException(
  name: NSInternalInconsistencyException,
  reason: "Not enough fish in the sea.",
  userInfo: ["something": "is fishy"])
expect { exception.raise() }.to(raiseException())

// Also, you can customize raiseException to be more specific
expect { exception.raise() }.to(raiseException(named: NSInternalInconsistencyException))
expect { exception.raise() }.to(raiseException(
    named: NSInternalInconsistencyException,
    reason: "Not enough fish in the sea"))
expect { exception.raise() }.to(raiseException(
    named: NSInternalInconsistencyException,
    reason: "Not enough fish in the sea",
    userInfo: ["something": "is fishy"]))
```

Objective-C works the same way, but you must use the `expectAction`
macro when making an expectation on an expression that has no return
value:

```objc
// Objective-C

NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                 reason:@"Not enough fish in the sea."
                                               userInfo:nil];
expectAction(^{ [exception raise]; }).to(raiseException());

// Use the property-block syntax to be more specific.
expectAction(^{ [exception raise]; }).to(raiseException().named(NSInternalInconsistencyException));
expectAction(^{ [exception raise]; }).to(raiseException().
    named(NSInternalInconsistencyException).
    reason("Not enough fish in the sea"));
expectAction(^{ [exception raise]; }).to(raiseException().
    named(NSInternalInconsistencyException).
    reason("Not enough fish in the sea").
    userInfo(@{@"something": @"is fishy"}));

// You can also pass a block for custom matching of the raised exception
expectAction(exception.raise()).to(raiseException().satisfyingBlock(^(NSException *exception) {
    expect(exception.name).to(beginWith(NSInternalInconsistencyException));
}));
```

## C Primitives

Some testing frameworks make it hard to test primitive C values.
In Nimble, it just works:

```swift
// Swift

let actual: CInt = 1
let expectedValue: CInt = 1
expect(actual).to(equal(expectedValue))
```

In fact, Nimble uses type inference, so you can write the above
without explicitly specifying both types:

```swift
// Swift

expect(1 as CInt).to(equal(1))
```

> In Objective-C, Nimble only supports Objective-C objects. To
  make expectations on primitive C values, wrap then in an object
  literal:

  ```objc
  expect(@(1 + 1)).to(equal(@2));
  ```

## Asynchronous Expectations

In Nimble, it's easy to make expectations on values that are updated
asynchronously. Just use `toEventually` or `toEventuallyNot`:

```swift
// Swift

dispatch_async(dispatch_get_main_queue()) {
  ocean.add("dolphins")
  ocean.add("whales")
}
expect(ocean).toEventually(contain("dolphins", "whales"))
```


```objc
// Objective-C
dispatch_async(dispatch_get_main_queue(), ^{
  [ocean add:@"dolphins"];
  [ocean add:@"whales"];
});
expect(ocean).toEventually(contain(@"dolphins", @"whales"));
```

In the above example, `ocean` is constantly re-evaluated. If it ever
contains dolphins and whales, the expectation passes. If `ocean` still
doesn't contain them, even after being continuously re-evaluated for one
whole second, the expectation fails.

Sometimes it takes more than a second for a value to update. In those
cases, use the `timeout` parameter:

```swift
// Swift

// Waits three seconds for ocean to contain "starfish":
expect(ocean).toEventually(contain("starfish"), timeout: 3)
```

```objc
// Objective-C

// Waits three seconds for ocean to contain "starfish":
expect(ocean).withTimeout(3).toEventually(contain(@"starfish"));
```

You can also provide a callback by using the `waitUntil` function:

```swift
// Swift

waitUntil { done in
  // do some stuff that takes a while...
  NSThread.sleepForTimeInterval(0.5)
  done()
}
```

```objc
// Objective-C

waitUntil(^(void (^done)(void)){
  // do some stuff that takes a while...
  [NSThread sleepForTimeInterval:0.5];
  done();
});
```

`waitUntil` also optionally takes a timeout parameter:

```swift
// Swift

waitUntil(timeout: 10) { done in
  // do some stuff that takes a while...
  NSThread.sleepForTimeInterval(1)
  done()
}
```

```objc
// Objective-C

waitUntilTimeout(10, ^(void (^done)(void)){
  // do some stuff that takes a while...
  [NSThread sleepForTimeInterval:1];
  done();
});
```

## Objective-C Support

Nimble has full support for Objective-C. However, there are two things
to keep in mind when using Nimble in Objective-C:

1. All parameters passed to the `expect` function, as well as matcher
   functions like `equal`, must be Objective-C objects:

   ```objc
   // Objective-C

   @import Nimble;

   expect(@(1 + 1)).to(equal(@2));
   expect(@"Hello world").to(contain(@"world"));
   ```

2. To make an expectation on an expression that does not return a value,
   such as `-[NSException raise]`, use `expectAction` instead of
   `expect`:

   ```objc
   // Objective-C

   expectAction(^{ [exception raise]; }).to(raiseException());
   ```

## Disabling Objective-C Shorthand

Nimble provides a shorthand for expressing expectations using the
`expect` function. To disable this shorthand in Objective-C, define the
`NIMBLE_DISABLE_SHORT_SYNTAX` macro somewhere in your code before
importing Nimble:

```objc
#define NIMBLE_DISABLE_SHORT_SYNTAX 1

@import Nimble;

NMB_expect(^{ return seagull.squawk; }, __FILE__, __LINE__).to(NMB_equal(@"Squee!"));
```

> Disabling the shorthand is useful if you're testing functions with
  names that conflict with Nimble functions, such as `expect` or
  `equal`. If that's not the case, there's no point in disabling the
  shorthand.

# Built-in Matcher Functions

Nimble includes a wide variety of matcher functions.

## Equivalence

```swift
// Swift

// Passes if actual is equivalent to expected:
expect(actual).to(equal(expected))
expect(actual) == expected

// Passes if actual is not equivalent to expected:
expect(actual).toNot(equal(expected))
expect(actual) != expected
```

```objc
// Objective-C

// Passes if actual is equivalent to expected:
expect(actual).to(equal(expected))

// Passes if actual is not equivalent to expected:
expect(actual).toNot(equal(expected))
```

Values must be `Equatable`, `Comparable`, or subclasses of `NSObject`.
`equal` will always fail when used to compare one or more `nil` values.

## Identity

```swift
// Swift

// Passes if actual has the same pointer address as expected:
expect(actual).to(beIdenticalTo(expected))
expect(actual) === expected

// Passes if actual does not have the same pointer address as expected:
expect(actual).toNot(beIdenticalTo(expected))
expect(actual) !== expected
```

```objc
// Objective-C

// Passes if actual has the same pointer address as expected:
expect(actual).to(beIdenticalTo(expected));

// Passes if actual does not have the same pointer address as expected:
expect(actual).toNot(beIdenticalTo(expected));
```

> `beIdenticalTo` only supports Objective-C objects: subclasses
  of `NSObject`, or Swift objects bridged to Objective-C with the
  `@objc` prefix.

## Comparisons

```swift
// Swift

expect(actual).to(beLessThan(expected))
expect(actual) < expected

expect(actual).to(beLessThanOrEqualTo(expected))
expect(actual) <= expected

expect(actual).to(beGreaterThan(expected))
expect(actual) > expected

expect(actual).to(beGreaterThanOrEqualTo(expected))
expect(actual) >= expected
```

```objc
// Objective-C

expect(actual).to(beLessThan(expected));
expect(actual).to(beLessThanOrEqualTo(expected));
expect(actual).to(beGreaterThan(expected));
expect(actual).to(beGreaterThanOrEqualTo(expected));
```

> Values given to the comparison matchers above must implement
  `Comparable`.

Because of how computers represent floating point numbers, assertions
that two floating point numbers be equal will sometimes fail. To express
that two numbers should be close to one another within a certain margin
of error, use `beCloseTo`:

```swift
// Swift

expect(actual).to(beCloseTo(expected, within: delta))
```

```objc
// Objective-C

expect(actual).to(beCloseTo(expected).within(delta));
```

For example, to assert that `10.01` is close to `10`, you can write:

```swift
// Swift

expect(10.01).to(beCloseTo(10, within: 0.1))
```

```objc
// Objective-C

expect(@(10.01)).to(beCloseTo(@10).within(0.1));
```

There is also an operator shortcut available in Swift:

```swift
// Swift

expect(actual) ≈ expected
expect(actual) ≈ (expected, delta)

```
(Type Option-x to get ≈ on a U.S. keyboard)

The former version uses the default delta of 0.0001. Here is yet another way to do this:

```swift
// Swift

expect(actual) ≈ expected ± delta
expect(actual) == expected ± delta

```
(Type Option-Shift-= to get ± on a U.S. keyboard)

If you are comparing arrays of floating point numbers, you'll find the following useful:

```swift
// Swift

expect([0.0, 2.0]) ≈ [0.0001, 2.0001]
expect([0.0, 2.0]).to(beCloseTo([0.1, 2.1], within: 0.1))

```

> Values given to the `beCloseTo` matcher must be coercable into a
  `Double`.

## Types/Classes

```swift
// Swift

// Passes if instance is an instance of aClass:
expect(instance).to(beAnInstanceOf(aClass))

// Passes if instance is an instance of aClass or any of its subclasses:
expect(instance).to(beAKindOf(aClass))
```

```objc
// Objective-C

// Passes if instance is an instance of aClass:
expect(instance).to(beAnInstanceOf(aClass));

// Passes if instance is an instance of aClass or any of its subclasses:
expect(instance).to(beAKindOf(aClass));
```

> Instances must be Objective-C objects: subclasses of `NSObject`,
  or Swift objects bridged to Objective-C with the `@objc` prefix.

For example, to assert that `dolphin` is a kind of `Mammal`:

```swift
// Swift

expect(dolphin).to(beAKindOf(Mammal))
```

```objc
// Objective-C

expect(dolphin).to(beAKindOf([Mammal class]));
```

> `beAnInstanceOf` uses the `-[NSObject isMemberOfClass:]` method to
  test membership. `beAKindOf` uses `-[NSObject isKindOfClass:]`.

## Truthiness

```swift
// Passes if actual is not nil, false, or an object with a boolean value of false:
expect(actual).to(beTruthy())

// Passes if actual is only true (not nil or an object conforming to BooleanType true):
expect(actual).to(beTrue())

// Passes if actual is nil, false, or an object with a boolean value of false:
expect(actual).to(beFalsy())

// Passes if actual is only false (not nil or an object conforming to BooleanType false):
expect(actual).to(beFalse())

// Passes if actual is nil:
expect(actual).to(beNil())
```

```objc
// Objective-C

// Passes if actual is not nil, false, or an object with a boolean value of false:
expect(actual).to(beTruthy());

// Passes if actual is only true (not nil or an object conforming to BooleanType true):
expect(actual).to(beTrue());

// Passes if actual is nil, false, or an object with a boolean value of false:
expect(actual).to(beFalsy());

// Passes if actual is only false (not nil or an object conforming to BooleanType false):
expect(actual).to(beFalse());

// Passes if actual is nil:
expect(actual).to(beNil());
```

## Swift Error Handling

If you're using Swift 2.0+, you can use the `throwError` matcher to check if an error is thrown.

```swift
// Swift

// Passes if somethingThatThrows() throws an ErrorType:
expect{ try somethingThatThrows() }.to(throwError())

// Passes if somethingThatThrows() throws an error with a given domain:
expect{ try somethingThatThrows() }.to(throwError { (error: ErrorType) in
    expect(error._domain).to(equal(NSCocoaErrorDomain))
})

// Passes if somethingThatThrows() throws an error with a given case:
expect{ try somethingThatThrows() }.to(throwError(NSCocoaError.PropertyListReadCorruptError))

// Passes if somethingThatThrows() throws an error with a given type:
expect{ try somethingThatThrows() }.to(throwError(errorType: MyError.self))
```

Note: This feature is only available in Swift.

## Exceptions

```swift
// Swift

// Passes if actual, when evaluated, raises an exception:
expect(actual).to(raiseException())

// Passes if actual raises an exception with the given name:
expect(actual).to(raiseException(named: name))

// Passes if actual raises an exception with the given name and reason:
expect(actual).to(raiseException(named: name, reason: reason))

// Passes if actual raises an exception and it passes expectations in the block
// (in this case, if name begins with 'a r')
expect { exception.raise() }.to(raiseException { (exception: NSException) in
    expect(exception.name).to(beginWith("a r"))
})
```

```objc
// Objective-C

// Passes if actual, when evaluated, raises an exception:
expect(actual).to(raiseException())

// Passes if actual raises an exception with the given name
expect(actual).to(raiseException().named(name))

// Passes if actual raises an exception with the given name and reason:
expect(actual).to(raiseException().named(name).reason(reason))

// Passes if actual raises an exception and it passes expectations in the block
// (in this case, if name begins with 'a r')
expect(actual).to(raiseException().satisfyingBlock(^(NSException *exception) {
    expect(exception.name).to(beginWith(@"a r"));
}));
```

Note: Swift currently doesn't have exceptions. Only Objective-C code can raise
exceptions that Nimble will catch.

## Collection Membership

```swift
// Swift

// Passes if all of the expected values are members of actual:
expect(actual).to(contain(expected...))

// Passes if actual is an empty collection (it contains no elements):
expect(actual).to(beEmpty())
```

```objc
// Objective-C

// Passes if expected is a member of actual:
expect(actual).to(contain(expected));

// Passes if actual is an empty collection (it contains no elements):
expect(actual).to(beEmpty());
```

> In Swift `contain` takes any number of arguments. The expectation
  passes if all of them are members of the collection. In Objective-C,
  `contain` only takes one argument [for now](https://github.com/Quick/Nimble/issues/27).

For example, to assert that a list of sea creature names contains
"dolphin" and "starfish":

```swift
// Swift

expect(["whale", "dolphin", "starfish"]).to(contain("dolphin", "starfish"))
```

```objc
// Objective-C

expect(@[@"whale", @"dolphin", @"starfish"]).to(contain(@"dolphin"));
expect(@[@"whale", @"dolphin", @"starfish"]).to(contain(@"starfish"));
```

> `contain` and `beEmpty` expect collections to be instances of
  `NSArray`, `NSSet`, or a Swift collection composed of `Equatable` elements.

To test whether a set of elements is present at the beginning or end of
an ordered collection, use `beginWith` and `endWith`:

```swift
// Swift

// Passes if the elements in expected appear at the beginning of actual:
expect(actual).to(beginWith(expected...))

// Passes if the the elements in expected come at the end of actual:
expect(actual).to(endWith(expected...))
```

```objc
// Objective-C

// Passes if the elements in expected appear at the beginning of actual:
expect(actual).to(beginWith(expected));

// Passes if the the elements in expected come at the end of actual:
expect(actual).to(endWith(expected));
```

> `beginWith` and `endWith` expect collections to be instances of
  `NSArray`, or ordered Swift collections composed of `Equatable`
  elements.

  Like `contain`, in Objective-C `beginWith` and `endWith` only support
  a single argument [for now](https://github.com/Quick/Nimble/issues/27).

## Strings

```swift
// Swift

// Passes if actual contains substring expected:
expect(actual).to(contain(expected))

// Passes if actual begins with substring:
expect(actual).to(beginWith(expected))

// Passes if actual ends with substring:
expect(actual).to(endWith(expected))

// Passes if actual is an empty string, "":
expect(actual).to(beEmpty())

// Passes if actual matches the regular expression defined in expected:
expect(actual).to(match(expected))
```

```objc
// Objective-C

// Passes if actual contains substring expected:
expect(actual).to(contain(expected));

// Passes if actual begins with substring:
expect(actual).to(beginWith(expected));

// Passes if actual ends with substring:
expect(actual).to(endWith(expected));

// Passes if actual is an empty string, "":
expect(actual).to(beEmpty());

// Passes if actual matches the regular expression defined in expected:
expect(actual).to(match(expected))
```

## Checking if all elements of a collection pass a condition

```swift
// Swift

// with a custom function:
expect([1,2,3,4]).to(allPass({$0 < 5}))

// with another matcher:
expect([1,2,3,4]).to(allPass(beLessThan(5)))
```

```objc
// Objective-C

expect(@[@1, @2, @3,@4]).to(allPass(beLessThan(@5)));
```

For Swift the actual value has to be a SequenceType, e.g. an array, a set or a custom seqence type.

For Objective-C the actual value has to be a NSFastEnumeration, e.g. NSArray and NSSet, of NSObjects and only the variant which
uses another matcher is available here.

# Writing Your Own Matchers

In Nimble, matchers are Swift functions that take an expected
value and return a `MatcherFunc` closure. Take `equal`, for example:

```swift
// Swift

public func equal<T: Equatable>(expectedValue: T?) -> MatcherFunc<T?> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "equal <\(expectedValue)>"
    return actualExpression.evaluate() == expectedValue
  }
}
```

The return value of a `MatcherFunc` closure is a `Bool` that indicates
whether the actual value matches the expectation: `true` if it does, or
`false` if it doesn't.

> The actual `equal` matcher function does not match when either
  `actual` or `expected` are nil; the example above has been edited for
  brevity.

Since matchers are just Swift functions, you can define them anywhere:
at the top of your test file, in a file shared by all of your tests, or
in an Xcode project you distribute to others.

> If you write a matcher you think everyone can use, consider adding it
  to Nimble's built-in set of matchers by sending a pull request! Or
  distribute it yourself via GitHub.

For examples of how to write your own matchers, just check out the
[`Matchers` directory](https://github.com/Quick/Nimble/tree/master/Nimble/Matchers)
to see how Nimble's built-in set of matchers are implemented. You can
also check out the tips below.

## Lazy Evaluation

`actualExpression` is a lazy, memoized closure around the value provided to the
`expect` function. The expression can either be a closure or a value directly
passed to `expect(...)`. In order to determine whether that value matches,
custom matchers should call `actualExpression.evaluate()`:

```swift
// Swift

public func beNil<T>() -> MatcherFunc<T?> {
  return MatcherFunc { actualExpression, failureMessage in
    failureMessage.postfixMessage = "be nil"
    return actualExpression.evaluate() == nil
  }
}
```

In the above example, `actualExpression` is not `nil`--it is a closure
that returns a value. The value it returns, which is accessed via the
`evaluate()` method, may be `nil`. If that value is `nil`, the `beNil`
matcher function returns `true`, indicating that the expectation passed.

Use `expression.isClosure` to determine if the expression will be invoking
a closure to produce its value.

## Type Checking via Swift Generics

Using Swift's generics, matchers can constrain the type of the actual value
passed to the `expect` function by modifying the return type.

For example, the following matcher, `haveDescription`, only accepts actual
values that implement the `Printable` protocol. It checks their `description`
against the one provided to the matcher function, and passes if they are the same:

```swift
// Swift

public func haveDescription(description: String) -> MatcherFunc<Printable?> {
  return MatcherFunc { actual, failureMessage in
    return actual.evaluate().description == description
  }
}
```

## Customizing Failure Messages

By default, Nimble outputs the following failure message when an
expectation fails:

```
expected to match, got <\(actual)>
```

You can customize this message by modifying the `failureMessage` struct
from within your `MatcherFunc` closure. To change the verb "match" to
something else, update the `postfixMessage` property:

```swift
// Swift

// Outputs: expected to be under the sea, got <\(actual)>
failureMessage.postfixMessage = "be under the sea"
```

You can change how the `actual` value is displayed by updating
`failureMessage.actualValue`. Or, to remove it altogether, set it to
`nil`:

```swift
// Swift

// Outputs: expected to be under the sea
failureMessage.actualValue = nil
failureMessage.postfixMessage = "be under the sea"
```

## Supporting Objective-C

To use a custom matcher written in Swift from Objective-C, you'll have
to extend the `NMBObjCMatcher` class, adding a new class method for your
custom matcher. The example below defines the class method
`+[NMBObjCMatcher beNilMatcher]`:

```swift
// Swift

extension NMBObjCMatcher {
  public class func beNilMatcher() -> NMBObjCMatcher {
    return NMBObjCMatcher { actualBlock, failureMessage, location in
      let block = ({ actualBlock() as NSObject? })
      let expr = Expression(expression: block, location: location)
      return beNil().matches(expr, failureMessage: failureMessage)
    }
  }
}
```

The above allows you to use the matcher from Objective-C:

```objc
// Objective-C

expect(actual).to([NMBObjCMatcher beNilMatcher]());
```

To make the syntax easier to use, define a C function that calls the
class method:

```objc
// Objective-C

FOUNDATION_EXPORT id<NMBMatcher> beNil() {
  return [NMBObjCMatcher beNilMatcher];
}
```

### Properly Handling `nil` in Objective-C Matchers

When supporting Objective-C, make sure you handle `nil` appropriately.
Like [Cedar](https://github.com/pivotal/cedar/issues/100),
**most matchers do not match with nil**. This is to bring prevent test
writers from being surprised by `nil` values where they did not expect
them.

Nimble provides the `beNil` matcher function for test writer that want
to make expectations on `nil` objects:

```objc
// Objective-C

expect(nil).to(equal(nil)); // fails
expect(nil).to(beNil());    // passes
```

If your matcher does not want to match with nil, you use `NonNilMatcherFunc`
and the `canMatchNil` constructor on `NMBObjCMatcher`. Using both types will
automatically generate expected value failure messages when they're nil.

```swift

public func beginWith<S: SequenceType, T: Equatable where S.Generator.Element == T>(startingElement: T) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "begin with <\(startingElement)>"
        if let actualValue = actualExpression.evaluate() {
            var actualGenerator = actualValue.generate()
            return actualGenerator.next() == startingElement
        }
        return false
    }
}

extension NMBObjCMatcher {
    public class func beginWithMatcher(expected: AnyObject) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let actual = actualExpression.evaluate()
            let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
            return beginWith(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
```

# Installing Nimble

> Nimble can be used on its own, or in conjunction with its sister
  project, [Quick](https://github.com/Quick/Quick). To install both
  Quick and Nimble, follow [the installation instructions in the Quick
  README](https://github.com/Quick/Quick#how-to-install-quick).

Nimble can currently be installed in one of two ways: using CocoaPods, or with
git submodules.

- The `swift-2.0` branch support Swift 2.0.
- The `master` branch of Nimble supports Swift 1.2.
- For Swift 1.1 support, use the `swift-1.1` branch.

## Installing Nimble as a Submodule

To use Nimble as a submodule to test your iOS or OS X applications, follow these
4 easy steps:

1. Clone the Nimble repository
2. Add Nimble.xcodeproj to the Xcode workspace for your project
3. Link Nimble.framework to your test target
4. Start writing expectations!

For more detailed instructions on each of these steps,
read [How to Install Quick](https://github.com/Quick/Quick#how-to-install-quick).
Ignore the steps involving adding Quick to your project in order to
install just Nimble.

## Installing Nimble via CocoaPods

To use Nimble in CocoaPods to test your iOS or OS X applications, add Nimble to
your podfile and add the ```use_frameworks!``` line to enable Swift support for
Cocoapods.

```ruby
platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

# Whatever pods you need for your app go here

target 'YOUR_APP_NAME_HERE_Tests', :exclusive => true do
  use_frameworks!
  # If you're using Swift 2.0 (Xcode 7), use this:
  pod 'Nimble', '2.0.0-rc.2'
  # If you're using Swift 1.2 (Xcode 6), use this:
  pod 'Nimble', '~> 1.0.0'
  # Otherwise, use this commented out line for Swift 1.1 (Xcode 6.2):
  # pod 'Nimble', '~> 0.3.0'
end
```

Finally run `pod install`.
