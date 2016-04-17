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

#import <Realm/RLMDefines.h>

RLM_ASSUME_NONNULL_BEGIN

@class RLMRealm, RLMResults, RLMObject, RLMSortDescriptor, RLMNotificationToken;

/**
 A homogenous collection of `RLMObject`s like `RLMArray` or `RLMResults`.
 */
@protocol RLMCollection <NSFastEnumeration>

@required

#pragma mark - Properties

/**
 Number of objects in the collection.
 */
@property (nonatomic, readonly, assign) NSUInteger count;

/**
 The class name (i.e. type) of the RLMObjects contained in this RLMCollection.
 */
@property (nonatomic, readonly, copy) NSString *objectClassName;

/**
 The Realm in which this collection is persisted. Returns nil for standalone collections.
 */
@property (nonatomic, readonly) RLMRealm *realm;

#pragma mark - Accessing Objects from a Collection

/**
 Returns the object at the index specified.
 
 @param index   The index to look up.
 
 @return An RLMObject of the type contained in this RLMCollection.
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 Returns the first object in the collection.
 
 Returns `nil` if called on an empty RLMCollection.
 
 @return An RLMObject of the type contained in this RLMCollection.
 */
- (nullable id)firstObject;

/**
 Returns the last object in the collection.
 
 Returns `nil` if called on an empty RLMCollection.
 
 @return An RLMObject of the type contained in this RLMCollection.
 */
- (nullable id)lastObject;

#pragma mark - Querying a Collection

/**
 Gets the index of an object.
 
 Returns NSNotFound if the object is not found in this RLMCollection.
 
 @param object  An object (of the same type as returned from the objectClassName selector).
 */
- (NSUInteger)indexOfObject:(RLMObject *)object;

/**
 Gets the index of the first object matching the predicate.
 
 @param predicateFormat The predicate format string which can accept variable arguments.
 
 @return    Index of object or NSNotFound if the object is not found in this RLMCollection.
 */
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Gets the index of the first object matching the predicate.
 
 @param predicate   The predicate to filter the objects.
 
 @return    Index of object or NSNotFound if the object is not found in this RLMCollection.
 */
- (NSUInteger)indexOfObjectWithPredicate:(NSPredicate *)predicate;

/**
 Get objects matching the given predicate in the RLMCollection.
 
 @param predicateFormat The predicate format string which can accept variable arguments.
 
 @return    An RLMResults of objects that match the given predicate
 */
- (RLMResults *)objectsWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
- (RLMResults *)objectsWhere:(NSString *)predicateFormat args:(va_list)args;

/**
 Get objects matching the given predicate in the RLMCollection.
 
 @param predicate   The predicate to filter the objects.
 
 @return            An RLMResults of objects that match the given predicate
 */
- (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate;

/**
 Get a sorted RLMResults from an RLMCollection.
 
 @param property    The property name to sort by.
 @param ascending   The direction to sort by.
 
 @return    An RLMResults sorted by the specified property.
 */
- (RLMResults *)sortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending;

/**
 Get a sorted RLMResults from an RLMCollection.
 
 @param properties  An array of `RLMSortDescriptor`s to sort by.
 
 @return    An RLMResults sorted by the specified properties.
 */
- (RLMResults *)sortedResultsUsingDescriptors:(NSArray RLM_GENERIC(RLMSortDescriptor *) *)properties;

/// :nodoc:
- (id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Returns an NSArray containing the results of invoking `valueForKey:` using key on each of the collection's objects.

 @param key The name of the property.

 @return NSArray containing the results of invoking `valueForKey:` using key on each of the collection's objects.
 */
- (nullable id)valueForKey:(NSString *)key;

/**
 Invokes `setValue:forKey:` on each of the collection's objects using the specified value and key.

 @warning This method can only be called during a write transaction.

 @param value The object value.
 @param key   The name of the property.
 */
- (void)setValue:(nullable id)value forKey:(NSString *)key;

#pragma mark - Notifications

/**
 Register a block to be called each time the collection changes.

 @param block The block to be called each time the collection changes.
 @return A token which must be held for as long as you want notifications to be delivered.
 */
- (RLMNotificationToken *)addNotificationBlock:(void (^)(id<RLMCollection> collection))block RLM_WARN_UNUSED_RESULT;

@end

RLM_ASSUME_NONNULL_END
