#import <Nimble/DSL.h>
#import <Nimble/Nimble-Swift.h>

SWIFT_CLASS("_TtC6Nimble7NMBWait")
@interface NMBWait : NSObject

+ (void)untilTimeout:(NSTimeInterval)timeout file:(NSString *)file line:(NSUInteger)line action:(void(^)())action;
+ (void)untilFile:(NSString *)file line:(NSUInteger)line action:(void(^)())action;

@end

NIMBLE_EXPORT NMBExpectation *NMB_expect(id(^actualBlock)(), NSString *file, NSUInteger line) {
    return [[NMBExpectation alloc] initWithActualBlock:actualBlock
                                              negative:NO
                                                  file:file
                                                  line:line];
}

NIMBLE_EXPORT NMBExpectation *NMB_expectAction(void(^actualBlock)(), NSString *file, NSUInteger line) {
    return NMB_expect(^id{
        actualBlock();
        return nil;
    }, file, line);
}

NIMBLE_EXPORT void NMB_failWithMessage(NSString *msg, NSString *file, NSUInteger line) {
    return [NMBExpectation failWithMessage:msg file:file line:line];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beAnInstanceOf(Class expectedClass) {
    return [NMBObjCMatcher beAnInstanceOfMatcher:expectedClass];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beAKindOf(Class expectedClass) {
    return [NMBObjCMatcher beAKindOfMatcher:expectedClass];
}

NIMBLE_EXPORT NMBObjCBeCloseToMatcher *NMB_beCloseTo(NSNumber *expectedValue) {
    return [NMBObjCMatcher beCloseToMatcher:expectedValue within:0.001];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beginWith(id itemElementOrSubstring) {
    return [NMBObjCMatcher beginWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beGreaterThan(NSNumber *expectedValue) {
    return [NMBObjCMatcher beGreaterThanMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beGreaterThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBObjCMatcher beGreaterThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beIdenticalTo(id expectedInstance) {
    return [NMBObjCMatcher beIdenticalToMatcher:expectedInstance];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beLessThan(NSNumber *expectedValue) {
    return [NMBObjCMatcher beLessThanMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beLessThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBObjCMatcher beLessThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beTruthy() {
    return [NMBObjCMatcher beTruthyMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beFalsy() {
    return [NMBObjCMatcher beFalsyMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beTrue() {
    return [NMBObjCMatcher beTrueMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beFalse() {
    return [NMBObjCMatcher beFalseMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beNil() {
    return [NMBObjCMatcher beNilMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_beEmpty() {
    return [NMBObjCMatcher beEmptyMatcher];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_containWithNilTermination(id itemOrSubstring, ...) {
    NSMutableArray *itemOrSubstringArray = [NSMutableArray array];

    if (itemOrSubstring) {
        [itemOrSubstringArray addObject:itemOrSubstring];

        va_list args;
        va_start(args, itemOrSubstring);
        id next;
        while ((next = va_arg(args, id))) {
            [itemOrSubstringArray addObject:next];
        }
        va_end(args);
    }

    return [NMBObjCMatcher containMatcher:itemOrSubstringArray];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_endWith(id itemElementOrSubstring) {
    return [NMBObjCMatcher endWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_equal(id expectedValue) {
    return [NMBObjCMatcher equalMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_match(id expectedValue) {
    return [NMBObjCMatcher matchMatcher:expectedValue];
}

NIMBLE_EXPORT id<NMBMatcher> NMB_allPass(id expectedValue) {
    return [NMBObjCMatcher allPassMatcher:expectedValue];
}

NIMBLE_EXPORT NMBObjCRaiseExceptionMatcher *NMB_raiseException() {
    return [NMBObjCMatcher raiseExceptionMatcher];
}

NIMBLE_EXPORT NMBWaitUntilTimeoutBlock NMB_waitUntilTimeoutBuilder(NSString *file, NSUInteger line) {
    return ^(NSTimeInterval timeout, void (^action)(void (^)(void))) {
        [NMBWait untilTimeout:timeout file:file line:line action:action];
    };
}

NIMBLE_EXPORT NMBWaitUntilBlock NMB_waitUntilBuilder(NSString *file, NSUInteger line) {
  return ^(void (^action)(void (^)(void))) {
    [NMBWait untilFile:file line:line action:action];
  };
}
