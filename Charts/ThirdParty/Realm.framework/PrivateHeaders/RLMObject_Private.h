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

// RLMObject accessor and read/write realm
@interface RLMObjectBase () {
  @public
    RLMRealm *_realm;
    // objectSchema is a cached pointer to an object stored in the RLMSchema
    // owned by _realm, so it's guaranteed to stay alive as long as this object
    // without retaining it (and retaining it makes iteration slower)
    __unsafe_unretained RLMObjectSchema *_objectSchema;
}

// standalone initializer
- (instancetype)initWithValue:(id)value schema:(RLMSchema *)schema;

// live accessor initializer
- (instancetype)initWithRealm:(__unsafe_unretained RLMRealm *const)realm
                       schema:(__unsafe_unretained RLMObjectSchema *const)schema;

// shared schema for this class
+ (RLMObjectSchema *)sharedSchema;

@end

@interface RLMDynamicObject : RLMObject

@end

//
// Getters and setters for RLMObjectBase ivars for realm and objectSchema
//
FOUNDATION_EXTERN void RLMObjectBaseSetRealm(RLMObjectBase *object, RLMRealm *realm);
FOUNDATION_EXTERN RLMRealm *RLMObjectBaseRealm(RLMObjectBase *object);
FOUNDATION_EXTERN void RLMObjectBaseSetObjectSchema(RLMObjectBase *object, RLMObjectSchema *objectSchema);
FOUNDATION_EXTERN RLMObjectSchema *RLMObjectBaseObjectSchema(RLMObjectBase *object);

// Get linking objects for an RLMObjectBase
FOUNDATION_EXTERN NSArray *RLMObjectBaseLinkingObjectsOfClass(RLMObjectBase *object, NSString *className, NSString *property);

// Dynamic access to RLMObjectBase properties
FOUNDATION_EXTERN id RLMObjectBaseObjectForKeyedSubscript(RLMObjectBase *object, NSString *key);
FOUNDATION_EXTERN void RLMObjectBaseSetObjectForKeyedSubscript(RLMObjectBase *object, NSString *key, id obj);

// Calls valueForKey: and re-raises NSUndefinedKeyExceptions
FOUNDATION_EXTERN id RLMValidatedValueForProperty(id object, NSString *key, NSString *className);

// Compare two RLObjectBases
FOUNDATION_EXTERN BOOL RLMObjectBaseAreEqual(RLMObjectBase *o1, RLMObjectBase *o2);

// Get ObjectUil class for objc or swift
FOUNDATION_EXTERN Class RLMObjectUtilClass(BOOL isSwift);

FOUNDATION_EXTERN const NSUInteger RLMDescriptionMaxDepth;

@class RLMProperty, RLMArray;
@interface RLMObjectUtil : NSObject

+ (NSArray *)ignoredPropertiesForClass:(Class)cls;
+ (NSArray *)indexedPropertiesForClass:(Class)cls;

+ (NSArray *)getGenericListPropertyNames:(id)obj;
+ (void)initializeListProperty:(RLMObjectBase *)object property:(RLMProperty *)property array:(RLMArray *)array;

+ (NSDictionary *)getOptionalProperties:(id)obj;
+ (NSArray *)requiredPropertiesForClass:(Class)cls;

@end
