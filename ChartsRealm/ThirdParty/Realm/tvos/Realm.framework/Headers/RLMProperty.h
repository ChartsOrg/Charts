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
#import <Realm/RLMConstants.h>

NS_ASSUME_NONNULL_BEGIN

/// :nodoc:
@protocol RLMInt
@end

/// :nodoc:
@protocol RLMBool
@end

/// :nodoc:
@protocol RLMDouble
@end

/// :nodoc:
@protocol RLMFloat
@end

/// :nodoc:
@interface NSNumber ()<RLMInt, RLMBool, RLMDouble, RLMFloat>
@end

/**
 `RLMProperty` instances represent properties managed by a Realm in the context of an object schema. Such properties may
 be persisted to a Realm file or computed from other data from the Realm.
 
 When using Realm, `RLMProperty` instances allow performing migrations and introspecting the database's schema.
 
 These property instances map to columns in the core database.
 */
@interface RLMProperty : NSObject

#pragma mark - Properties

/**
 The name of the property.
 */
@property (nonatomic, readonly) NSString *name;

/**
 The type of the property.
 
 @see `RLMPropertyType`
 */
@property (nonatomic, readonly) RLMPropertyType type;

/**
 Indicates whether this property is indexed.
 
 @see `RLMObject`
 */
@property (nonatomic, readonly) BOOL indexed;

/**
 For `RLMObject` and `RLMArray` properties, the name of the class of object stored in the property.
 */
@property (nonatomic, readonly, copy, nullable) NSString *objectClassName;

/**
 For linking objects properties, the property name of the property the linking objects property is linked to.
 */
@property (nonatomic, readonly, copy, nullable) NSString *linkOriginPropertyName;

/**
 Indicates whether this property is optional.
 */
@property (nonatomic, readonly) BOOL optional;

#pragma mark - Methods

/**
 Returns a Boolean value that indicates whether a given property object is equal to the receiver.
 */
- (BOOL)isEqualToProperty:(RLMProperty *)property;

@end


/**
 An `RLMPropertyDescriptor` instance represents a specific property on a given class.
 */
@interface RLMPropertyDescriptor : NSObject

/**
 Creates and returns a property descriptor.

 @param objectClass  The class of this property descriptor.
 @param propertyName The name of this property descriptor.
 */
+ (instancetype)descriptorWithClass:(Class)objectClass propertyName:(NSString *)propertyName;

/// The class of the property.
@property (nonatomic, readonly) Class objectClass;

/// The name of the property.
@property (nonatomic, readonly) NSString *propertyName;

@end

NS_ASSUME_NONNULL_END
