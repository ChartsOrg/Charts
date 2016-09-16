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

#import <Realm/RLMObjectBase_Dynamic.h>

NS_ASSUME_NONNULL_BEGIN

// RLMObject accessor and read/write realm
@interface RLMObjectBase () {
@public
    RLMRealm *_realm;
    __unsafe_unretained RLMObjectSchema *_objectSchema;
}

// unmanaged initializer
- (instancetype)initWithValue:(id)value schema:(RLMSchema *)schema NS_DESIGNATED_INITIALIZER;

// live accessor initializer
- (instancetype)initWithRealm:(__unsafe_unretained RLMRealm *const)realm
                       schema:(RLMObjectSchema *)schema NS_DESIGNATED_INITIALIZER;

// shared schema for this class
+ (nullable RLMObjectSchema *)sharedSchema;

// provide injection point for alternative Swift object util class
+ (Class)objectUtilClass:(BOOL)isSwift;

@end

@interface RLMObject ()

// unmanaged initializer
- (instancetype)initWithValue:(id)value schema:(RLMSchema *)schema NS_DESIGNATED_INITIALIZER;

// live accessor initializer
- (instancetype)initWithRealm:(__unsafe_unretained RLMRealm *const)realm
                       schema:(RLMObjectSchema *)schema NS_DESIGNATED_INITIALIZER;

@end

@interface RLMDynamicObject : RLMObject

@end

// A reference to an object's row that doesn't keep the object accessor alive.
// Used by some Swift property types, such as LinkingObjects, to avoid retain cycles
// with their containing object.
@interface RLMWeakObjectHandle : NSObject

- (instancetype)initWithObject:(RLMObjectBase *)object;

// Consumes the row, so can only usefully be called once.
@property (nonatomic, readonly) RLMObjectBase *object;

@end

// Calls valueForKey: and re-raises NSUndefinedKeyExceptions
FOUNDATION_EXTERN id _Nullable RLMValidatedValueForProperty(id object, NSString *key, NSString *className);

// Compare two RLObjectBases
FOUNDATION_EXTERN BOOL RLMObjectBaseAreEqual(RLMObjectBase * _Nullable o1, RLMObjectBase * _Nullable o2);

// Get ObjectUil class for objc or swift
FOUNDATION_EXTERN Class RLMObjectUtilClass(BOOL isSwift);

FOUNDATION_EXTERN const NSUInteger RLMDescriptionMaxDepth;

@class RLMProperty, RLMArray;
@interface RLMObjectUtil : NSObject

+ (nullable NSArray<NSString *> *)ignoredPropertiesForClass:(Class)cls;
+ (nullable NSArray<NSString *> *)indexedPropertiesForClass:(Class)cls;
+ (nullable NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)linkingObjectsPropertiesForClass:(Class)cls;

+ (nullable NSArray<NSString *> *)getGenericListPropertyNames:(id)obj;
+ (nullable NSDictionary<NSString *, NSString *> *)getLinkingObjectsProperties:(id)object;

+ (nullable NSDictionary<NSString *, NSNumber *> *)getOptionalProperties:(id)obj;
+ (nullable NSArray<NSString *> *)requiredPropertiesForClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
