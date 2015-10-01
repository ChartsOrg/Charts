/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 Returns a Boolean value that indicates whether the snapshot test is running in 64Bit.
 This method is a convenience for creating the suffixes set based on the architecture
 that the test is running.
 
 @returns @c YES if the test is running in 64bit, otherwise @c NO.
 */
BOOL FBSnapshotTestCaseIs64Bit(void);

/**
 Returns a default set of strings that is used to append a suffix based on the architectures.
 @warning Do not modify this function, you can create your own and use it with @c FBSnapshotVerifyViewWithOptions()
 
 @returns An @c NSOrderedSet object containing strings that are appended to the reference images directory.
 */
NSOrderedSet *FBSnapshotTestCaseDefaultSuffixes(void);

#ifdef __cplusplus
}
#endif
