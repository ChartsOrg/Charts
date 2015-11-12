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

#ifdef __cplusplus
extern "C" {
#endif

#import <Realm/RLMSchema.h>
#import <Realm/RLMDefines.h>

RLM_ASSUME_NONNULL_BEGIN

@class RLMRealm;

//
// RLMSchema private interface
//
@interface RLMSchema ()

/**
 Returns an `RLMSchema` containing only the given `RLMObject` subclasses.

 @param classes The classes to be included in the schema.

 @return An `RLMSchema` containing only the given classes.
 */
+ (instancetype)schemaWithObjectClasses:(NSArray *)classes;

@property (nonatomic, readwrite, copy) NSArray *objectSchema;

// schema based on runtime objects
+ (instancetype)sharedSchema;

// schema based upon all currently registered object classes
+ (instancetype)partialSharedSchema;

// schema based on tables in a Realm
+ (instancetype)dynamicSchemaFromRealm:(RLMRealm *)realm;

// class for string
+ (nullable Class)classForString:(NSString *)className;

// shallow copy for reusing schema properties accross the same Realm on multiple threads
- (instancetype)shallowCopy;

@end

RLM_ASSUME_NONNULL_END

#ifdef __cplusplus
}
#endif
