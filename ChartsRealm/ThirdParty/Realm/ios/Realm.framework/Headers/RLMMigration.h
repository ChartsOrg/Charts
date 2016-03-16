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
#import <Realm/RLMDefines.h>

RLM_ASSUME_NONNULL_BEGIN

@class RLMSchema;
@class RLMArray;
@class RLMObject;

/**
Provides both the old and new versions of an object in this Realm. Object properties can only be
accessed using keyed subscripting.

@param oldObject Object in original RLMRealm (read-only).
@param newObject Object in migrated RLMRealm (read-write).
*/
typedef void (^RLMObjectMigrationBlock)(RLMObject * __nullable oldObject, RLMObject * __nullable newObject);

/**
 RLMMigration is the object passed into a user defined RLMMigrationBlock when updating the version
 of an RLMRealm instance.

 This object provides access to the RLMSchema current to this migration.
 */
@interface RLMMigration : NSObject

#pragma mark - Properties

/**
 Get the old RLMSchema for the migration. This is the schema which describes the RLMRealm before the
 migration is applied.
 */
@property (nonatomic, readonly) RLMSchema *oldSchema;

/**
 Get the new RLMSchema for the migration. This is the schema which describes the RLMRealm after applying
 a migration.
 */
@property (nonatomic, readonly) RLMSchema *newSchema;


#pragma mark - Altering Objects during a Migration

/**
 Enumerates objects of a given type in this Realm, providing both the old and new versions of each object.
 Objects properties can be accessed using keyed subscripting.

 @param className   The name of the RLMObject class to enumerate.

 @warning   All objects returned are of a type specific to the current migration and should not be casted
            to className. Instead you should access them as RLMObjects and use keyed subscripting to access
            properties.
 */
- (void)enumerateObjects:(NSString *)className block:(RLMObjectMigrationBlock)block;

/**
 Create an RLMObject of type `className` in the Realm being migrated.

 @param className   The name of the RLMObject class to create.
 @param value       The value used to populate the created object. This can be any key/value coding compliant
                    object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                    an NSArray with one object for each persisted property. An exception will be
                    thrown if any required properties are not present and no default is set.

                    When passing in an NSArray, all properties must be present, valid and in the same order as the properties defined in the model.
 */
-(RLMObject *)createObject:(NSString *)className withValue:(id)value;

/**
 Delete an object from a Realm during a migration. This can be called within `enumerateObjects:block:`.

 @param object  Object to be deleted from the Realm being migrated.
 */
- (void)deleteObject:(RLMObject *)object;

/**
 Deletes the data for the class with the given name.
 This deletes all objects of the given class, and if the RLMObject subclass no longer exists in your program,
 cleans up any remaining metadata for the class in the Realm file.

 @param  name The name of the RLMObject class to delete.

 @return whether there was any data to delete.
 */
- (BOOL)deleteDataForClassName:(NSString *)name;

@end

RLM_ASSUME_NONNULL_END
