#import "NMBExceptionCapture.h"

@interface NMBExceptionCapture ()
@property (nonatomic, copy) void(^handler)(NSException *exception);
@property (nonatomic, copy) void(^finally)();
@end

@implementation NMBExceptionCapture

- (id)initWithHandler:(void(^)(NSException *))handler finally:(void(^)())finally {
    self = [super init];
    if (self) {
        self.handler = handler;
        self.finally = finally;
    }
    return self;
}

- (void)tryBlock:(void(^)())unsafeBlock {
    @try {
        unsafeBlock();
    }
    @catch (NSException *exception) {
        if (self.handler) {
            self.handler(exception);
        }
    }
    @finally {
        if (self.finally) {
            self.finally();
        }
    }
}

@end
