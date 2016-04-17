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

#import <Realm/RLMObjectBase.h>

RLM_ASSUME_NONNULL_BEGIN

@class RLMRealm;
@class RLMResults;
@class RLMObjectSchema;

/**
 
 In Realm you define your model classes by subclassing `RLMObject` and adding properties to be persisted.
 You then instantiate and use your custom subclasses instead of using the `RLMObject` class directly.
 
     // Dog.h
     @interface Dog : RLMObject
     @property NSString *name;
     @property BOOL      adopted;
     @end
 
     // Dog.m
     @implementation Dog
     @end //none needed
 
 ### Supported property types
 
 - `NSString`
 - `NSInteger`, `int`, `long`, `float`, and `double`
 - `BOOL` or `bool`
 - `NSDate`
 - `NSData`
 - `NSNumber<X>`, where X is one of RLMInt, RLMFloat, RLMDouble or RLMBool, for optional number properties
 - `RLMObject` subclasses, so you can have many-to-one relationships.
 - `RLMArray<X>`, where X is an `RLMObject` subclass, so you can have many-to-many relationships.

 ### Querying
 
 You can query an object directly via the class methods: `allObjects`, `objectsWhere:`, and `objectsWithPredicate:`.
 These methods allow you to easily query a custom subclass for instances of this class in the
 default Realm. To search in a Realm other than the default Realm use the interface on an RLMRealm instance.
 
 ### Relationships
 
 See our [Cocoa guide](https://realm.io/docs/objc/latest#relationships) for more details.

 ### Key-Value Observing

 All `RLMObject` properties (including properties you create in subclasses) are
 [Key-Value Observing compliant](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html),
 except for `realm` and `objectSchema`. There are several Realm-specific things
 to keep in mind when observing Realm objects:

 1. Unlike `NSMutableArray` properties, `RLMArray` properties do not require
    using the proxy object returned from `-mutableArrayValueForKey:`, or defining
    KVC mutation methods on the containing class. You can simply call methods on
    the RLMArray directly and the changes will be observed by the containing
    object.
 2. Standalone `RLMObjects` cannot be added to a Realm while they have any
    observed properties.
 3. Modifying persisted `RLMObjects` in `-observeValueForKeyPath:ofObject:change:context:`
    is problematic. Properties may change when the Realm is not in a write
    transaction (for example, when `-[RLMRealm refresh]` is called after changes
    are made on a different thread), and notifications sent prior to the change
    being applied (when `NSKeyValueObservingOptionPrior` is used) may be sent at
    times when you *cannot* begin a write transaction.
 */

@interface RLMObject : RLMObjectBase

#pragma mark - Creating & Initializing Objects

/**
 Initialize a standalone RLMObject
 
 Initialize an unpersisted instance of this object.
 Call addObject: on an RLMRealm to add standalone object to a realm.
 
 @see [RLMRealm addObject:]:
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;


/**
 Initialize a standalone RLMObject with values from an NSArray or NSDictionary
 
 Initialize an unpersisted instance of this object.
 Call addObject: on an RLMRealm to add standalone object to a realm.
 
 @see [RLMRealm addObject:]:
 */
- (instancetype)initWithValue:(id)value NS_DESIGNATED_INITIALIZER;


/**
 Helper to return the class name for an RLMObject subclass.

 @warning Do not override. Realm relies on this method returning the exact class
          name.
 
 @return  The class name for the model class.
 */
+ (NSString *)className;

/**
 Create an RLMObject in the default Realm with a given value.

 Creates an instance of this object and adds it to the default Realm populating
 the object with the given value.
 
 If nested objects are included in the argument, `createInDefaultRealmWithValue:` will be called
 on them.

 @param value   The value used to populate the object. This can be any key/value coding compliant
                object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                an NSArray with one object for each persisted property. An exception will be
                thrown if any required properties are not present and no default is set.

 When passing in an NSArray, all properties must be present, valid and in the same order as the properties defined in the model.

 @see   defaultPropertyValues
 */
+ (instancetype)createInDefaultRealmWithValue:(id)value;

/**
 Create an RLMObject in a Realm with a given object.
 
 Creates an instance of this object and adds it to the given Realm populating
 the object with the given object.
 
 If nested objects are included in the argument, `createInRealm:withValue:` will be called
 on them.
 
 @param realm   The Realm in which this object is persisted.
 @param value   The value used to populate the object. This can be any key/value coding compliant
                object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                an NSArray with one object for each persisted property. An exception will be
                thrown if any required properties are not present and no default is set.
                
                When passing in an NSArray, all properties must be present, valid and in the same order as the properties defined in the model.
 
 @see   defaultPropertyValues
 */
+ (instancetype)createInRealm:(RLMRealm *)realm withValue:(id)value;

/**
 Create or update an RLMObject in the default Realm with a given object.

 This method can only be called on object types with a primary key defined. If there is already
 an object with the same primary key value in the default RLMRealm its values are updated and the object
 is returned. Otherwise this creates and populates a new instance of this object in the default Realm.
 
 If nested objects are included in the argument, `createOrUpdateInDefaultRealmWithValue:` will be
 called on them if have a primary key (`createInDefaultRealmWithValue:` otherwise).
 
 This is a no-op if the argument is an RLMObject of the same type already backed by the target realm.

 @param value   The value used to populate the object. This can be any key/value coding compliant
                object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                an NSArray with one object for each persisted property. An exception will be
                thrown if any required properties are not present and no default is set.

 When passing in an NSArray, all properties must be present, valid and in the same order as the properties defined in the model.

 @see   defaultPropertyValues, primaryKey
 */
+ (instancetype)createOrUpdateInDefaultRealmWithValue:(id)value;

/**
 Create or update an RLMObject with a given object.

 This method can only be called on object types with a primary key defined. If there is already
 an object with the same primary key value in the provided RLMRealm its values are updated and the object
 is returned. Otherwise this creates and populates a new instance of this object in the provided Realm.
 
 If nested objects are included in the argument, `createOrUpdateInRealm:withValue:` will be
 called on them if have a primary key (`createInRealm:withValue:` otherwise).

 This is a no-op if the argument is an RLMObject of the same type already backed by the target realm.

 @param realm   The Realm in which this object is persisted.
 @param value   The value used to populate the object. This can be any key/value coding compliant
                object, or a JSON object such as those returned from the methods in NSJSONSerialization, or
                an NSArray with one object for each persisted property. An exception will be
                thrown if any required properties are not present and no default is set.

 When passing in an NSArray, all properties must be present, valid and in the same order as the properties defined in the model.

 @see   defaultPropertyValues, primaryKey
 */
+ (instancetype)createOrUpdateInRealm:(RLMRealm *)realm withValue:(id)value;

#pragma mark - Properties

/**
 The Realm in which this object is persisted. Returns nil for standalone objects.
 */
@property (nonatomic, readonly, nullable) RLMRealm *realm;

/**
 The ObjectSchema which lists the persisted properties for this object.
 */
@property (nonatomic, readonly) RLMObjectSchema *objectSchema;

/**
 Indicates if an object can no longer be accessed.
 
 An object can no longer be accessed if the object has been deleted from the containing `realm` or
 if `invalidate` is called on the containing `realm`.
 */
@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;


#pragma mark - Customizing your Objects

/**
 Return an array of property names for properties which should be indexed. Only supported
 for string and int properties.
 @return    NSArray of property names.
 */
+ (NSArray RLM_GENERIC(NSString *) *)indexedProperties;

/**
 Implement to indicate the default values to be used for each property.
 
 @return    NSDictionary mapping property names to their default values.
 */
+ (nullable NSDictionary *)defaultPropertyValues;

/**
 Implement to designate a property as the primary key for an RLMObject subclass. Only properties of
 type RLMPropertyTypeString and RLMPropertyTypeInt can be designated as the primary key. Primary key 
 properties enforce uniqueness for each value whenever the property is set which incurs some overhead.
 Indexes are created automatically for primary key properties.

 @return    Name of the property designated as the primary key.
 */
+ (nullable NSString *)primaryKey;

/**
 Implement to return an array of property names to ignore. These properties will not be persisted
 and are treated as transient.
 
 @return    NSArray of property names to ignore.
 */
+ (nullable NSArray RLM_GENERIC(NSString *) *)ignoredProperties;

/**
 Implement to return an array of property names that should not allow storing nil.

 By default, all properties of a type that support storing nil are considered optional properties.
 To require that an object in a Realm always have a non-nil value for a property,
 add the name of the property to the array returned from this method.
 
 Currently Object properties cannot be required. Array and NSNumber properties
 can, but it makes little sense to do so: arrays do not support storing nil, and
 if you want a non-optional number you should instead use the primitive type.

 @return    NSArray of property names that are required.
 */
+ (NSArray RLM_GENERIC(NSString *) *)requiredProperties;


#pragma mark - Getting & Querying Objects from the Default Realm

/**
 Get all objects of this type from the default Realm.
 
 @return    An RLMResults of all objects of this type in the default Realm.
 */
+ (RLMResults *)allObjects;

/**
 Get objects matching the given predicate for this type from the default Realm.
 
 @param predicateFormat The predicate format string which can accept variable arguments.
 
 @return    An RLMResults of objects of the subclass type in the default Realm that match the given predicate
 */
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat args:(va_list)args;


/**
 Get objects matching the given predicate for this type from the default Realm.

 @param predicate   The predicate to filter the objects.

 @return    An RLMResults of objects of the subclass type in the default Realm that match the given predicate
 */
+ (RLMResults *)objectsWithPredicate:(nullable NSPredicate *)predicate;

/**
 Get the single object with the given primary key from the default Realm.

 Returns the object from the default Realm which has the given primary key, or
 `nil` if the object does not exist. This is slightly faster than the otherwise
 equivalent `[[SubclassName objectsWhere:@"primaryKeyPropertyName = %@", key] firstObject]`.

 This method requires that `primaryKey` be overridden on the receiving subclass.

 @return    An object of the subclass type or nil if an object with the given primary key does not exist.
 @see       -primaryKey
 */
+ (nullable instancetype)objectForPrimaryKey:(nullable id)primaryKey;


#pragma mark - Querying Specific Realms

/**
 Get all objects of this type from the specified Realm.

 @param realm   The Realm instance to query.

 @return        An RLMResults of all objects of this type in the specified Realm.
 */
+ (RLMResults *)allObjectsInRealm:(RLMRealm *)realm;

/**
 Get objects matching the given predicate for this type from the specified Realm.

 @param predicateFormat The predicate format string which can accept variable arguments.
 @param realm           The Realm instance to query.

 @return    An RLMResults of objects of the subclass type in the specified Realm that match the given predicate
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat, ...;

/// :nodoc:
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat args:(va_list)args;

/**
 Get objects matching the given predicate for this type from the specified Realm.

 @param predicate   The predicate to filter the objects.
 @param realm       The Realm instance to query.

 @return    An RLMResults of objects of the subclass type in the specified Realm that match the given predicate
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm withPredicate:(nullable NSPredicate *)predicate;

/**
 Get the single object with the given primary key from the specified Realm.

 Returns the object from the specified Realm which has the given primary key, or
 `nil` if the object does not exist. This is slightly faster than the otherwise
 equivalent `[[SubclassName objectsInRealm:realm where:@"primaryKeyPropertyName = %@", key] firstObject]`.

 This method requires that `primaryKey` be overridden on the receiving subclass.

 @return    An object of the subclass type or nil if an object with the given primary key does not exist.
 @see       -primaryKey
 */
+ (nullable instancetype)objectInRealm:(RLMRealm *)realm forPrimaryKey:(nullable id)primaryKey;

#pragma mark - Other Instance Methods

/**
 Get an `NSArray` of objects of type `className` which have this object as the given property value. This can
 be used to get the inverse relationship value for `RLMObject` and `RLMArray` properties.

 @param className   The type of object on which the relationship to query is defined.
 @param property    The name of the property which defines the relationship.

 @return    An NSArray of objects of type `className` which have this object as their value for the `property` property.
 */
- (NSArray *)linkingObjectsOfClass:(NSString *)className forProperty:(NSString *)property;

/**
 Returns YES if another RLMObject points to the same object in an RLMRealm. For RLMObject types
 with a primary, key, `isEqual:` is overridden to use this method (along with a corresponding
 implementation for `hash`.

 @param object  The object to compare to.

 @return    YES if the object represents the same object in the same RLMRealm.
 */
- (BOOL)isEqualToObject:(RLMObject *)object;

#pragma mark - Dynamic Accessors

/// :nodoc:
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/// :nodoc:
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

#pragma mark - RLMArray Property Declaration

/**
 Properties on RLMObjects of type RLMArray must have an associated type. A type is associated
 with an RLMArray property by defining a protocol for the object type which the RLMArray will
 hold. To define the protocol for an object you can use the macro RLM_ARRAY_TYPE:
 
     RLM_ARRAY_TYPE(ObjectType)
     ...
     @property RLMArray<ObjectType *><ObjectType> *arrayOfObjectTypes;
  */
#define RLM_ARRAY_TYPE(RLM_OBJECT_SUBCLASS)\
@protocol RLM_OBJECT_SUBCLASS <NSObject>   \
@end

RLM_ASSUME_NONNULL_END
