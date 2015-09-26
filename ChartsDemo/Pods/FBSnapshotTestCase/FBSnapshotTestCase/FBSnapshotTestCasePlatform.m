/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCasePlatform.h>

BOOL FBSnapshotTestCaseIs64Bit(void)
{
#if __LP64__
  return YES;
#else
  return NO;
#endif
}

NSOrderedSet *FBSnapshotTestCaseDefaultSuffixes(void)
{
  NSMutableOrderedSet *suffixesSet = [[NSMutableOrderedSet alloc] init];
  [suffixesSet addObject:@"_32"];
  [suffixesSet addObject:@"_64"];
  if (FBSnapshotTestCaseIs64Bit()) {
    return [suffixesSet reversedOrderedSet];
  } 
  return [suffixesSet copy];
}
