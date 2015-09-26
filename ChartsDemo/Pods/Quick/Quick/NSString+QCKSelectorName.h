#import <Foundation/Foundation.h>

/**
 QuickSpec converts example names into test methods.
 Those test methods need valid selector names, which means no whitespace,
 control characters, etc. This category gives NSString objects an easy way
 to replace those illegal characters with underscores.
 */
@interface NSString (QCKSelectorName)

/**
 Returns a string with underscores in place of all characters that cannot
 be included in a selector (SEL) name.
 */
@property (nonatomic, readonly) NSString *qck_selectorName;

@end
