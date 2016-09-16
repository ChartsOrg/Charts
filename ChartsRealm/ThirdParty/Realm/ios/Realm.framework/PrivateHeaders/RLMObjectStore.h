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

#ifdef __cplusplus
extern "C" {
#endif

@class RLMRealm, RLMSchema, RLMObjectBase, RLMResults, RLMProperty;

NS_ASSUME_NONNULL_BEGIN

//
// Accessor Creation
//

// create or get cached accessors for the given schema
void RLMRealmCreateAccessors(RLMSchema *schema);


//
// Options for object creation
//
typedef NS_OPTIONS(NSUInteger, RLMCreationOptions) {
    // Normal object creation
    RLMCreationOptionsNone = 0,
    // If the property is a link or array property, upsert the linked objects
    // if they have a primary key, and insert them otherwise.
    RLMCreationOptionsCreateOrUpdate = 1 << 0,
    // Allow unmanaged objects to be promoted to managed objects
    // if false objects are copied during object creation
    RLMCreationOptionsPromoteUnmanaged = 1 << 1,
};


//
// Adding, Removing, Getting Objects
//

// add an object to the given realm
void RLMAddObjectToRealm(RLMObjectBase *object, RLMRealm *realm, bool createOrUpdate);

// delete an object from its realm
void RLMDeleteObjectFromRealm(RLMObjectBase *object, RLMRealm *realm);

// deletes all objects from a realm
void RLMDeleteAllObjectsFromRealm(RLMRealm *realm);

// get objects of a given class
RLMResults *RLMGetObjects(RLMRealm *realm, NSString *objectClassName, NSPredicate * _Nullable predicate)
NS_RETURNS_RETAINED;

// get an object with the given primary key
id _Nullable RLMGetObject(RLMRealm *realm, NSString *objectClassName, id _Nullable key) NS_RETURNS_RETAINED;

// create object from array or dictionary
RLMObjectBase *RLMCreateObjectInRealmWithValue(RLMRealm *realm, NSString *className, id _Nullable value, bool createOrUpdate)
NS_RETURNS_RETAINED;
    

//
// Accessor Creation
//


// switch List<> properties from being backed by unmanaged RLMArrays to RLMArrayLinkView
void RLMInitializeSwiftAccessorGenerics(RLMObjectBase *object);

#ifdef __cplusplus
}

namespace realm {
    class Table;
    template<typename T> class BasicRowExpr;
    using RowExpr = BasicRowExpr<Table>;
}
class RLMClassInfo;

// Create accessors
RLMObjectBase *RLMCreateObjectAccessor(RLMRealm *realm, RLMClassInfo& info,
                                       NSUInteger index) NS_RETURNS_RETAINED;
RLMObjectBase *RLMCreateObjectAccessor(RLMRealm *realm, RLMClassInfo& info,
                                       realm::RowExpr row) NS_RETURNS_RETAINED;
#endif

NS_ASSUME_NONNULL_END
