////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class RLMRealm;

// Add a Realm to the weak cache
FOUNDATION_EXPORT void RLMCacheRealm(RLMRealm *realm);
// Get a Realm for the given path which can be used on the current thread
FOUNDATION_EXPORT RLMRealm *RLMGetThreadLocalCachedRealmForPath(NSString *path);
// Get a Realm for the given path
FOUNDATION_EXPORT RLMRealm *RLMGetAnyCachedRealmForPath(NSString *path);
// Clear the weak cache of Realms
FOUNDATION_EXPORT void RLMClearRealmCache();

// Install an uncaught exception handler that cancels write transactions
// for all cached realms on the current thread
FOUNDATION_EXPORT void RLMInstallUncaughtExceptionHandler();

@interface RLMNotifier : NSObject
// listens to changes to the realm's file and notifies it when they occur
// does not retain the Realm
- (instancetype)initWithRealm:(RLMRealm *)realm error:(NSError **)error;
// stop listening for changes
- (void)stop;
// notify other Realm instances for the same path that a change has occurred
- (void)notifyOtherRealms;
@end
