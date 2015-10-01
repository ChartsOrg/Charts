#import "QuickConfiguration.h"
#import "World.h"
#import <objc/runtime.h>

typedef void (^QCKClassEnumerationBlock)(Class klass);

/**
 Finds all direct subclasses of the given class and passes them to the block provided.
 The classes are iterated over in the order that objc_getClassList returns them.

 @param klass The base class to find subclasses of.
 @param block A block that takes a Class. This block will be executed once for each subclass of klass.
 */
void qck_enumerateSubclasses(Class klass, QCKClassEnumerationBlock block) {
    Class *classes = NULL;
    int classesCount = objc_getClassList(NULL, 0);

    if (classesCount > 0) {
        classes = (Class *)calloc(sizeof(Class), classesCount);
        classesCount = objc_getClassList(classes, classesCount);

        Class subclass, superclass;
        for(int i = 0; i < classesCount; i++) {
            subclass = classes[i];
            superclass = class_getSuperclass(subclass);
            if (superclass == klass && block) {
                block(subclass);
            }
        }

        free(classes);
    }
}

@implementation QuickConfiguration

#pragma mark - Object Lifecycle

/**
 QuickConfiguration is not meant to be instantiated; it merely provides a hook
 for users to configure how Quick behaves. Raise an exception if an instance of
 QuickConfiguration is created.
 */
- (instancetype)init {
    NSString *className = NSStringFromClass([self class]);
    NSString *selectorName = NSStringFromSelector(@selector(configure:));
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ is not meant to be instantiated; "
     @"subclass %@ and override %@ to configure Quick.",
     className, className, selectorName];
    return nil;
}

#pragma mark - NSObject Overrides

/**
 Hook into when QuickConfiguration is initialized in the runtime in order to
 call +[QuickConfiguration configure:] on each of its subclasses.
 */
+ (void)initialize {
    // Only enumerate over the subclasses of QuickConfiguration, not any of its subclasses.
    if ([self class] == [QuickConfiguration class]) {

        // Only enumerate over subclasses once, even if +[QuickConfiguration initialize]
        // were to be called several times. This is necessary because +[QuickSpec initialize]
        // manually calls +[QuickConfiguration initialize].
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            qck_enumerateSubclasses([QuickConfiguration class], ^(__unsafe_unretained Class klass) {
                [[World sharedWorld] configure:^(Configuration *configuration) {
                    [klass configure:configuration];
                }];
            });
            [[World sharedWorld] finalizeConfiguration];
        });
    }
}

#pragma mark - Public Interface

+ (void)configure:(Configuration *)configuration { }

@end
