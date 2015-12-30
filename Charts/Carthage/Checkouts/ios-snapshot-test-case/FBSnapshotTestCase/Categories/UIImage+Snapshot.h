/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

@interface UIImage (Snapshot)

/// Uses renderInContext: to get a snapshot of the layer.
+ (UIImage *)fb_imageForLayer:(CALayer *)layer;

/// Uses renderInContext: to get a snapshot of the view layer.
+ (UIImage *)fb_imageForViewLayer:(UIView *)view;

/// Uses drawViewHierarchyInRect: to get a snapshot of the view and adds the view into a window if needed.
+ (UIImage *)fb_imageForView:(UIView *)view;

@end
