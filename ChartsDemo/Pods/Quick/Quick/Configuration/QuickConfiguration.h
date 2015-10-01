#import <Foundation/Foundation.h>

@class Configuration;

/**
 Subclass QuickConfiguration and override the +[QuickConfiguration configure:]
 method in order to configure how Quick behaves when running specs, or to define
 shared examples that are used across spec files.
 */
@interface QuickConfiguration : NSObject

/**
 This method is executed on each subclass of this class before Quick runs
 any examples. You may override this method on as many subclasses as you like, but
 there is no guarantee as to the order in which these methods are executed.

 You can override this method in order to:

 1. Configure how Quick behaves, by modifying properties on the Configuration object.
    Setting the same properties in several methods has undefined behavior.

 2. Define shared examples using `sharedExamples`.

 @param configuration A mutable object that is used to configure how Quick behaves on
                      a framework level. For details on all the options, see the
                      documentation in Configuration.swift.
 */
+ (void)configure:(Configuration *)configuration;

@end
