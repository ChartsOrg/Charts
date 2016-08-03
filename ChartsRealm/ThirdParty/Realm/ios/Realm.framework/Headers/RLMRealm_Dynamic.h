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
 Returns all objects of a given type from the Realm.

 @warning This method is useful only in specialized circumstances, for example, when building components
          that integrate with Realm. The preferred way to get objects of a single class is to use the class
          methods on `RLMObject`.

 @param className   The name of the `RLMObject` subclass to retrieve on (e.g. `MyClass.className`).

 @return    An `RLMResults` containing all objects in the Realm of the given type.

 @see       `+[RLMObject allObjects]`
 */
- (RLMResults *)allObjects:(NSString *)className;

/**
 Returns all objects matching the given predicate from the Realm.

 @warning This method is useful only in specialized circumstances, for example, when building components
          that integrate with Realm. The preferred way to get objects of a single class is to use the class
          methods on `RLMObject`.

 @param className       The type of objects you are looking for (name of the class).
 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.

 @return    An `RLMResults` containing results matching the given predicate.

 @see       `+[RLMObject objectsWhere:]`
 */
- (RLMResults *)objects:(NSString *)className where:(NSString *)predicateFormat, ...;

/**
 Returns all objects matching the given predicate from the Realm.

 @warning This method is useful only in specialized circumstances, for example, when building components
          that integrate with Realm. The preferred way to get objects of a single class is to use the class
          methods on `RLMObject`.

 @param className   The type of objects you are looking for (name of the class).
 @param predicate   The predicate with which to filter the objects.

 @return    An `RLMResults` containing results matching the given predicate.

 @see       `+[RLMObject objectsWhere:]`
 */
- (RLMResults *)objects:(NSString *)className withPredicate:(NSPredicate *)predicate;

/**
 Returns the object of the given type with the given primary key from the Realm.

 @warning This method is useful only in specialized circumstances, for example, when building components 
          that integrate with Realm. The preferred way to get an object of a single class is to use the class
          methods on `RLMObject`.
 
 @param className   The class name for the object you are looking for.
 @param primaryKey  The primary key value for the object you are looking for.
 
 @return    An object, or `nil` if an object with the given primary key does not exist.
 
 @see       `+[RLMObject objectForPrimaryKey:]`
 */
- (RLMObject *)objectWithClassName:(NSString *)className forPrimaryKey:(id)primaryKey;

/**
 Creates an `RLMObject` instance of type `className` in the Realm, and populates it using a given object.
 
 The `value` argument is used to populate the object. It can be a key-value coding compliant object, an array or
 dictionary returned from the methods in `NSJSONSerialization`, or an array containing one element for each managed
 property. An exception will be thrown if any required properties are not present and those properties were not defined
 with default values.

 When passing in an array as the `value` argument, all properties must be present, valid and in the same order as the
 properties defined in the model.

 @warning This method is useful only in specialized circumstances, for example, when building components
          that integrate with Realm. If you are simply building an app on Realm, it is recommended to
          use `[RLMObject createInDefaultRealmWithValue:]`.

 @param value    The value used to populate the object.

 @return    An `RLMObject` instance of type `className`.
 */
-(RLMObject *)createObject:(NSString *)className withValue:(id)value;

@end
