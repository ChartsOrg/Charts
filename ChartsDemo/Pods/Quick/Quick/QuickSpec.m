#import "QuickSpec.h"
#import "QuickConfiguration.h"
#import "NSString+QCKSelectorName.h"
#import "World.h"
#import <objc/runtime.h>

static QuickSpec *currentSpec = nil;

const void * const QCKExampleKey = &QCKExampleKey;

@interface QuickSpec ()
@property (nonatomic, strong) Example *example;
@end

@implementation QuickSpec

#pragma mark - XCTestCase Overrides

/**
 The runtime sends initialize to each class in a program just before the class, or any class
 that inherits from it, is sent its first message from within the program. QuickSpec hooks into
 this event to compile the example groups for this spec subclass.

 If an exception occurs when compiling the examples, report it to the user. Chances are they
 included an expectation outside of a "it", "describe", or "context" block.
 */
+ (void)initialize {
    [QuickConfiguration initialize];

    World *world = [World sharedWorld];
    world.currentExampleGroup = [world rootExampleGroupForSpecClass:[self class]];
    QuickSpec *spec = [self new];

    @try {
        [spec spec];
    }
    @catch (NSException *exception) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"An exception occurred when building Quick's example groups.\n"
                           @"Some possible reasons this might happen include:\n\n"
                           @"- An 'expect(...).to' expectation was evaluated outside of "
                           @"an 'it', 'context', or 'describe' block\n"
                           @"- 'sharedExamples' was called twice with the same name\n"
                           @"- 'itBehavesLike' was called with a name that is not registered as a shared example\n\n"
                           @"Here's the original exception: '%@', reason: '%@', userInfo: '%@'",
                           exception.name, exception.reason, exception.userInfo];
    }
}

/**
 Invocations for each test method in the test case. QuickSpec overrides this method to define a
 new method for each example defined in +[QuickSpec spec].

 @return An array of invocations that execute the newly defined example methods.
 */
+ (NSArray *)testInvocations {
    NSArray *examples = [[World sharedWorld] examplesForSpecClass:[self class]];
    NSMutableArray *invocations = [NSMutableArray arrayWithCapacity:[examples count]];
    for (Example *example in examples) {
        SEL selector = [self addInstanceMethodForExample:example];
        NSInvocation *invocation = [self invocationForInstanceMethodWithSelector:selector
                                                                         example:example];
        [invocations addObject:invocation];
    }

    return invocations;
}

/**
 XCTest sets the invocation for the current test case instance using this setter.
 QuickSpec hooks into this event to give the test case a reference to the current example.
 It will need this reference to correctly report its name to XCTest.
 */
- (void)setInvocation:(NSInvocation *)invocation {
    self.example = objc_getAssociatedObject(invocation, QCKExampleKey);
    [super setInvocation:invocation];
}

#pragma mark - Public Interface

- (void)spec { }

#pragma mark - Internal Methods

/**
 QuickSpec uses this method to dynamically define a new instance method for the
 given example. The instance method runs the example, catching any exceptions.
 The exceptions are then reported as test failures.

 In order to report the correct file and line number, examples must raise exceptions
 containing following keys in their userInfo:

 - "SenTestFilenameKey": A String representing the file name
 - "SenTestLineNumberKey": An Int representing the line number

 These keys used to be used by SenTestingKit, and are still used by some testing tools
 in the wild. See: https://github.com/Quick/Quick/pull/41

 @return The selector of the newly defined instance method.
 */
+ (SEL)addInstanceMethodForExample:(Example *)example {
    IMP implementation = imp_implementationWithBlock(^(QuickSpec *self){
        currentSpec = self;
        [example run];
    });
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    NSMutableString *sanitizedFileName = [NSMutableString string];
    for (NSUInteger i = 0; i < example.callsite.file.length; i++) {
        unichar ch = [example.callsite.file characterAtIndex:i];
        if ([characterSet characterIsMember:ch]) {
            [sanitizedFileName appendFormat:@"%c", ch];
        }
    }

    const char *types = [[NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)] UTF8String];
    NSString *selectorName = [NSString stringWithFormat:@"%@_%@_%ld",
                              example.name.qck_selectorName,
                              sanitizedFileName,
                              (long)example.callsite.line];
    SEL selector = NSSelectorFromString(selectorName);
    class_addMethod(self, selector, implementation, types);

    return selector;
}

+ (NSInvocation *)invocationForInstanceMethodWithSelector:(SEL)selector
                                                  example:(Example *)example {
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    objc_setAssociatedObject(invocation,
                             QCKExampleKey,
                             example,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return invocation;
}

/**
 This method is used to record failures, whether they represent example
 expectations that were not met, or exceptions raised during test setup
 and teardown. By default, the failure will be reported as an
 XCTest failure, and the example will be highlighted in Xcode.
 */
- (void)recordFailureWithDescription:(NSString *)description
                              inFile:(NSString *)filePath
                              atLine:(NSUInteger)lineNumber
                            expected:(BOOL)expected {
    if (self.example.isSharedExample) {
        filePath = self.example.callsite.file;
        lineNumber = self.example.callsite.line;
    }
    [currentSpec.testRun recordFailureWithDescription:description
                                               inFile:filePath
                                               atLine:lineNumber
                                             expected:expected];
}

@end
