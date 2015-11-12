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
#import <Realm/RLMDefines.h>

@class RLMRealmConfiguration, RLMObject, RLMSchema, RLMMigration, RLMNotificationToken;

RLM_ASSUME_NONNULL_BEGIN

/**
 An RLMRealm instance (also referred to as "a realm") represents a Realm
 database.

 Realms can either be stored on disk (see +[RLMRealm realmWithPath:]) or in
 memory (see +[RLMRealm inMemoryRealmWithIdentifier:]).

 RLMRealm instances are cached internally, and constructing equivalent RLMRealm
 objects (with the same path or identifier) multiple times on a single thread
 within a single iteration of the run loop will normally return the same
 RLMRealm object. If you specifically want to ensure a RLMRealm object is
 destroyed (for example, if you wish to open a realm, check some property, and
 then possibly delete the realm file and re-open it), place the code which uses
 the realm within an `@autoreleasepool {}` and ensure you have no other
 strong references to it.

 @warning RLMRealm instances are not thread safe and can not be shared across
 threads or dispatch queues. You must call this method on each thread you want
 to interact with the realm on. For dispatch queues, this means that you must
 call it in each block which is dispatched, as a queue is not guaranteed to run
 on a consistent thread.
 */

@interface RLMRealm : NSObject
/**---------------------------------------------------------------------------------------
 *  @name Creating & Initializing a Realm
 * ---------------------------------------------------------------------------------------
 */
/**
 Obtains an instance of the default Realm.

 The default Realm is used by the `RLMObject` class methods
 which do not take a `RLMRealm` parameter, but is otherwise not special. The
 default Realm is persisted as default.realm under the Documents directory of
 your Application on iOS, and in your application's Application Support
 directory on OS X.
 
 The default Realm is created using the default `RLMRealmConfiguration`, which
 can be changed via `+[RLMRealmConfiguration setDefaultConfiguration:]`.

 @return The default `RLMRealm` instance for the current thread.
 */
+ (instancetype)defaultRealm;

/**
 Obtains an `RLMRealm` instance with the given configuration.

 @param configuration The configuration for the realm.
 @param error         If an error occurs, upon return contains an `NSError` object
                      that describes the problem. If you are not interested in
                      possible errors, pass in `NULL`.

 @return An `RLMRealm` instance.
 */
+ (nullable instancetype)realmWithConfiguration:(RLMRealmConfiguration *)configuration error:(NSError **)error;

/**
 Obtains an `RLMRealm` instance persisted at a specific file path.

 @param path Path to the file you want the data saved in.

 @return An `RLMRealm` instance.
 */
+ (instancetype)realmWithPath:(NSString *)path;

/**
 Obtains an `RLMRealm` instance with persistence to a specific file path with
 options.

 Like `realmWithPath:`, but with the ability to open read-only realms and get
 errors as an `NSError` inout parameter rather than exceptions.

 @warning Read-only Realms do not support changes made to the file while the
 `RLMRealm` exists. This means that you cannot open a Realm as both read-only
 and read-write at the same time. Read-only Realms should normally only be used
 on files which cannot be opened in read-write mode, and not just for enforcing
 correctness in code that should not need to write to the Realm.

 @param path        Path to the file you want the data saved in.
 @param readonly    BOOL indicating if this Realm is read-only (must use for read-only files)
 @param error       If an error occurs, upon return contains an `NSError` object
                    that describes the problem. If you are not interested in
                    possible errors, pass in `NULL`.

 @return An `RLMRealm` instance.
 */
+ (nullable instancetype)realmWithPath:(NSString *)path readOnly:(BOOL)readonly error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealm realmWithConfiguration:error:]");

/**
 Obtains an `RLMRealm` instance persisted to an encrypted file.

 The on-disk storage for encrypted Realms are encrypted using AES256+HMAC-SHA2,
 but otherwise they behave like normal persisted Realms.

 Encrypted Realms currently cannot be opened while lldb is attached to the
 process since lldb often hangs in this situation. See issue #1625 for
 further discussion. Attempting to open an encrypted Realm with lldb attached
 will result in an EXC_BAD_ACCESS. Running your application with
 REALM_DISABLE_ENCRYPTION=YES set in your environment will result in Realm
 treating requests to open an encrypted Realm as requesting an unencrypted Realm.

 @param path        Path to the file you want the data saved in.
 @param key         64-byte key to use to encrypt the data.
 @param readonly    BOOL indicating if this Realm is read-only (must use for read-only files)
 @param error       If an error occurs, upon return contains an `NSError` object
                    that describes the problem. If you are not interested in
                    possible errors, pass in `NULL`.

 @return An encrypted `RLMRealm` instance.
 */
+ (nullable instancetype)realmWithPath:(NSString *)path
                         encryptionKey:(NSData *)key
                              readOnly:(BOOL)readonly
                                 error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealm realmWithConfiguration:error:]");

/**
 Set the encryption key to use when opening Realms at a certain path.

 This can be used as an alternative to explicitly passing the key to
 `realmWithPath:key:readOnly:error:` each time a Realm instance is
 needed. The encryption key will be used any time a Realm is opened with
 `realmWithPath:` or `defaultRealm`.

 If you do not want Realm to hold on to your encryption keys any longer than
 needed, then use `realmWithPath:encryptionKey:readOnly:error:` rather than this
 method.

 @param key     64-byte encryption key to use, or `nil` to unset.
 @param path    Realm path to set the encryption key for.
 */
+ (void)setEncryptionKey:(nullable NSData *)key forRealmsAtPath:(NSString *)path DEPRECATED_MSG_ATTRIBUTE("Use RLMRealmConfiguration to set an encryption key");

/**
 Obtains an `RLMRealm` instance for an un-persisted in-memory Realm. The identifier
 used to create this instance can be used to access the same in-memory Realm from
 multiple threads.

 Because in-memory Realms are not persisted, you must be sure to hold on to a
 reference to the `RLMRealm` object returned from this for as long as you want
 the data to last. Realm's internal cache of `RLMRealm`s will not keep the
 in-memory Realm alive across cycles of the run loop, so without a strong
 reference to the `RLMRealm` a new Realm will be created each time. Note that
 `RLMObject`s, `RLMArray`s, and `RLMResults` that refer to objects persisted in a Realm have a
 strong reference to the relevant `RLMRealm`, as do `RLMNotifcationToken`s.

 @param identifier  A string used to identify a particular in-memory Realm.

 @return An `RLMRealm` instance.
 */
+ (instancetype)inMemoryRealmWithIdentifier:(NSString *)identifier DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealm realmWithConfiguration:error:]");

/**
 Path to the file where this Realm is persisted.
 */
@property (nonatomic, readonly) NSString *path;

/**
 Indicates if this Realm was opened in read-only mode.
 */
@property (nonatomic, readonly, getter = isReadOnly) BOOL readOnly;

/**
 The RLMSchema used by this RLMRealm.
 */
@property (nonatomic, readonly, null_unspecified) RLMSchema *schema;

/**
 Indicates if this Realm is currently in a write transaction.

 @warning Wrapping mutating operations in a write transaction if this property returns `NO`
          may cause a large number of write transactions to be created, which could negatively
          impact Realm's performance. Always prefer performing multiple mutations in a single
          transaction when possible.
 */
@property (nonatomic, readonly) BOOL inWriteTransaction;

/**
 Returns an `RLMRealmConfiguration` that can be used to create this `RLMRealm` instance.
 */
@property (nonatomic, readonly) RLMRealmConfiguration *configuration;

/**
 Indicates if this Realm contains any objects.
 */
@property (nonatomic, readonly) BOOL isEmpty;

/**---------------------------------------------------------------------------------------
 *  @name Default Realm Path
 * ---------------------------------------------------------------------------------------
 */
/**
 Returns the location of the default Realm as a string.

 `~/Library/Application Support/{bundle ID}/default.realm` on OS X.

 `default.realm` in your application's documents directory on iOS.

 @return Location of the default Realm.

 @see defaultRealm
 */
+ (NSString *)defaultRealmPath DEPRECATED_MSG_ATTRIBUTE("Use [RLMRealmConfiguration defaultConfiguration].path");

/**
 Set the default Realm path to a given path.

 @param defaultRealmPath    The path to use for the default Realm.

 @see defaultRealm
 */
+ (void)setDefaultRealmPath:(NSString *)defaultRealmPath DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealmConfiguration setDefaultConfiguration:]");


#pragma mark - Notifications

typedef void(^RLMNotificationBlock)(NSString *notification, RLMRealm *realm);

/**---------------------------------------------------------------------------------------
 *  @name Receiving Notification when a Realm Changes
 * ---------------------------------------------------------------------------------------
 */

/**
 Add a notification handler for changes in this RLMRealm.

 The block has the following definition:

     typedef void(^RLMNotificationBlock)(NSString *notification, RLMRealm *realm);

 It receives the following parameters:

 - `NSString` \***notification**:    The name of the incoming notification. See
                                     RLMRealmNotification for information on what
                                     notifications are sent.
 - `RLMRealm` \***realm**:           The realm for which this notification occurred

 @param block   A block which is called to process RLMRealm notifications.

 @return A token object which can later be passed to `-removeNotification:`
         to remove this notification.
 */
- (RLMNotificationToken *)addNotificationBlock:(RLMNotificationBlock)block;

/**
 Remove a previously registered notification handler using the token returned
 from `-addNotificationBlock:`

 @param notificationToken   The token returned from `-addNotificationBlock:`
                            corresponding to the notification block to remove.
 */
- (void)removeNotification:(RLMNotificationToken *)notificationToken;

#pragma mark - Transactions

/**---------------------------------------------------------------------------------------
 *  @name Writing to a Realm
 * ---------------------------------------------------------------------------------------
 */

/**
 Begins a write transaction in an `RLMRealm`.

 Only one write transaction can be open at a time. Write transactions cannot be
 nested, and trying to begin a write transaction on a `RLMRealm` which is
 already in a write transaction with throw an exception. Calls to
 `beginWriteTransaction` from `RLMRealm` instances in other threads will block
 until the current write transaction completes.

 Before beginning the write transaction, `beginWriteTransaction` updates the
 `RLMRealm` to the latest Realm version, as if refresh was called, and
 generates notifications if applicable. This has no effect if the `RLMRealm`
 was already up to date.

 It is rarely a good idea to have write transactions span multiple cycles of
 the run loop, but if you do wish to do so you will need to ensure that the
 `RLMRealm` in the write transaction is kept alive until the write transaction
 is committed.
 */
- (void)beginWriteTransaction;

/**
 Commits all writes operations in the current write transaction.

 After this is called the `RLMRealm` reverts back to being read-only.

 Calling this when not in a write transaction will throw an exception.
 */
- (void)commitWriteTransaction RLM_SWIFT_UNAVAILABLE("");

/**
 Commits all writes operations in the current write transaction.

 After this is called the `RLMRealm` reverts back to being read-only.

 Calling this when not in a write transaction will throw an exception.

 @param error If an error occurs, upon return contains an `NSError` object
              that describes the problem. If you are not interested in
              possible errors, pass in `NULL`.

 @return Whether the transaction succeeded.
 */
- (BOOL)commitWriteTransaction:(NSError **)error;

/**
 Revert all writes made in the current write transaction and end the transaction.

 This rolls back all objects in the Realm to the state they were in at the
 beginning of the write transaction, and then ends the transaction.

 This restores the data for deleted objects, but does not re-validated deleted
 accessor objects. Any `RLMObject`s which were added to the Realm will be
 invalidated rather than switching back to standalone objects.
 Given the following code:

     ObjectType *oldObject = [[ObjectType objectsWhere:@"..."] firstObject];
     ObjectType *newObject = [[ObjectType alloc] init];

     [realm beginWriteTransaction];
     [realm addObject:newObject];
     [realm deleteObject:oldObject];
     [realm cancelWriteTransaction];

 Both `oldObject` and `newObject` will return `YES` for `isInvalidated`,
 but re-running the query which provided `oldObject` will once again return
 the valid object.

 Calling this when not in a write transaction will throw an exception.
 */
- (void)cancelWriteTransaction;

/**
 Helper to perform a block within a transaction.
 */
- (void)transactionWithBlock:(void(^)(void))block RLM_SWIFT_UNAVAILABLE("");

/**
 Helper to perform a block within a transaction.

 @param block The block to perform.
 @param error If an error occurs, upon return contains an `NSError` object
              that describes the problem. If you are not interested in
              possible errors, pass in `NULL`.

 @return Whether the transaction succeeded.
 */
- (BOOL)transactionWithBlock:(void(^)(void))block error:(NSError **)error;

/**
 Update an `RLMRealm` and outstanding objects to point to the most recent data for this `RLMRealm`.

 @return    Whether the realm had any updates. Note that this may return YES even if no data has actually changed.
 */
- (BOOL)refresh;

/**
 Set to YES to automatically update this Realm when changes happen in other threads.

 If set to YES (the default), changes made on other threads will be reflected
 in this Realm on the next cycle of the run loop after the changes are
 committed.  If set to NO, you must manually call -refresh on the Realm to
 update it to get the latest version.

 Even with this enabled, you can still call -refresh at any time to update the
 Realm before the automatic refresh would occur.

 Notifications are sent when a write transaction is committed whether or not
 this is enabled.

 Disabling this on an `RLMRealm` without any strong references to it will not
 have any effect, and it will switch back to YES the next time the `RLMRealm`
 object is created. This is normally irrelevant as it means that there is
 nothing to refresh (as persisted `RLMObject`s, `RLMArray`s, and `RLMResults` have strong
 references to the containing `RLMRealm`), but it means that setting
 `RLMRealm.defaultRealm.autorefresh = NO` in
 `application:didFinishLaunchingWithOptions:` and only later storing Realm
 objects will not work.

 Defaults to YES.
 */
@property (nonatomic) BOOL autorefresh;

/**
 Write a compacted copy of the RLMRealm to the given path.

 The destination file cannot already exist.

 Note that if this is called from within a write transaction it writes the
 *current* data, and not data when the last write transaction was committed.

 @param path Path to save the Realm to.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return YES if the realm was copied successfully. Returns NO if an error occurred.
*/
- (BOOL)writeCopyToPath:(NSString *)path error:(NSError **)error;

/**
 Write an encrypted and compacted copy of the RLMRealm to the given path.

 The destination file cannot already exist.

 Note that if this is called from within a write transaction it writes the
 *current* data, and not data when the last write transaction was committed.

 @param path Path to save the Realm to.
 @param key 64-byte encryption key to encrypt the new file with
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return YES if the realm was copied successfully. Returns NO if an error occurred.
*/
- (BOOL)writeCopyToPath:(NSString *)path encryptionKey:(NSData *)key error:(NSError **)error;

/**
 Invalidate all RLMObjects and RLMResults read from this Realm.

 An RLMRealm holds a read lock on the version of the data accessed by it, so
 that changes made to the Realm on different threads do not modify or delete the
 data seen by this RLMRealm. Calling this method releases the read lock,
 allowing the space used on disk to be reused by later write transactions rather
 than growing the file. This method should be called before performing long
 blocking operations on a background thread on which you previously read data
 from the Realm which you no longer need.

 All `RLMObject`, `RLMResults` and `RLMArray` instances obtained from this
 `RLMRealm` on the current thread are invalidated, and can not longer be used.
 The `RLMRealm` itself remains valid, and a new read transaction is implicitly
 begun the next time data is read from the Realm.

 Calling this method multiple times in a row without reading any data from the
 Realm, or before ever reading any data from the Realm is a no-op. This method
 cannot be called on a read-only Realm.
 */
- (void)invalidate;

#pragma mark - Accessing Objects

/**---------------------------------------------------------------------------------------
 *  @name Adding and Removing Objects from a Realm
 * ---------------------------------------------------------------------------------------
 */
/**
 Adds an object to be persisted it in this Realm.

 Once added, this object can be retrieved using the `objectsWhere:` selectors
 on `RLMRealm` and on subclasses of `RLMObject`. When added, all linked (child)
 objects referenced by this object will also be added to the Realm if they are
 not already in it. If the object or any linked objects already belong to a
 different Realm an exception will be thrown. Use
 `-[RLMObject createInRealm:withObject]` to insert a copy of a persisted object
 into a different Realm.

 The object to be added must be valid and cannot have been previously deleted
 from a Realm (i.e. `isInvalidated`) must be false.

 @param object  Object to be added to this Realm.
 */
- (void)addObject:(RLMObject *)object;

/**
 Adds objects in the given array to be persisted it in this Realm.

 This is the equivalent of `addObject:` except for an array of objects.

 @param array   An enumerable object such as NSArray or RLMResults which contains objects to be added to
                this Realm.

 @see   addObject:
 */
- (void)addObjects:(id<NSFastEnumeration>)array;

/**
 Adds or updates an object to be persisted it in this Realm. The object provided must have a designated
 primary key. If no objects exist in the RLMRealm instance with the same primary key value, the object is
 inserted. Otherwise, the existing object is updated with any changed values.

 As with `addObject:`, the object cannot already be persisted in a different
 Realm. Use `-[RLMObject createOrUpdateInRealm:withValue:]` to copy values to
 a different Realm.

 @param object  Object to be added or updated.
 */
- (void)addOrUpdateObject:(RLMObject *)object;

/**
 Adds or updates objects in the given array to be persisted it in this Realm.

 This is the equivalent of `addOrUpdateObject:` except for an array of objects.

 @param array  `NSArray`, `RLMArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be added to this Realm.

 @see   addOrUpdateObject:
 */
- (void)addOrUpdateObjectsFromArray:(id)array;

/**
 Delete an object from this Realm.

 @param object  Object to be deleted from this Realm.
 */
- (void)deleteObject:(RLMObject *)object;

/**
 Delete an `NSArray`, `RLMArray`, or `RLMResults` of objects from this Realm.

 @param array  `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s to be deleted.
 */
- (void)deleteObjects:(id)array;

/**
 Deletes all objects in this Realm.
 */
- (void)deleteAllObjects;


#pragma mark - Migrations

/**
 Migration block used to migrate a Realm.

 @param migration   `RLMMigration` object used to perform the migration. The
                    migration object allows you to enumerate and alter any
                    existing objects which require migration.

 @param oldSchemaVersion    The schema version of the `RLMRealm` being migrated.
 */
typedef void (^RLMMigrationBlock)(RLMMigration *migration, uint64_t oldSchemaVersion);

/**
 Specify a schema version and an associated migration block which is applied when
 opening the default Realm with an old schema version.

 Before you can open an existing `RLMRealm` which has a different on-disk schema
 from the schema defined in your object interfaces you must provide a migration 
 block which converts from the disk schema to your current object schema. At the
 minimum your migration block must initialize any properties which were added to
 existing objects without defaults and ensure uniqueness if a primary key
 property is added to an existing object.

 You should call this method before accessing any `RLMRealm` instances which
 require migration. After registering your migration block Realm will call your 
 block automatically as needed.

 @warning Unsuccessful migrations will throw exceptions when the migration block
 is applied. This will happen in the following cases:

 - The migration block was run and returns a schema version which is not higher
   than the previous schema version.
 - A new property without a default was added to an object and not initialized
   during the migration. You are required to either supply a default value or to
   manually populate added properties during a migration.

 @param version     The current schema version.
 @param block       The block which migrates the Realm to the current version.

 @see               RLMMigration
 */
+ (void)setDefaultRealmSchemaVersion:(uint64_t)version withMigrationBlock:(nullable RLMMigrationBlock)block DEPRECATED_MSG_ATTRIBUTE("Use RLMRealmConfiguration.schemaVersion and RLMRealmConfiguration.migrationBlock");

/**
 Specify a schema version and an associated migration block which is applied when
 opening the Realm at realmPath with an old schema version.

 @param version     The current schema version.
 @param realmPath   The path at which this schema version and migration block is applied.
 @param block       The block which migrates the Realm to the current version.

 @see               RLMMigration
 */
+ (void)setSchemaVersion:(uint64_t)version forRealmAtPath:(NSString *)realmPath withMigrationBlock:(nullable RLMMigrationBlock)block DEPRECATED_MSG_ATTRIBUTE("Use RLMRealmConfiguration.schemaVersion and RLMRealmConfiguration.migrationBlock");

/**
 Get the schema version for a Realm at a given path.

 @param realmPath   Path to a Realm file
 @param error       If an error occurs, upon return contains an `NSError` object
                    that describes the problem. If you are not interested in
                    possible errors, pass in `NULL`.

 @return            The version of the Realm at `realmPath` or RLMNotVersioned if the version cannot be read.
 */
+ (uint64_t)schemaVersionAtPath:(NSString *)realmPath error:(NSError **)error;

/**
 Get the schema version for an encrypted Realm at a given path.

 @param realmPath   Path to a Realm file
 @param key         64-byte encryption key.
 @param error       If an error occurs, upon return contains an `NSError` object
                    that describes the problem. If you are not interested in
                    possible errors, pass in `NULL`.

 @return            The version of the Realm at `realmPath` or RLMNotVersioned if the version cannot be read.
 */
+ (uint64_t)schemaVersionAtPath:(NSString *)realmPath encryptionKey:(nullable NSData *)key error:(NSError **)error;

/**
 Performs the given Realm configuration's migration block on a Realm at the given path.

 This method is called automatically when opening a Realm for the first time and does
 not need to be called explicitly. You can choose to call this method to control
 exactly when and how migrations are performed.

 @param configuration The Realm configuration used to open and migrate the Realm.
 @return              The error that occurred while applying the migration, if any.

 @see                 RLMMigration
 */
+ (NSError *)migrateRealm:(RLMRealmConfiguration *)configuration;

/**
 Performs the registered migration block on a Realm at the given path.

 This method is called automatically when opening a Realm for the first time and does
 not need to be called explicitly. You can choose to call this method to control 
 exactly when and how migrations are performed.

 @param realmPath   The path of the Realm to migrate.
 @return            The error that occurred while applying the migration if any.

 @see               RLMMigration
 @see               setSchemaVersion:forRealmAtPath:withMigrationBlock:
 */
+ (NSError *)migrateRealmAtPath:(NSString *)realmPath DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealm migrateRealm:]");

/**
 Performs the registered migration block on an encrypted Realm at the given path.

 As `migrateRealmAtPath:`, but for encrypted realms.

 @param realmPath   The path of the Realm to migrate.
 @param key         64-byte encryption key.
 @return            The error that occurred while applying the migration, if any.
 */
+ (NSError *)migrateRealmAtPath:(NSString *)realmPath encryptionKey:(NSData *)key DEPRECATED_MSG_ATTRIBUTE("Use +[RLMRealm migrateRealm:]");

#pragma mark -

//---------------------------------------------------------------------------------------
//@name Named Object Storage and Retrieval
//---------------------------------------------------------------------------------------
//
// Realm provides a top level key/value store for storing and accessing objects by NSString.
// This system can be extended with the RLMKeyValueStore interface to create nested
// namespaces as needed.

// Retrieve a persisted object with an NSString.
//
// @usage RLMObject *object = RLMRealm.defaultRealm[@"name"];
// @param key The NSString used to identify an object
//
// @return    RLMObject or nil if no object is stored for the given key.
//
//-(id)objectForKeyedSubscript:(id <NSCopying>)key;


// Store an object with an NSString key.
//
// @usage RLMRealm.defaultRealm[@"name"] = object;
// @param obj     The object to be stored.
// @param key     The key that identifies the object to be used for future lookups.
//
//-(void)setObject:(RLMObject *)obj forKeyedSubscript:(id <NSCopying>)key;


@end

//
// Notification token - holds onto the realm and the notification block
//
@interface RLMNotificationToken : NSObject
@end

RLM_ASSUME_NONNULL_END
