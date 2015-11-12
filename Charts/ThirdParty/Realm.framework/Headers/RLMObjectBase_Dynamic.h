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

#import <Realm/RLMObject.h>

@class RLMObjectSchema, RLMRealm;

/**
 This function is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to retrieve `realm` via `RLMObject`.
 
 @param object	an RLMObjectBase obtained via a Swift Object or RLMObject
 
 @return The Realm in which this object is persisted. Returns nil for standalone objects.
 */
FOUNDATION_EXTERN RLMRealm *RLMObjectBaseRealm(RLMObjectBase *object);

/**
 This function is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to retrieve `objectSchema` via `RLMObject`.
 
 @param object	an RLMObjectBase obtained via a Swift Object or RLMObject
 
 @return The ObjectSchema which lists the persisted properties for this object.
 */
FOUNDATION_EXTERN RLMObjectSchema *RLMObjectBaseObjectSchema(RLMObjectBase *object);

/**
 This function is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to retrieve the linking objects via `RLMObject`.
 
 @param object		an RLMObjectBase obtained via a Swift Object or RLMObject
 @param className	The type of object on which the relationship to query is defined.
 @param property	The name of the property which defines the relationship.
 
 @return An NSArray of objects of type `className` which have this object as thier value for the `property` property.
 */
FOUNDATION_EXTERN NSArray *RLMObjectBaseLinkingObjectsOfClass(RLMObjectBase *object, NSString *className, NSString *property);

/**
 This function is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to retrieve key values via `RLMObject`.
 
 @warning Will throw `NSUndefinedKeyException` if key is not present on the object
 
 @param object	an RLMObjectBase obtained via a Swift Object or RLMObject
 @param key		The name of the property
 
 @return the object for the property requested
 */
FOUNDATION_EXTERN id RLMObjectBaseObjectForKeyedSubscript(RLMObjectBase *object, NSString *key);

/**
 This function is useful only in specialized circumstances, for example, when building components
 that integrate with Realm. If you are simply building an app on Realm, it is
 recommended to set key values via `RLMObject`.
 
 @warning Will throw `NSUndefinedKeyException` if key is not present on the object
 
 @param object	an RLMObjectBase obtained via a Swift Object or RLMObject
 @param key		The name of the property
 @param obj		The object to set as the value of the key
 */
FOUNDATION_EXTERN void RLMObjectBaseSetObjectForKeyedSubscript(RLMObjectBase *object, NSString *key, id obj);

