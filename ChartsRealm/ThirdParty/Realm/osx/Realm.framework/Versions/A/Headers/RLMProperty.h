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
#import <Realm/RLMDefines.h>

RLM_ASSUME_NONNULL_BEGIN

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
 This class models properties persisted to Realm in an RLMObjectSchema.
 
 When using Realm, RLMProperty objects allow performing migrations and 
 introspecting the database's schema.
 
 These properties map to columns in the core database.
 */
@interface RLMProperty : NSObject

#pragma mark - Properties

/**
 Property name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 Property type.
 
 @see RLMPropertyType
 */
@property (nonatomic, readonly) RLMPropertyType type;

/**
 Indicates if this property is indexed.
 
 @see RLMObject
 */
@property (nonatomic, readonly) BOOL indexed;

/**
 Object class name - specify object types for RLMObject and RLMArray properties.
 */
@property (nonatomic, readonly, copy, nullable) NSString *objectClassName;

/**
 Whether this property is optional.
 */
@property (nonatomic, readonly) BOOL optional;

#pragma mark - Methods

/**
 Returns YES if property objects are equal.
 */
- (BOOL)isEqualToProperty:(RLMProperty *)property;

@end

RLM_ASSUME_NONNULL_END
