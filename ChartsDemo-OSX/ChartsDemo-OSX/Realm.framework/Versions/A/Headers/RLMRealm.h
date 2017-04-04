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
#import "RLMConstants.h"

@class RLMRealmConfiguration, RLMObject, RLMSchema, RLMMigration, RLMNotificationToken, RLMThreadSafeReference;

NS_ASSUME_NONNULL_BEGIN

/**
 An `RLMRealm` instance (also referred to as "a Realm") represents a Realm
 database.

 Realms can either be stored on disk (see `+[RLMRealm realmWithURL:]`) or in
 memory (see `RLMRealmConfiguration`).

 `RLMRealm` instances are cached internally, and constructing equivalent `RLMRealm`
 objects (for example, by using the same path or identifier) multiple times on a single thread
 within a single iteration of the run loop will normally return the same
 `RLMRealm` object.

 If you specifically want to ensure an `RLMRealm` instance is
 destroyed (for example, if you wish to open a Realm, check some property, and
 then possibly delete the Realm file and re-open it), place the code which uses
 the Realm within an `@autoreleasepool {}` and ensure you have no other
 strong references to it.

 @warning `RLMRealm` instances are not thread safe and cannot be shared across
 threads or dispatch queues. Trying to do so will cause an exception to be thrown.
 You must call this method on each thread you want
 to interact with the Realm on. For dispatch queues, this means that you must
 call it in each block which is dispatched, as a queue is not guaranteed to run
 all of its blocks on the same thread.
 */

@interface RLMRealm : NSObject

#pragma mark - Creating & Initializing a Realm

/**
 Obtains an instance of the default Realm.

 The default Realm is used by the `RLMObject` class methods
 which do not take an `RLMRealm` parameter, but is otherwise not special. The
 default Realm is persisted as *default.realm* under the *Documents* directory of
 your Application on iOS, and in your application's *Application Support*
 directory on OS X.

 The default Realm is created using the default `RLMRealmConfiguration`, which
 can be changed via `+[RLMRealmConfiguration setDefaultConfiguration:]`.

 @return The default `RLMRealm` instance for the current thread.
 */
+ (instancetype)defaultRealm;

/**
 Obtains an `RLMRealm` instance with the given configuration.

 @param configuration A configuration object to use when creating the Realm.
 @param error         If an error occurs, upon return contains an `NSError` object
                      that describes the problem. If you are not interested in
                      possible errors, pass in `NULL`.

 @return An `RLMRealm` instance.
 */
+ (nullable instancetype)realmWithConfiguration:(RLMRealmConfiguration *)configuration error:(NSError **)error;

/**
 Obtains an `RLMRealm` instance persisted at a specified file URL.

 @param fileURL The local URL of the file the Realm should be saved at.

 @return An `RLMRealm` instance.
 */
+ (instancetype)realmWithURL:(NSURL *)fileURL;

/**
 The `RLMSchema` used by the Realm.
 */
@property (nonatomic, readonly) RLMSchema *schema;

/**
 Indicates if the Realm is currently engaged in a write transaction.

 @warning   Do not simply check this property and then start a write transaction whenever an object needs to be
            created, updated, or removed. Doing so might cause a large number of write transactions to be created,
            degrading performance. Instead, always prefer performing multiple updates during a single transaction.
 */
@property (nonatomic, readonly) BOOL inWriteTransaction;

/**
 The `RLMRealmConfiguration` object that was used to create this `RLMRealm` instance.
 */
@property (nonatomic, readonly) RLMRealmConfiguration *configuration;

/**
 Indicates if this Realm contains any objects.
 */
@property (nonatomic, readonly) BOOL isEmpty;

#pragma mark - Notifications

/**
 The type of a block to run whenever the data within the Realm is modified.

 @see `-[RLMRealm addNotificationBlock:]`
 */
typedef void (^RLMNotificationBlock)(RLMNotification notification, RLMRealm *realm);

#pragma mark - Receiving Notification when a Realm Changes

/**
 Adds a notification handler for changes in this Realm, and returns a notification token.

 Notification handlers are called after each write transaction is committed,
 either on the current thread or other threads.

 Handler blocks are called on the same thread that they were added on, and may
 only be added on threads which are currently within a run loop. Unless you are
 specifically creating and running a run loop on a background thread, this will
 normally only be the main thread.

 The block has the following definition:

     typedef void(^RLMNotificationBlock)(RLMNotification notification, RLMRealm *realm);

 It receives the following parameters:

 - `NSString` \***notification**:    The name of the incoming notification. See
                                     `RLMRealmNotification` for information on what
                                     notifications are sent.
 - `RLMRealm` \***realm**:           The Realm for which this notification occurred.

 @param block   A block which is called to process Realm notifications.

 @return A token object which must be retained as long as you wish to continue
         receiving change notifications.
 */
- (RLMNotificationToken *)addNotificationBlock:(RLMNotificationBlock)block __attribute__((warn_unused_result));

#pragma mark - Transactions


#pragma mark - Writing to a Realm

/**
 Begins a write transaction on the Realm.

 Only one write transaction can be open at a time for each Realm file. Write
 transactions cannot be nested, and trying to begin a write transaction on a
 Realm which is already in a write transaction will throw an exception. Calls to
 `beginWriteTransaction` from `RLMRealm` instances for the same Realm file in
 other threads or other processes will block until the current write transaction
 completes or is cancelled.

 Before beginning the write transaction, `beginWriteTransaction` updates the
 `RLMRealm` instance to the latest Realm version, as if `refresh` had been
 called, and generates notifications if applicable. This has no effect if the
 Realm was already up to date.

 It is rarely a good idea to have write transactions span multiple cycles of
 the run loop, but if you do wish to do so you will need to ensure that the
 Realm participating in the write transaction is kept alive until the write
 transaction is committed.
 */
- (void)beginWriteTransaction;

/**
 Commits all write operations in the current write transaction, and ends the
 transaction.

 After saving the changes, all notification blocks registered on this specific
 `RLMRealm` instance are invoked synchronously. Notification blocks registered
 on other threads or on collections are invoked asynchronously. If you do not
 want to receive a specific notification for this write tranaction, see
 `commitWriteTransactionWithoutNotifying:error:`.

 This method can fail if there is insufficient disk space available to save the
 writes made, or due to unexpected i/o errors. This version of the method throws
 an exception when errors occur. Use the version with a `NSError` out parameter
 instead if you wish to handle errors.

 @warning This method may only be called during a write transaction.
 */
- (void)commitWriteTransaction NS_SWIFT_UNAVAILABLE("");

/**
 Commits all write operations in the current write transaction, and ends the
 transaction.

 After saving the changes, all notification blocks registered on this specific
 `RLMRealm` instance are invoked synchronously. Notification blocks registered
 on other threads or on collections are invoked asynchronously. If you do not
 want to receive a specific notification for this write tranaction, see
 `commitWriteTransactionWithoutNotifying:error:`.

 This method can fail if there is insufficient disk space available to save the
 writes made, or due to unexpected i/o errors.

 @warning This method may only be called during a write transaction.

 @param error If an error occurs, upon return contains an `NSError` object
              that describes the problem. If you are not interested in
              possible errors, pass in `NULL`.

 @return Whether the transaction succeeded.
 */
- (BOOL)commitWriteTransaction:(NSError **)error;

/**
 Commits all write operations in the current write transaction, without
 notifying specific notification blocks of the changes.

 After saving the changes, all notification blocks registered on this specific
 `RLMRealm` instance are invoked synchronously. Notification blocks registered
 on other threads or on collections are scheduled to be invoked asynchronously.

 You can skip notifiying specific notification blocks about the changes made
 in this write transaction by passing in their associated notification tokens.
 This is primarily useful when the write transaction is saving changes already
 made in the UI and you do not want to have the notification block attempt to
 re-apply the same changes.

 The tokens passed to this method must be for notifications for this specific
 `RLMRealm` instance. Notifications for different threads cannot be skipped
 using this method.

 This method can fail if there is insufficient disk space available to save the
 writes made, or due to unexpected i/o errors.

 @warning This method may only be called during a write transaction.

 @param tokens An array of notification tokens which were returned from adding
               callbacks which you do not want to be notified for the changes
               made in this write transaction.
 @param error If an error occurs, upon return contains an `NSError` object
              that describes the problem. If you are not interested in
              possible errors, pass in `NULL`.

 @return Whether the transaction succeeded.
 */
- (BOOL)commitWriteTransactionWithoutNotifying:(NSArray<RLMNotificationToken *> *)tokens error:(NSError **)error;

/**
 Reverts all writes made during the current write transaction and ends the transaction.

 This rolls back all objects in the Realm to the state they were in at the
 beginning of the write transaction, and then ends the transaction.

 This restores the data for deleted objects, but does not revive invalidated
 object instances. Any `RLMObject`s which were added to the Realm will be
 invalidated rather than becoming unmanaged.
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

 KVO observers on any objects which were modified during the transaction will
 be notified about the change back to their initial values, but no other
 notifcations are produced by a cancelled write transaction.

 @warning This method may only be called during a write transaction.
 */
- (void)cancelWriteTransaction;

/**
 Performs actions contained within the given block inside a write transaction.

 @see `[RLMRealm transactionWithBlock:error:]`
 */
- (void)transactionWithBlock:(__attribute__((noescape)) void(^)(void))block NS_SWIFT_UNAVAILABLE("");

/**
 Performs actions contained within the given block inside a write transaction.

 Write transactions cannot be nested, and trying to execute a write transaction
 on a Realm which is already participating in a write transaction will throw an
 exception. Calls to `transactionWithBlock:` from `RLMRealm` instances in other
 threads will block until the current write transaction completes.

 Before beginning the write transaction, `transactionWithBlock:` updates the
 `RLMRealm` instance to the latest Realm version, as if `refresh` had been called, and
 generates notifications if applicable. This has no effect if the Realm
 was already up to date.

 @param block The block containing actions to perform.
 @param error If an error occurs, upon return contains an `NSError` object
              that describes the problem. If you are not interested in
              possible errors, pass in `NULL`.

 @return Whether the transaction succeeded.
 */
- (BOOL)transactionWithBlock:(__attribute__((noescape)) void(^)(void))block error:(NSError **)error;

/**
 Updates the Realm and outstanding objects managed by the Realm to point to the
 most recent data.

 If the version of the Realm is actually changed, Realm and collection
 notifications will be sent to reflect the changes. This may take some time, as
 collection notifications are prepared on a background thread. As a result,
 calling this method on the main thread is not advisable.

 @return Whether there were any updates for the Realm. Note that `YES` may be
         returned even if no data actually changed.
 */
- (BOOL)refresh;

/**
 Set this property to `YES` to automatically update this Realm when changes
 happen in other threads.

 If set to `YES` (the default), changes made on other threads will be reflected
 in this Realm on the next cycle of the run loop after the changes are
 committed.  If set to `NO`, you must manually call `-refresh` on the Realm to
 update it to get the latest data.

 Note that by default, background threads do not have an active run loop and you
 will need to manually call `-refresh` in order to update to the latest version,
 even if `autorefresh` is set to `YES`.

 Even with this property enabled, you can still call `-refresh` at any time to
 update the Realm before the automatic refresh would occur.

 Write transactions will still always advance a Realm to the latest version and
 produce local notifications on commit even if autorefresh is disabled.

 Disabling `autorefresh` on a Realm without any strong references to it will not
 have any effect, and `autorefresh` will revert back to `YES` the next time the
 Realm is created. This is normally irrelevant as it means that there is nothing
 to refresh (as managed `RLMObject`s, `RLMArray`s, and `RLMResults` have strong
 references to the Realm that manages them), but it means that setting
 `RLMRealm.defaultRealm.autorefresh = NO` in
 `application:didFinishLaunchingWithOptions:` and only later storing Realm
 objects will not work.

 Defaults to `YES`.
 */
@property (nonatomic) BOOL autorefresh;

/**
 Writes a compacted and optionally encrypted copy of the Realm to the given local URL.

 The destination file cannot already exist.

 Note that if this method is called from within a write transaction, the
 *current* data is written, not the data from the point when the previous write
 transaction was committed.

 @param fileURL Local URL to save the Realm to.
 @param key     Optional 64-byte encryption key to encrypt the new file with.
 @param error   If an error occurs, upon return contains an `NSError` object
                that describes the problem. If you are not interested in
                possible errors, pass in `NULL`.

 @return `YES` if the Realm was successfully written to disk, `NO` if an error occurred.
*/
- (BOOL)writeCopyToURL:(NSURL *)fileURL encryptionKey:(nullable NSData *)key error:(NSError **)error;

/**
 Invalidates all `RLMObject`s, `RLMResults`, `RLMLinkingObjects`, and `RLMArray`s managed by the Realm.

 A Realm holds a read lock on the version of the data accessed by it, so
 that changes made to the Realm on different threads do not modify or delete the
 data seen by this Realm. Calling this method releases the read lock,
 allowing the space used on disk to be reused by later write transactions rather
 than growing the file. This method should be called before performing long
 blocking operations on a background thread on which you previously read data
 from the Realm which you no longer need.

 All `RLMObject`, `RLMResults` and `RLMArray` instances obtained from this
 `RLMRealm` instance on the current thread are invalidated. `RLMObject`s and `RLMArray`s
 cannot be used. `RLMResults` will become empty. The Realm itself remains valid,
 and a new read transaction is implicitly begun the next time data is read from the Realm.

 Calling this method multiple times in a row without reading any data from the
 Realm, or before ever reading any data from the Realm, is a no-op. This method
 may not be called on a read-only Realm.
 */
- (void)invalidate;

#pragma mark - Accessing Objects

/**
 Returns the same object as the one referenced when the `RLMThreadSafeReference` was first created,
 but resolved for the current Realm for this thread. Returns `nil` if this object was deleted after
 the reference was created.

 @param reference The thread-safe reference to the thread-confined object to resolve in this Realm.

 @warning A `RLMThreadSafeReference` object must be resolved at most once.
          Failing to resolve a `RLMThreadSafeReference` will result in the source version of the
          Realm being pinned until the reference is deallocated.
          An exception will be thrown if a reference is resolved more than once.

 @warning Cannot call within a write transaction.

 @note Will refresh this Realm if the source Realm was at a later version than this one.

 @see `+[RLMThreadSafeReference referenceWithThreadConfined:]`
 */
- (nullable id)resolveThreadSafeReference:(RLMThreadSafeReference *)reference
NS_REFINED_FOR_SWIFT;

#pragma mark - Adding and Removing Objects from a Realm

/**
 Adds an object to the Realm.

 Once added, this object is considered to be managed by the Realm. It can be retrieved
 using the `objectsWhere:` selectors on `RLMRealm` and on subclasses of `RLMObject`.

 When added, all child relationships referenced by this object will also be added to
 the Realm if they are not already in it.

 If the object or any related objects are already being managed by a different Realm
 an exception will be thrown. Use `-[RLMObject createInRealm:withObject:]` to insert a copy of a managed object
 into a different Realm.

 The object to be added must be valid and cannot have been previously deleted
 from a Realm (i.e. `isInvalidated` must be `NO`).

 @warning This method may only be called during a write transaction.

 @param object  The object to be added to this Realm.
 */
- (void)addObject:(RLMObject *)object;

/**
 Adds all the objects in a collection to the Realm.

 This is the equivalent of calling `addObject:` for every object in a collection.

 @warning This method may only be called during a write transaction.

 @param array   An enumerable object such as `NSArray` or `RLMResults` which contains objects to be added to
                the Realm.

 @see   `addObject:`
 */
- (void)addObjects:(id<NSFastEnumeration>)array;

/**
 Adds or updates an existing object into the Realm.

 The object provided must have a designated primary key. If no objects exist in the Realm
 with the same primary key value, the object is inserted. Otherwise, the existing object is
 updated with any changed values.

 As with `addObject:`, the object cannot already be managed by a different
 Realm. Use `-[RLMObject createOrUpdateInRealm:withValue:]` to copy values to
 a different Realm.

 @warning This method may only be called during a write transaction.

 @param object  The object to be added or updated.
 */
- (void)addOrUpdateObject:(RLMObject *)object;

/**
 Adds or updates all the objects in a collection into the Realm.

 This is the equivalent of calling `addOrUpdateObject:` for every object in a collection.

 @warning This method may only be called during a write transaction.

 @param array  An `NSArray`, `RLMArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be added to the Realm.

 @see   `addOrUpdateObject:`
 */
- (void)addOrUpdateObjectsFromArray:(id)array;

/**
 Deletes an object from the Realm. Once the object is deleted it is considered invalidated.

 @warning This method may only be called during a write transaction.

 @param object  The object to be deleted.
 */
- (void)deleteObject:(RLMObject *)object;

/**
 Deletes one or more objects from the Realm.

 This is the equivalent of calling `deleteObject:` for every object in a collection.

 @warning This method may only be called during a write transaction.

 @param array  An `RLMArray`, `NSArray`, or `RLMResults` of `RLMObject`s (or subclasses) to be deleted.

 @see `deleteObject:`
 */
- (void)deleteObjects:(id)array;

/**
 Deletes all objects from the Realm.

 @warning This method may only be called during a write transaction.

 @see `deleteObject:`
 */
- (void)deleteAllObjects;


#pragma mark - Migrations

/**
 The type of a migration block used to migrate a Realm.

 @param migration   A `RLMMigration` object used to perform the migration. The
                    migration object allows you to enumerate and alter any
                    existing objects which require migration.

 @param oldSchemaVersion    The schema version of the Realm being migrated.
 */
typedef void (^RLMMigrationBlock)(RLMMigration *migration, uint64_t oldSchemaVersion);

/**
 Returns the schema version for a Realm at a given local URL.

 @param fileURL Local URL to a Realm file.
 @param key     64-byte key used to encrypt the file, or `nil` if it is unencrypted.
 @param error   If an error occurs, upon return contains an `NSError` object
                that describes the problem. If you are not interested in
                possible errors, pass in `NULL`.

 @return The version of the Realm at `fileURL`, or `RLMNotVersioned` if the version cannot be read.
 */
+ (uint64_t)schemaVersionAtURL:(NSURL *)fileURL encryptionKey:(nullable NSData *)key error:(NSError **)error
NS_REFINED_FOR_SWIFT;

/**
 Performs the given Realm configuration's migration block on a Realm at the given path.

 This method is called automatically when opening a Realm for the first time and does
 not need to be called explicitly. You can choose to call this method to control
 exactly when and how migrations are performed.

 @param configuration The Realm configuration used to open and migrate the Realm.
 @return              The error that occurred while applying the migration, if any.

 @see                 RLMMigration
 */
+ (nullable NSError *)migrateRealm:(RLMRealmConfiguration *)configuration
__deprecated_msg("Use `performMigrationForConfiguration:error:`") NS_REFINED_FOR_SWIFT;

/**
 Performs the given Realm configuration's migration block on a Realm at the given path.

 This method is called automatically when opening a Realm for the first time and does
 not need to be called explicitly. You can choose to call this method to control
 exactly when and how migrations are performed.

 @param configuration The Realm configuration used to open and migrate the Realm.
 @return              The error that occurred while applying the migration, if any.

 @see                 RLMMigration
 */
+ (BOOL)performMigrationForConfiguration:(RLMRealmConfiguration *)configuration error:(NSError **)error;

#pragma mark - Unavailable Methods

/**
 RLMRealm instances are cached internally by Realm and cannot be created directly.

 Use `+[RLMRealm defaultRealm]`, `+[RLMRealm realmWithConfiguration:error:]` or
 `+[RLMRealm realmWithURL]` to obtain a reference to an RLMRealm.
 */
- (instancetype)init __attribute__((unavailable("Use +defaultRealm, +realmWithConfiguration: or +realmWithURL:.")));

/**
 RLMRealm instances are cached internally by Realm and cannot be created directly.

 Use `+[RLMRealm defaultRealm]`, `+[RLMRealm realmWithConfiguration:error:]` or
 `+[RLMRealm realmWithURL]` to obtain a reference to an RLMRealm.
 */
+ (instancetype)new __attribute__((unavailable("Use +defaultRealm, +realmWithConfiguration: or +realmWithURL:.")));

@end

/**
 A token which is returned from methods which subscribe to changes to a Realm.

 Change subscriptions in Realm return an `RLMNotificationToken` instance,
 which can be used to unsubscribe from the changes. You must store a strong
 reference to the token for as long as you want to continue to receive notifications.
 When you wish to stop, call the `-stop` method. Notifications are also stopped if
 the token is deallocated.
 */
@interface RLMNotificationToken : NSObject
/// Stops notifications for the change subscription that returned this token.
- (void)stop;
@end

NS_ASSUME_NONNULL_END
