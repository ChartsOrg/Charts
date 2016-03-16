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

#import <Realm/RLMObjectSchema.h>
#import <Realm/RLMProperty.h>

@class RLMResults;

@interface RLMRealm (Dynamic)

#pragma mark - Getting Objects from a Realm

/**
 This method is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to use the class methods on `RLMObject`.
 
 Get all objects of a given type in this Realm.
 
 The preferred way to get objects of a single class is to use the class methods on RLMObject.
 
 @warning This method is useful only in specialized circumstances.

 @param className   The name of the RLMObject subclass to retrieve on e.g. `MyClass.className`.

 @return    An RLMResults of all objects in this realm of the given type.

 @see       RLMObject allObjects
 */
- (RLMResults *)allObjects:(NSString *)className;

/**
 This method is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to use the class methods on `RLMObject`.
 
 Get objects matching the given predicate from the this Realm.

 The preferred way to get objects of a single class is to use the class methods on RLMObject.
 
 @warning This method is useful only in specialized circumstances.

 @param className       The type of objects you are looking for (name of the class).
 @param predicateFormat The predicate format string which can accept variable arguments.

 @return    An RLMResults of results matching the given predicate.

 @see       RLMObject objectsWhere:
 */
- (RLMResults *)objects:(NSString *)className where:(NSString *)predicateFormat, ...;

/**
 This method is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to use the class methods on `RLMObject`.
 
 Get objects matching the given predicate from the this Realm.

 The preferred way to get objects of a single class is to use the class methods on RLMObject.
 
 @warning This method is useful only in specialized circumstances.

 @param className   The type of objects you are looking for (name of the class).
 @param predicate   The predicate to filter the objects.

 @return    An RLMResults of results matching the given predicate.

 @see       RLMObject objectsWhere:
 */
- (RLMResults *)objects:(NSString *)className withPredicate:(NSPredicate *)predicate;

/**
 This method is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to use the class methods on `RLMObject`.
 
 Get an object of a given class name with a primary key
 
 The preferred way to get an object of a single class is to use the class methods on RLMObject.
 
 @warning This method is useful only in specialized circumstances.
 
 @param className   The class name for the object you are looking for
 @param primaryKey  The primary key value for the object you are looking for
 
 @return    An object or nil if an object with the given primary key does not exist.
 
 @see       RLMObject objectForPrimaryKey:
 */
- (RLMObject *)objectWithClassName:(NSString *)className forPrimaryKey:(id)primaryKey;

/**
 This method is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to use [RLMObject createInDefaultRealmWithValue:].
 
 Create an RLMObject of type `className` in the Realm with a given object.
 
 @warning This method is useful only in specialized circumstances.

 @param value   The value used to populate the object. This can be any key/value coding compliant
                object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                an NSArray with one object for each persisted property. An exception will be
                thrown if any required properties are not present and no default is set.

                When passing in an NSArray, all properties must be present, valid and in the same order as 
                the properties defined in the model.
 
 @return    An RLMObject of type `className`
 */
-(RLMObject *)createObject:(NSString *)className withValue:(id)value;

@end
