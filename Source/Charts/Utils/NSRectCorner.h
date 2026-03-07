#import <Foundation/Foundation.h>
#include <TargetConditionals.h>

#if TARGET_OS_OSX

typedef NS_OPTIONS(NSUInteger, NSRectCorner) {
    NSRectCornerTopLeft     = 1 << 0,
    NSRectCornerTopRight    = 1 << 1,
    NSRectCornerBottomLeft  = 1 << 2,
    NSRectCornerBottomRight = 1 << 3,
    NSRectCornerAllCorners  = NSRectCornerTopLeft | NSRectCornerTopRight | NSRectCornerBottomLeft | NSRectCornerBottomRight
};
    
#endif
