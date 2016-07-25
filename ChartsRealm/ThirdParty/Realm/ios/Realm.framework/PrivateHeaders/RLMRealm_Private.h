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

#import <Realm/RLMRealm.h>

@class RLMFastEnumerator;

// Disable syncing files to disk. Cannot be re-enabled. Use only for tests.
FOUNDATION_EXTERN void RLMDisableSyncToDisk();

FOUNDATION_EXTERN NSData *RLMRealmValidatedEncryptionKey(NSData *key);

// Translate an in-flight exception resulting from opening a SharedGroup to
// an NSError or NSException (if error is nil)
void RLMRealmTranslateException(NSError **error);

// RLMRealm private members
@interface RLMRealm ()

@property (nonatomic, readonly) BOOL dynamic;
@property (nonatomic, readwrite) RLMSchema *schema;

+ (void)resetRealmState;

- (void)registerEnumerator:(RLMFastEnumerator *)enumerator;
- (void)unregisterEnumerator:(RLMFastEnumerator *)enumerator;
- (void)detachAllEnumerators;

- (void)sendNotifications:(RLMNotification)notification;
- (void)verifyThread;
- (void)verifyNotificationsAreSupported;

+ (NSString *)writeableTemporaryPathForFile:(NSString *)fileName;

@end
