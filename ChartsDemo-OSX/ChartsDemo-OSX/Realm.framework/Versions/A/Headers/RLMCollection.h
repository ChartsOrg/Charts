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

#import "RLMThreadSafeReference.h"

NS_ASSUME_NONNULL_BEGIN

@class RLMRealm, RLMResults, RLMObject, RLMSortDescriptor, RLMNotificationToken, RLMCollectionChange;

/**
 A homogenous collection of `RLMObject` instances. Examples of conforming types include `RLMArray`,
 `RLMResults`, and `RLMLinkingObjects`.
 */
@protocol RLMCollection <NSFastEnumeration, RLMThreadConfined>

@required

#pragma mark - Properties

/**
 The number of objects in the collection.
 */
@property (nonatomic, readonly, assign) NSUInteger count;

/**
 The class name (i.e. type) of the `RLMObject`s contained in the collection.
 */
@property (nonatomic, readonly, copy) NSString *objectClassName;

/**
 The Realm which manages the collection, or `nil` for unmanaged collections.
 */
@property (nonatomic, readonly) RLMRealm *realm;

#pragma mark - Accessing Objects from a Collection

/**
 Returns the object at the index specified.

 @param index   The index to look up.

 @return An `RLMObject` of the type contained in the collection.
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 Returns the first object in the collection.

 Returns `nil` if called on an empty collection.

 @return An `RLMObject` of the type contained in the collection.
 */
- (nullable id)firstObject;

/**
 Returns the last object in the collection.

 Returns `nil` if called on an empty collection.

 @return An `RLMObject` of the type contained in the collection.
 */
- (nullable id)lastObject;

#pragma mark - Querying a Collection

/**
 Returns the index of an object in the collection.

 Returns `NSNotFound` if the object is not found in the collection.

 @param object  An object (of the same type as returned from the `objectClassName` selector).
 */
- (NSUInteger)indexOfObject:(RLMObject *)object;

/**
 Returns the index of the first object in the collection matching the predicate.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.

 @return    The index of the object, or `NSNotFound` if the object is not found in the collection.
 */
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns the index of the first object in the collection matching the predicate.

 @param predicate   The predicate with which to filter the objects.

 @return    The index of the object, or `NSNotFound` if the object is not found in the collection.
 */
- (NSUInteger)indexOfObjectWithPredicate:(NSPredicate *)predicate;

/**
 Returns all objects matching the given predicate in the collection.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.

 @return    An `RLMResults` containing objects that match the given predicate.
 */
- (RLMResults *)objectsWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (RLMResults *)objectsWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns all objects matching the given predicate in the collection.

 @param predicate   The predicate with which to filter the objects.

 @return            An `RLMResults` containing objects that match the given predicate.
 */
- (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate;

/**
 Returns a sorted `RLMResults` from the collection.

 @param keyPath     The keyPath to sort by.
 @param ascending   The direction to sort in.

 @return    An `RLMResults` sorted by the specified key path.
 */
- (RLMResults *)sortedResultsUsingKeyPath:(NSString *)keyPath ascending:(BOOL)ascending;

/**
 Returns a sorted `RLMResults` from the collection.

 @param property    The property name to sort by.
 @param ascending   The direction to sort in.

 @return    An `RLMResults` sorted by the specified property.
 */
- (RLMResults *)sortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending
    __deprecated_msg("Use `-sortedResultsUsingKeyPath:ascending:`");

/**
 Returns a sorted `RLMResults` from the collection.

 @param properties  An array of `RLMSortDescriptor`s to sort by.

 @return    An `RLMResults` sorted by the specified properties.
 */
- (RLMResults *)sortedResultsUsingDescriptors:(NSArray<RLMSortDescriptor *> *)properties;

/// :nodoc:
- (id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Returns an `NSArray` containing the results of invoking `valueForKey:` using `key` on each of the collection's objects.

 @param key The name of the property.

 @return An `NSArray` containing results.
 */
- (nullable id)valueForKey:(NSString *)key;

/**
 Invokes `setValue:forKey:` on each of the collection's objects using the specified `value` and `key`.

 @warning This method may only be called during a write transaction.

 @param value The object value.
 @param key   The name of the property.
 */
- (void)setValue:(nullable id)value forKey:(NSString *)key;

#pragma mark - Notifications

/**
 Registers a block to be called each time the collection changes.

 The block will be asynchronously called with the initial collection, and then
 called again after each write transaction which changes either any of the
 objects in the collection, or which objects are in the collection.

 The `change` parameter will be `nil` the first time the block is called.
 For each call after that, it will contain information about
 which rows in the collection were added, removed or modified. If a write transaction
 did not modify any objects in this collection, the block is not called at all.
 See the `RLMCollectionChange` documentation for information on how the changes
 are reported and an example of updating a `UITableView`.

 If an error occurs the block will be called with `nil` for the collection
 parameter and a non-`nil` error. Currently the only errors that can occur are
 when opening the Realm on the background worker thread.

 At the time when the block is called, the collection object will be fully
 evaluated and up-to-date, and as long as you do not perform a write transaction
 on the same thread or explicitly call `-[RLMRealm refresh]`, accessing it will
 never perform blocking work.

 Notifications are delivered via the standard run loop, and so can't be
 delivered while the run loop is blocked by other activity. When
 notifications can't be delivered instantly, multiple notifications may be
 coalesced into a single notification. This can include the notification
 with the initial collection. For example, the following code performs a write
 transaction immediately after adding the notification block, so there is no
 opportunity for the initial notification to be delivered first. As a
 result, the initial notification will reflect the state of the Realm after
 the write transaction.

     id<RLMCollection> collection = [Dog allObjects];
     NSLog(@"dogs.count: %zu", dogs.count); // => 0
     self.token = [collection addNotificationBlock:^(id<RLMCollection> dogs,
                                                  RLMCollectionChange *changes,
                                                  NSError *error) {
         // Only fired once for the example
         NSLog(@"dogs.count: %zu", dogs.count); // => 1
     }];
     [realm transactionWithBlock:^{
         Dog *dog = [[Dog alloc] init];
         dog.name = @"Rex";
         [realm addObject:dog];
     }];
     // end of run loop execution context

 You must retain the returned token for as long as you want updates to continue
 to be sent to the block. To stop receiving updates, call `-stop` on the token.

 @warning This method cannot be called during a write transaction, or when the
          containing Realm is read-only.

 @param block The block to be called each time the collection changes.
 @return A token which must be held for as long as you want collection notifications to be delivered.
 */
- (RLMNotificationToken *)addNotificationBlock:(void (^)(id<RLMCollection> __nullable collection,
                                                         RLMCollectionChange *__nullable change,
                                                         NSError *__nullable error))block __attribute__((warn_unused_result));

@end

/**
 An `RLMSortDescriptor` stores a property name and a sort order for use with
 `sortedResultsUsingDescriptors:`. It is similar to `NSSortDescriptor`, but supports
 only the subset of functionality which can be efficiently run by Realm's query
 engine.
 
 `RLMSortDescriptor` instances are immutable.
 */
@interface RLMSortDescriptor : NSObject

#pragma mark - Properties

/**
 The key path which the sort descriptor orders results by.
 */
@property (nonatomic, readonly) NSString *keyPath;

/**
 Whether the descriptor sorts in ascending or descending order.
 */
@property (nonatomic, readonly) BOOL ascending;

#pragma mark - Methods

/**
 Returns a new sort descriptor for the given key path and sort direction.
 */
+ (instancetype)sortDescriptorWithKeyPath:(NSString *)keyPath ascending:(BOOL)ascending;

/**
 Returns a copy of the receiver with the sort direction reversed.
 */
- (instancetype)reversedSortDescriptor;

#pragma mark - Deprecated

/**
 The name of the property which the sort descriptor orders results by.
 */
@property (nonatomic, readonly) NSString *property __deprecated_msg("Use `-keyPath`");

/**
 Returns a new sort descriptor for the given property name and sort direction.
 */
+ (instancetype)sortDescriptorWithProperty:(NSString *)propertyName ascending:(BOOL)ascending
    __deprecated_msg("Use `+sortDescriptorWithKeyPath:ascending:`");

@end

/**
 A `RLMCollectionChange` object encapsulates information about changes to collections
 that are reported by Realm notifications.

 `RLMCollectionChange` is passed to the notification blocks registered with
 `-addNotificationBlock` on `RLMArray` and `RLMResults`, and reports what rows in the
 collection changed since the last time the notification block was called.

 The change information is available in two formats: a simple array of row
 indices in the collection for each type of change, and an array of index paths
 in a requested section suitable for passing directly to `UITableView`'s batch
 update methods. A complete example of updating a `UITableView` named `tv`:

     [tv beginUpdates];
     [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
     [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
     [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
     [tv endUpdates];

 All of the arrays in an `RLMCollectionChange` are always sorted in ascending order.
 */
@interface RLMCollectionChange : NSObject
/// The indices of objects in the previous version of the collection which have
/// been removed from this one.
@property (nonatomic, readonly) NSArray<NSNumber *> *deletions;

/// The indices in the new version of the collection which were newly inserted.
@property (nonatomic, readonly) NSArray<NSNumber *> *insertions;

/**
 The indices in the new version of the collection which were modified.
 
 For `RLMResults`, this means that one or more of the properties of the object at
 that index were modified (or an object linked to by that object was
 modified).
 
 For `RLMArray`, the array itself being modified to contain a
 different object at that index will also be reported as a modification.
 */
@property (nonatomic, readonly) NSArray<NSNumber *> *modifications;

/// Returns the index paths of the deletion indices in the given section.
- (NSArray<NSIndexPath *> *)deletionsInSection:(NSUInteger)section;

/// Returns the index paths of the insertion indices in the given section.
- (NSArray<NSIndexPath *> *)insertionsInSection:(NSUInteger)section;

/// Returns the index paths of the modification indices in the given section.
- (NSArray<NSIndexPath *> *)modificationsInSection:(NSUInteger)section;
@end

NS_ASSUME_NONNULL_END
