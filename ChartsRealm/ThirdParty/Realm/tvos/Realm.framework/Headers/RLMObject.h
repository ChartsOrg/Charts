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

NS_ASSUME_NONNULL_BEGIN

@class RLMPropertyDescriptor;
@class RLMRealm;
@class RLMResults;
@class RLMObjectSchema;

/**
 `RLMObject` is a base class for model objects representing data stored in Realms.

 Define your model classes by subclassing `RLMObject` and adding properties to be managed.
 Then instantiate and use your custom subclasses instead of using the `RLMObject` class directly.

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
 - `NSNumber<X>`, where `X` is one of `RLMInt`, `RLMFloat`, `RLMDouble` or `RLMBool`, for optional number properties
 - `RLMObject` subclasses, to model many-to-one relationships.
 - `RLMArray<X>`, where `X` is an `RLMObject` subclass, to model many-to-many relationships.

 ### Querying
 
 You can initiate queries directly via the class methods: `allObjects`, `objectsWhere:`, and `objectsWithPredicate:`.
 These methods allow you to easily query a custom subclass for instances of that class in the default Realm.
 
 To search in a Realm other than the default Realm, use the `allObjectsInRealm:`, `objectsInRealm:where:`,
 and `objectsInRealm:withPredicate:` class methods.
 
 @see `RLMRealm`
 
 ### Relationships
 
 See our [Cocoa guide](https://realm.io/docs/objc/latest#relationships) for more details.

 ### Key-Value Observing

 All `RLMObject` properties (including properties you create in subclasses) are
 [Key-Value Observing compliant](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html),
 except for `realm` and `objectSchema`.
 
 Keep the following tips in mind when observing Realm objects:

 1. Unlike `NSMutableArray` properties, `RLMArray` properties do not require
    using the proxy object returned from `-mutableArrayValueForKey:`, or defining
    KVC mutation methods on the containing class. You can simply call methods on
    the `RLMArray` directly; any changes will be automatically observed by the containing
    object.
 2. Unmanaged `RLMObject` instances cannot be added to a Realm while they have any
    observed properties.
 3. Modifying managed `RLMObject`s within `-observeValueForKeyPath:ofObject:change:context:`
    is not recommended. Properties may change even when the Realm is not in a write
    transaction (for example, when `-[RLMRealm refresh]` is called after changes
    are made on a different thread), and notifications sent prior to the change
    being applied (when `NSKeyValueObservingOptionPrior` is used) may be sent at
    times when you *cannot* begin a write transaction.
 */

@interface RLMObject : RLMObjectBase

#pragma mark - Creating & Initializing Objects

/**
 Initializes an unmanaged instance of a Realm object.

 Call `addObject:` on an `RLMRealm` instance to add an unmanaged object into that Realm.
 
 @see `[RLMRealm addObject:]`
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;


/**
 Initializes an unmanaged instance of a Realm object.
 
 Pass in an `NSArray` or `NSDictionary` instance to set the values of the object's properties.

 Call `addObject:` on an `RLMRealm` instance to add an unmanaged object into that Realm.
 
 @see `[RLMRealm addObject:]`
 */
- (instancetype)initWithValue:(id)value NS_DESIGNATED_INITIALIZER;


/**
 Returns the class name for a Realm object subclass.

 @warning Do not override. Realm relies on this method returning the exact class
          name.
 
 @return  The class name for the model class.
 */
+ (NSString *)className;

/**
 Creates an instance of a Realm object with a given value, and adds it to the default Realm.
 
 If nested objects are included in the argument, `createInDefaultRealmWithValue:` will be recursively called
 on them.
 
 The `value` argument can be a key-value coding compliant object, an array or dictionary returned from the methods in
 `NSJSONSerialization`, or an array containing one element for each managed property. An exception will be thrown if
 any required properties are not present and those properties were not defined with default values.

 When passing in an array as the `value` argument, all properties must be present, valid and in the same order as the
 properties defined in the model.

 @param value    The value used to populate the object.

 @see   `defaultPropertyValues`
 */
+ (instancetype)createInDefaultRealmWithValue:(id)value;

/**
 Creates an instance of a Realm object with a given value, and adds it to the specified Realm.
 
 If nested objects are included in the argument, `createInRealm:withValue:` will be recursively called
 on them.
 
 The `value` argument can be a key-value coding compliant object, an array or dictionary returned from the methods in
 `NSJSONSerialization`, or an array containing one element for each managed property. An exception will be thrown if any
 required properties are not present and those properties were not defined with default values.

 When passing in an array as the `value` argument, all properties must be present, valid and in the same order as the
 properties defined in the model.

 @param realm    The Realm which should manage the newly-created object.
 @param value    The value used to populate the object.

 @see   `defaultPropertyValues`
 */
+ (instancetype)createInRealm:(RLMRealm *)realm withValue:(id)value;

/**
 Creates or updates a Realm object within the default Realm.

 This method may only be called on Realm object types with a primary key defined. If there is already
 an object with the same primary key value in the default Realm, its values are updated and the object
 is returned. Otherwise, this method creates and populates a new instance of the object in the default Realm.
 
 If nested objects are included in the argument, `createOrUpdateInDefaultRealmWithValue:` will be
 recursively called on them if they have primary keys, `createInDefaultRealmWithValue:` if they do not.

 If the argument is a Realm object already managed by the default Realm, the argument's type is the same
 as the receiver, and the objects have identical values for their managed properties, this method does nothing.
 
 The `value` argument is used to populate the object. It can be a key-value coding compliant object, an array or
 dictionary returned from the methods in `NSJSONSerialization`, or an array containing one element for each managed
 property. An exception will be thrown if any required properties are not present and those properties were not defined
 with default values.

 When passing in an array as the `value` argument, all properties must be present, valid and in the same order as the
 properties defined in the model.

 @param value    The value used to populate the object.

 @see   `defaultPropertyValues`, `primaryKey`
 */
+ (instancetype)createOrUpdateInDefaultRealmWithValue:(id)value;

/**
 Creates or updates an Realm object within a specified Realm.

 This method may only be called on Realm object types with a primary key defined. If there is already
 an object with the same primary key value in the given Realm, its values are updated and the object
 is returned. Otherwise this method creates and populates a new instance of this object in the given Realm.
 
 If nested objects are included in the argument, `createOrUpdateInRealm:withValue:` will be
 recursively called on them if they have primary keys, `createInRealm:withValue:` if they do not.

 If the argument is a Realm object already managed by the given Realm, the argument's type is the same
 as the receiver, and the objects have identical values for their managed properties, this method does nothing.
 
 The `value` argument is used to populate the object. It can be a key-value coding compliant object, an array or
 dictionary returned from the methods in `NSJSONSerialization`, or an array containing one element for each managed
 property. An exception will be thrown if any required properties are not present and those properties were not defined
 with default values.

 When passing in an array as the `value` argument, all properties must be present, valid and in the same order as the
 properties defined in the model.

 @param realm    The Realm which should own the object.
 @param value    The value used to populate the object.

 @see   `defaultPropertyValues`, `primaryKey`
 */
+ (instancetype)createOrUpdateInRealm:(RLMRealm *)realm withValue:(id)value;

#pragma mark - Properties

/**
 The Realm which manages the object, or `nil` if the object is unmanaged.
 */
@property (nonatomic, readonly, nullable) RLMRealm *realm;

/**
 The object schema which lists the managed properties for the object.
 */
@property (nonatomic, readonly) RLMObjectSchema *objectSchema;

/**
 Indicates if the object can no longer be accessed because it is now invalid.
 
 An object can no longer be accessed if the object has been deleted from the Realm that manages it, or
 if `invalidate` is called on that Realm.
 */
@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;


#pragma mark - Customizing your Objects

/**
 Returns an array of property names for properties which should be indexed.
 
 Only string, integer, boolean, and `NSDate` properties are supported.

 @return    An array of property names.
 */
+ (NSArray<NSString *> *)indexedProperties;

/**
 Override this method to specify the default values to be used for each property.
 
 @return    A dictionary mapping property names to their default values.
 */
+ (nullable NSDictionary *)defaultPropertyValues;

/**
 Override this method to specify the name of a property to be used as the primary key.
 
 Only properties of types `RLMPropertyTypeString` and `RLMPropertyTypeInt` can be designated as the primary key.
 Primary key properties enforce uniqueness for each value whenever the property is set, which incurs minor overhead.
 Indexes are created automatically for primary key properties.

 @return    The name of the property designated as the primary key.
 */
+ (nullable NSString *)primaryKey;

/**
 Override this method to specify the names of properties to ignore. These properties will not be managed by the Realm
 that manages the object.

 @return    An array of property names to ignore.
 */
+ (nullable NSArray<NSString *> *)ignoredProperties;

/**
 Override this method to specify the names of properties that are non-optional (i.e. cannot be assigned a `nil` value).

 By default, all properties of a type whose values can be set to `nil` are considered optional properties.
 To require that an object in a Realm always store a non-`nil` value for a property,
 add the name of the property to the array returned from this method.
 
 Properties of `RLMObject` type cannot be non-optional. Array and `NSNumber` properties
 can be non-optional, but there is no reason to do so: arrays do not support storing nil, and
 if you want a non-optional number you should instead use the primitive type.

 @return    An array of property names that are required.
 */
+ (NSArray<NSString *> *)requiredProperties;

/**
 Override this method to provide information related to properties containing linking objects.
 
 Each property of type `RLMLinkingObjects` must have a key in the dictionary returned by this method consisting
 of the property name. The corresponding value must be an instance of `RLMPropertyDescriptor` that describes the class
 and property that the property is linked to.

     return @{ @"owners": [RLMPropertyDescriptor descriptorWithClass:Owner.class propertyName:@"dogs"] };

 @return     A dictionary mapping property names to `RLMPropertyDescriptor` instances.
 */
+ (NSDictionary<NSString *, RLMPropertyDescriptor *> *)linkingObjectsProperties;


#pragma mark - Getting & Querying Objects from the Default Realm

/**
 Returns all objects of this object type from the default Realm.
 
 @return    An `RLMResults` containing all objects of this type in the default Realm.
 */
+ (RLMResults *)allObjects;

/**
 Returns all objects of this object type matching the given predicate from the default Realm.
 
 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.
 
 @return    An `RLMResults` containing all objects of this type in the default Realm that match the given predicate.
 */
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ...;

/// :nodoc:
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat args:(va_list)args;


/**
 Returns all objects of this object type matching the given predicate from the default Realm.

 @param predicate   The predicate with which to filter the objects.

 @return    An `RLMResults` containing all objects of this type in the default Realm that match the given predicate.
 */
+ (RLMResults *)objectsWithPredicate:(nullable NSPredicate *)predicate;

/**
 Retrieves the single instance of this object type with the given primary key from the default Realm.

 Returns the object from the default Realm which has the given primary key, or
 `nil` if the object does not exist. This is slightly faster than the otherwise
 equivalent `[[SubclassName objectsWhere:@"primaryKeyPropertyName = %@", key] firstObject]`.

 This method requires that `primaryKey` be overridden on the receiving subclass.

 @return    An object of this object type, or `nil` if an object with the given primary key does not exist.
 @see       `-primaryKey`
 */
+ (nullable instancetype)objectForPrimaryKey:(nullable id)primaryKey;


#pragma mark - Querying Specific Realms

/**
 Returns all objects of this object type from the specified Realm.

 @param realm   The Realm to query.

 @return        An `RLMResults` containing all objects of this type in the specified Realm.
 */
+ (RLMResults *)allObjectsInRealm:(RLMRealm *)realm;

/**
 Returns all objects of this object type matching the given predicate from the specified Realm.

 @param predicateFormat A predicate format string, optionally followed by a variable number of arguments.
 @param realm           The Realm to query.

 @return    An `RLMResults` containing all objects of this type in the specified Realm that match the given predicate.
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat, ...;

/// :nodoc:
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat args:(va_list)args;

/**
 Returns all objects of this object type matching the given predicate from the specified Realm.

 @param predicate   A predicate to use to filter the elements.
 @param realm       The Realm to query.

 @return    An `RLMResults` containing all objects of this type in the specified Realm that match the given predicate.
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm withPredicate:(nullable NSPredicate *)predicate;

/**
 Retrieves the single instance of this object type with the given primary key from the specified Realm.

 Returns the object from the specified Realm which has the given primary key, or
 `nil` if the object does not exist. This is slightly faster than the otherwise
 equivalent `[[SubclassName objectsInRealm:realm where:@"primaryKeyPropertyName = %@", key] firstObject]`.

 This method requires that `primaryKey` be overridden on the receiving subclass.

 @return    An object of this object type, or `nil` if an object with the given primary key does not exist.
 @see       `-primaryKey`
 */
+ (nullable instancetype)objectInRealm:(RLMRealm *)realm forPrimaryKey:(nullable id)primaryKey;

#pragma mark - Other Instance Methods

/**
 Returns YES if another Realm object instance points to the same object as the receiver in the Realm managing
 the receiver.
 
 For object types with a primary, key, `isEqual:` is overridden to use this method (along with a corresponding
 implementation for `hash`).

 @param object  The object to compare the receiver to.

 @return    A Boolean indicating whether the object represents the same object as the receiver.
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
 Properties on `RLMObject`s of type `RLMArray` must have an associated type. A type is associated
 with an `RLMArray` property by defining a protocol for the object type that the array should contain.
 To define the protocol for an object, you can use the macro RLM_ARRAY_TYPE:
 
     RLM_ARRAY_TYPE(ObjectType)
     ...
     @property RLMArray<ObjectType *><ObjectType> *arrayOfObjectTypes;
  */
#define RLM_ARRAY_TYPE(RLM_OBJECT_SUBCLASS)\
@protocol RLM_OBJECT_SUBCLASS <NSObject>   \
@end

NS_ASSUME_NONNULL_END
