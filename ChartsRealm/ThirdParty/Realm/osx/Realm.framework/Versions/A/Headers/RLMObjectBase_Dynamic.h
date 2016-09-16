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

NS_ASSUME_NONNULL_BEGIN

/**
 Returns the Realm that manages the object, if one exists.
 
 @warning  This function is useful only in specialized circumstances, for example, when building components
           that integrate with Realm. If you are simply building an app on Realm, it is
           recommended to retrieve the Realm that manages the object via `RLMObject`.

 @param object	An `RLMObjectBase` obtained via a Swift `Object` or `RLMObject`.
 
 @return The Realm which manages this object. Returns `nil `for unmanaged objects.
 */
FOUNDATION_EXTERN RLMRealm * _Nullable RLMObjectBaseRealm(RLMObjectBase * _Nullable object);

/**
 Returns an `RLMObjectSchema` which describes the managed properties of the object.
 
 @warning  This function is useful only in specialized circumstances, for example, when building components
           that integrate with Realm. If you are simply building an app on Realm, it is
           recommended to retrieve `objectSchema` via `RLMObject`.

 @param object	An `RLMObjectBase` obtained via a Swift `Object` or `RLMObject`.
 
 @return The object schema which lists the managed properties for the object.
 */
FOUNDATION_EXTERN RLMObjectSchema * _Nullable RLMObjectBaseObjectSchema(RLMObjectBase * _Nullable object);

/**
 Returns the object corresponding to a key value.

 @warning  This function is useful only in specialized circumstances, for example, when building components
           that integrate with Realm. If you are simply building an app on Realm, it is
           recommended to retrieve key values via `RLMObject`.

 @warning Will throw an `NSUndefinedKeyException` if `key` is not present on the object.
 
 @param object	An `RLMObjectBase` obtained via a Swift `Object` or `RLMObject`.
 @param key		The name of the property.
 
 @return The object for the property requested.
 */
FOUNDATION_EXTERN id _Nullable RLMObjectBaseObjectForKeyedSubscript(RLMObjectBase * _Nullable object, NSString *key);

/**
 Sets a value for a key on the object.
 
 @warning  This function is useful only in specialized circumstances, for example, when building components
           that integrate with Realm. If you are simply building an app on Realm, it is
           recommended to set key values via `RLMObject`.

 @warning Will throw an `NSUndefinedKeyException` if `key` is not present on the object.
 
 @param object	An `RLMObjectBase` obtained via a Swift `Object` or `RLMObject`.
 @param key		The name of the property.
 @param obj		The object to set as the value of the key.
 */
FOUNDATION_EXTERN void RLMObjectBaseSetObjectForKeyedSubscript(RLMObjectBase * _Nullable object, NSString *key, id _Nullable obj);

NS_ASSUME_NONNULL_END
