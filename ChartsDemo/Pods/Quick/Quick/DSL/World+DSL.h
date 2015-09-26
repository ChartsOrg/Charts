#import <Quick/Quick-Swift.h>

@interface World (SWIFT_EXTENSION(Quick))
- (void)beforeSuite:(void (^ __nonnull)(void))closure;
- (void)afterSuite:(void (^ __nonnull)(void))closure;
- (void)sharedExamples:(NSString * __nonnull)name closure:(void (^ __nonnull)(NSDictionary * __nonnull (^ __nonnull)(void)))closure;
- (void)describe:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags closure:(void (^ __nonnull)(void))closure;
- (void)context:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags closure:(void (^ __nonnull)(void))closure;
- (void)fdescribe:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags closure:(void (^ __nonnull)(void))closure;
- (void)xdescribe:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags closure:(void (^ __nonnull)(void))closure;
- (void)beforeEach:(void (^ __nonnull)(void))closure;
- (void)beforeEachWithMetadata:(void (^ __nonnull)(ExampleMetadata * __nonnull))closure;
- (void)afterEach:(void (^ __nonnull)(void))closure;
- (void)afterEachWithMetadata:(void (^ __nonnull)(ExampleMetadata * __nonnull))closure;
- (void)itWithDescription:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags file:(NSString * __nonnull)file line:(NSUInteger)line closure:(void (^ __nonnull)(void))closure;
- (void)fitWithDescription:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags file:(NSString * __nonnull)file line:(NSUInteger)line closure:(void (^ __nonnull)(void))closure;
- (void)xitWithDescription:(NSString * __nonnull)description flags:(NSDictionary * __nonnull)flags file:(NSString * __nonnull)file line:(NSUInteger)line closure:(void (^ __nonnull)(void))closure;
- (void)itBehavesLikeSharedExampleNamed:(NSString * __nonnull)name sharedExampleContext:(NSDictionary * __nonnull (^ __nonnull)(void))sharedExampleContext flags:(NSDictionary * __nonnull)flags file:(NSString * __nonnull)file line:(NSUInteger)line;
- (void)pending:(NSString * __nonnull)description closure:(void (^ __nonnull)(void))closure;
@end
