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

NS_ASSUME_NONNULL_BEGIN

@class RLMSchema;
@class RLMArray;
@class RLMObject;

/**
 A block type which provides both the old and new versions of an object in the Realm. Object 
 properties can only be accessed using keyed subscripting.
 
 @see `-[RLMMigration enumerateObjects:block:]`
 
 @param oldObject The object from the original Realm (read-only).
 @param newObject The object from the migrated Realm (read-write).
*/
typedef void (^RLMObjectMigrationBlock)(RLMObject * __nullable oldObject, RLMObject * __nullable newObject);

/**
 `RLMMigration` instances encapsulate information intended to facilitate a schema migration.
 
 A `RLMMigration` instance is passed into a user-defined `RLMMigrationBlock` block when updating
 the version of a Realm. This instance provides access to the old and new database schemas, the
 objects in the Realm, and provides functionality for modifying the Realm during the migration.
 */
@interface RLMMigration : NSObject

#pragma mark - Properties

/**
 Returns the old `RLMSchema`. This is the schema which describes the Realm before the
 migration is applied.
 */
@property (nonatomic, readonly) RLMSchema *oldSchema;

/**
 Returns the new `RLMSchema`. This is the schema which describes the Realm after the
 migration is applied.
 */
@property (nonatomic, readonly) RLMSchema *newSchema;


#pragma mark - Altering Objects during a Migration

/**
 Enumerates all the objects of a given type in the Realm, providing both the old and new versions
 of each object. Within the block, object properties can only be accessed using keyed subscripting.

 @param className   The name of the `RLMObject` class to enumerate.

 @warning   All objects returned are of a type specific to the current migration and should not be cast
            to `className`. Instead, treat them as `RLMObject`s and use keyed subscripting to access
            properties.
 */
- (void)enumerateObjects:(NSString *)className block:(RLMObjectMigrationBlock)block;

/**
 Creates and returns an `RLMObject` instance of type `className` in the Realm being migrated.
 
 The `value` argument is used to populate the object. It can be a key-value coding compliant object, an array or 
 dictionary returned from the methods in `NSJSONSerialization`, or an array containing one element for each managed
 property. An exception will be thrown if any required properties are not present and those properties were not defined
 with default values.

 When passing in an `NSArray` as the `value` argument, all properties must be present, valid and in the same order as
 the properties defined in the model.

 @param className   The name of the `RLMObject` class to create.
 @param value       The value used to populate the object.
 */
- (RLMObject *)createObject:(NSString *)className withValue:(id)value;

/**
 Deletes an object from a Realm during a migration.

 It is permitted to call this method from within the block passed to `-[enumerateObjects:block:]`.

 @param object  Object to be deleted from the Realm being migrated.
 */
- (void)deleteObject:(RLMObject *)object;

/**
 Deletes the data for the class with the given name.

 All objects of the given class will be deleted. If the `RLMObject` subclass no longer exists in your program,
 any remaining metadata for the class will be removed from the Realm file.

 @param  name The name of the `RLMObject` class to delete.

 @return A Boolean value indicating whether there was any data to delete.
 */
- (BOOL)deleteDataForClassName:(NSString *)name;

/**
 Renames a property of the given class from `oldName` to `newName`.

 @param className The name of the class whose property should be renamed. This class must be present
                  in both the old and new Realm schemas.
 @param oldName   The old name for the property to be renamed. There must not be a property with this name in the
                  class as defined by the new Realm schema.
 @param newName   The new name for the property to be renamed. There must not be a property with this name in the
                  class as defined by the old Realm schema.
 */
- (void)renamePropertyForClass:(NSString *)className oldName:(NSString *)oldName newName:(NSString *)newName;

@end

NS_ASSUME_NONNULL_END
