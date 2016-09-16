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
#import <Realm/RLMCollection.h>

NS_ASSUME_NONNULL_BEGIN

@class RLMObject, RLMRealm, RLMNotificationToken;

/**
 `RLMResults` is an auto-updating container type in Realm returned from object
 queries. It represents the results of the query in the form of a collection of objects.

 `RLMResults` can be queried using the same predicates as `RLMObject` and `RLMArray`,
 and you can chain queries to further filter results.

 `RLMResults` always reflect the current state of the Realm on the current thread,
 including during write transactions on the current thread. The one exception to
 this is when using `for...in` fast enumeration, which will always enumerate
 over the objects which matched the query when the enumeration is begun, even if
 some of them are deleted or modified to be excluded by the filter during the
 enumeration.

 `RLMResults` are lazily evaluated the first time they are accessed; they only
 run queries when the result of the query is requested. This means that 
 chaining several temporary `RLMResults` to sort and filter your data does not 
 perform any extra work processing the intermediate state.

 Once the results have been evaluated or a notification block has been added,
 the results are eagerly kept up-to-date, with the work done to keep them
 up-to-date done on a background thread whenever possible.

 `RLMResults` cannot be directly instantiated.
 */
@interface RLMResults<RLMObjectType: RLMObject *> : NSObject<RLMCollection, NSFastEnumeration>

#pragma mark - Properties

/**
 The number of objects in the results collection.
 */
@property (nonatomic, readonly, assign) NSUInteger count;

/**
 The class name (i.e. type) of the `RLMObject`s contained in the results collection.
 */
@property (nonatomic, readonly, copy) NSString *objectClassName;

/**
 The Realm which manages this results collection.
 */
@property (nonatomic, readonly) RLMRealm *realm;

/**
 Indicates if the results collection is no longer valid.

 The results collection becomes invalid if `invalidate` is called on the containing `realm`.
 An invalidated results collection can be accessed, but will always be empty.
 */
@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;

#pragma mark - Accessing Objects from an RLMResults

/**
 Returns the object at the index specified.

 @param index   The index to look up.

 @return An `RLMObject` of the type contained in the results collection.
 */
- (RLMObjectType)objectAtIndex:(NSUInteger)index;

/**
 Returns the first object in the results collection.

 Returns `nil` if called on an empty results collection.

 @return An `RLMObject` of the type contained in the results collection.
 */
- (nullable RLMObjectType)firstObject;

/**
 Returns the last object in the results collection.

 Returns `nil` if called on an empty results collection.

 @return An `RLMObject` of the type contained in the results collection.
 */
- (nullable RLMObjectType)lastObject;

#pragma mark - Querying Results

/**
 Returns the index of an object in the results collection.

 Returns `NSNotFound` if the object is not found in the results collection.

 @param object  An object (of the same type as returned from the `objectClassName` selector).
 */
- (NSUInteger)indexOfObject:(RLMObjectType)object;

/**
 Returns the index of the first object in the results collection matching the predicate.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.

 @return    The index of the object, or `NSNotFound` if the object is not found in the results collection.
 */
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns the index of the first object in the results collection matching the predicate.

 @param predicate   The predicate with which to filter the objects.

 @return    The index of the object, or `NSNotFound` if the object is not found in the results collection.
 */
- (NSUInteger)indexOfObjectWithPredicate:(NSPredicate *)predicate;

/**
 Returns all the objects matching the given predicate in the results collection.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.

 @return                An `RLMResults` of objects that match the given predicate.
 */
- (RLMResults<RLMObjectType> *)objectsWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (RLMResults<RLMObjectType> *)objectsWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns all the objects matching the given predicate in the results collection.

 @param predicate   The predicate with which to filter the objects.

 @return            An `RLMResults` of objects that match the given predicate.
 */
- (RLMResults<RLMObjectType> *)objectsWithPredicate:(NSPredicate *)predicate;

/**
 Returns a sorted `RLMResults` from an existing results collection.

 @param property    The property name to sort by.
 @param ascending   The direction to sort in.

 @return    An `RLMResults` sorted by the specified property.
 */
- (RLMResults<RLMObjectType> *)sortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending;

/**
 Returns a sorted `RLMResults` from an existing results collection.

 @param properties  An array of `RLMSortDescriptor`s to sort by.

 @return    An `RLMResults` sorted by the specified properties.
 */
- (RLMResults<RLMObjectType> *)sortedResultsUsingDescriptors:(NSArray *)properties;

#pragma mark - Notifications

/**
 Registers a block to be called each time the results collection changes.

 The block will be asynchronously called with the initial results collection,
 and then called again after each write transaction which changes either any
 of the objects in the results, or which objects are in the results.

 The `change` parameter will be `nil` the first time the block is called.
 For each call after that, it will contain information about
 which rows in the results collection were added, removed or modified. If a
 write transaction did not modify any objects in the results collection,
 the block is not called at all. See the `RLMCollectionChange` documentation for
 information on how the changes are reported and an example of updating a 
 `UITableView`.

 If an error occurs the block will be called with `nil` for the results
 parameter and a non-`nil` error. Currently the only errors that can occur are
 when opening the Realm on the background worker thread.

 At the time when the block is called, the `RLMResults` object will be fully
 evaluated and up-to-date, and as long as you do not perform a write transaction
 on the same thread or explicitly call `-[RLMRealm refresh]`, accessing it will
 never perform blocking work.

 Notifications are delivered via the standard run loop, and so can't be
 delivered while the run loop is blocked by other activity. When
 notifications can't be delivered instantly, multiple notifications may be
 coalesced into a single notification. This can include the notification
 with the initial results. For example, the following code performs a write
 transaction immediately after adding the notification block, so there is no
 opportunity for the initial notification to be delivered first. As a
 result, the initial notification will reflect the state of the Realm after
 the write transaction.

     RLMResults<Dog *> *results = [Dog allObjects];
     NSLog(@"dogs.count: %zu", dogs.count); // => 0
     self.token = [results addNotificationBlock:^(RLMResults *dogs,
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

 @param block The block to be called whenever a change occurs.
 @return A token which must be held for as long as you want updates to be delivered.
 */
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMResults<RLMObjectType> *__nullable results,
                                                         RLMCollectionChange *__nullable change,
                                                         NSError *__nullable error))block __attribute__((warn_unused_result));

#pragma mark - Aggregating Property Values

/**
 Returns the minimum (lowest) value of the given property among all the objects
 represented by the results collection.

     NSNumber *min = [results minOfProperty:@"age"];

 @warning You cannot use this method on `RLMObject`, `RLMArray`, and `NSData` properties.

 @param property The property whose minimum value is desired. Only properties of types `int`, `float`, `double`, and
                 `NSDate` are supported.

 @return The minimum value of the property.
 */
- (nullable id)minOfProperty:(NSString *)property;

/**
 Returns the maximum (highest) value of the given property among all the objects represented by the results collection.

     NSNumber *max = [results maxOfProperty:@"age"];

 @warning You cannot use this method on `RLMObject`, `RLMArray`, and `NSData` properties.

 @param property The property whose maximum value is desired. Only properties of types `int`, `float`, `double`, and 
                 `NSDate` are supported.

 @return The maximum value of the property.
 */
- (nullable id)maxOfProperty:(NSString *)property;

/**
 Returns the sum of the values of a given property over all the objects represented by the results collection.

     NSNumber *sum = [results sumOfProperty:@"age"];

 @warning You cannot use this method on `RLMObject`, `RLMArray`, and `NSData` properties.

 @param property The property whose values should be summed. Only properties of types `int`, `float`, and `double` are
                 supported.

 @return The sum of the given property.
 */
- (NSNumber *)sumOfProperty:(NSString *)property;

/**
 Returns the average value of a given property over the objects represented by the results collection.

     NSNumber *average = [results averageOfProperty:@"age"];

 @warning You cannot use this method on `RLMObject`, `RLMArray`, and `NSData` properties.

 @param property The property whose average value should be calculated. Only properties of types `int`, `float`, and
                 `double` are supported.

 @return    The average value of the given property. This will be of type `double` for both `float` and `double`
            properties.
 */
- (nullable NSNumber *)averageOfProperty:(NSString *)property;

/// :nodoc:
- (RLMObjectType)objectAtIndexedSubscript:(NSUInteger)index;

#pragma mark - Unavailable Methods

/**
 `-[RLMResults init]` is not available because `RLMResults` cannot be created directly.
 `RLMResults` can be obtained by querying a Realm.
 */
- (instancetype)init __attribute__((unavailable("RLMResults cannot be created directly")));

/**
 `+[RLMResults new]` is not available because `RLMResults` cannot be created directly.
 `RLMResults` can be obtained by querying a Realm.
 */
+ (instancetype)new __attribute__((unavailable("RLMResults cannot be created directly")));

@end

/**
 `RLMLinkingObjects` is an auto-updating container type. It represents a collection of objects that link to its
 parent object.
 
 For more information, please see the "Inverse Relationships" section in the
 [documentation](https://realm.io/docs/objc/latest/#relationships).
 */
@interface RLMLinkingObjects<RLMObjectType: RLMObject *> : RLMResults
@end

NS_ASSUME_NONNULL_END
