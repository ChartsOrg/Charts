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
#import <Realm/RLMObjectSchema.h>

RLM_ASSUME_NONNULL_BEGIN

@class RLMRealm;

// RLMObjectSchema private
@interface RLMObjectSchema ()

// writable redecleration
@property (nonatomic, readwrite, copy) NSArray RLM_GENERIC(RLMProperty *) *properties;
@property (nonatomic, readwrite, assign) bool isSwiftClass;

// class used for this object schema
@property (nonatomic, readwrite, assign) Class objectClass;
@property (nonatomic, readwrite, assign) Class accessorClass;
@property (nonatomic, readwrite, assign) Class standaloneClass;

@property (nonatomic, readwrite) RLMProperty *primaryKeyProperty;

@property (nonatomic, readonly) NSArray RLM_GENERIC(RLMProperty *) *propertiesInDeclaredOrder;

// The Realm retains its object schemas, so they need to not retain the Realm
@property (nonatomic, unsafe_unretained, nullable) RLMRealm *realm;
// returns a cached or new schema for a given object class
+ (instancetype)schemaForObjectClass:(Class)objectClass;

- (void)sortPropertiesByColumn;

@end

@interface RLMObjectSchema (Dynamic)
/**
 This method is useful only in specialized circumstances, for example, when accessing objects
 in a Realm produced externally. If you are simply building an app on Realm, it is not recommened
 to use this method as an [RLMObjectSchema](RLMObjectSchema) is generated automatically for every [RLMObject](RLMObject) subclass.
 
 Initialize an RLMObjectSchema with classname, objectClass, and an array of properties
 
 @warning This method is useful only in specialized circumstances.
 
 @param objectClassName     The name of the class used to refer to objects of this type.
 @param objectClass         The objective-c class used when creating instances of this type.
 @param properties          An array RLMProperty describing the persisted properties for this type.
 
 @return    An initialized instance of RLMObjectSchema.
 */
- (instancetype)initWithClassName:(NSString *)objectClassName objectClass:(Class)objectClass properties:(NSArray *)properties;
@end

RLM_ASSUME_NONNULL_END
