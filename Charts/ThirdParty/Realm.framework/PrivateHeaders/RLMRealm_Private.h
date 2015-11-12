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

@class RLMFastEnumerator, RLMNotifier;

// Disable syncing files to disk. Cannot be re-enabled. Use only for tests.
FOUNDATION_EXTERN void RLMDisableSyncToDisk();

FOUNDATION_EXTERN NSData *RLMRealmValidatedEncryptionKey(NSData *key);

FOUNDATION_EXTERN void RLMRealmSetEncryptionKeyForPath(NSData *encryptionKey, NSString *path);

FOUNDATION_EXTERN NSUInteger RLMRealmSchemaVersionForPath(NSString *path);
FOUNDATION_EXTERN RLMMigrationBlock RLMRealmMigrationBlockForPath(NSString *path);
FOUNDATION_EXTERN void RLMRealmSetSchemaVersionForPath(uint64_t version, NSString *path, RLMMigrationBlock migrationBlock);

FOUNDATION_EXTERN void RLMRealmAddPathSettingsToConfiguration(RLMRealmConfiguration *configuration);

// RLMRealm private members
@interface RLMRealm () {
    @public
    // expose ivar to to avoid objc messages in accessors
    BOOL _inWriteTransaction;
    mach_port_t _threadID;
}

@property (nonatomic, readonly) BOOL dynamic;
@property (nonatomic, readwrite) RLMSchema *schema;
@property (nonatomic, strong) RLMNotifier *notifier;

+ (void)resetRealmState;

- (instancetype)initWithPath:(NSString *)path key:(NSData *)key readOnly:(BOOL)readonly inMemory:(BOOL)inMemory dynamic:(BOOL)dynamic error:(NSError **)error;

/**
 This method is useful only in specialized circumstances, for example, when opening Realm files
 retrieved externally that contain a different schema than defined in your application.
 If you are simply building an app on Realm you should consider using:
 [defaultRealm]([RLMRealm defaultRealm]) or [realmWithPath:]([RLMRealm realmWithPath:])
 
 Obtains an `RLMRealm` instance with persistence to a specific file path with
 options.
 
 @warning This method is useful only in specialized circumstances.
 
 @param path         Path to the file you want the data saved in.
 @param key          64-byte key to use to encrypt the data.
 @param readonly     `BOOL` indicating if this Realm is read-only (must use for read-only files)
 @param inMemory     `BOOL` indicating if this Realm is in-memory
 @param dynamic      `BOOL` indicating if this Realm is dynamic
 @param customSchema `RLMSchema` object representing the schema for the Realm
 @param outError     If an error occurs, upon return contains an `NSError` object
 that describes the problem. If you are not interested in
 possible errors, pass in NULL.
 
 @return An `RLMRealm` instance.
 
 @see RLMRealm defaultRealm
 @see RLMRealm realmWithPath:
 @see RLMRealm realmWithPath:readOnly:error:
 @see RLMRealm realmWithPath:encryptionKey:readOnly:error:
 */
+ (instancetype)realmWithPath:(NSString *)path
                          key:(NSData *)key
                     readOnly:(BOOL)readonly
                     inMemory:(BOOL)inMemory
                      dynamic:(BOOL)dynamic
                       schema:(RLMSchema *)customSchema
                        error:(NSError **)outError;

- (void)registerEnumerator:(RLMFastEnumerator *)enumerator;
- (void)unregisterEnumerator:(RLMFastEnumerator *)enumerator;

+ (NSString *)writeableTemporaryPathForFile:(NSString *)fileName;

@end
