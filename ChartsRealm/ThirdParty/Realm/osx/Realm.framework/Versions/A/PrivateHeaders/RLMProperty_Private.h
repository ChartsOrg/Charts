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

#import <Realm/RLMProperty.h>

#import <objc/runtime.h>

@class RLMObjectBase;

BOOL RLMPropertyTypeIsNullable(RLMPropertyType propertyType);
BOOL RLMPropertyTypeIsComputed(RLMPropertyType propertyType);

// private property interface
@interface RLMProperty () {
@public
    RLMPropertyType _type;
    Ivar _swiftIvar;
}

- (instancetype)initWithName:(NSString *)name
                     indexed:(BOOL)indexed
      linkPropertyDescriptor:(RLMPropertyDescriptor *)linkPropertyDescriptor
                    property:(objc_property_t)property;

- (instancetype)initSwiftPropertyWithName:(NSString *)name
                                  indexed:(BOOL)indexed
                   linkPropertyDescriptor:(RLMPropertyDescriptor *)linkPropertyDescriptor
                                 property:(objc_property_t)property
                                 instance:(RLMObjectBase *)objectInstance;

- (instancetype)initSwiftListPropertyWithName:(NSString *)name
                                         ivar:(Ivar)ivar
                              objectClassName:(NSString *)objectClassName;

- (instancetype)initSwiftOptionalPropertyWithName:(NSString *)name
                                          indexed:(BOOL)indexed
                                             ivar:(Ivar)ivar
                                     propertyType:(RLMPropertyType)propertyType;

- (instancetype)initSwiftLinkingObjectsPropertyWithName:(NSString *)name
                                                   ivar:(Ivar)ivar
                                        objectClassName:(NSString *)objectClassName
                                 linkOriginPropertyName:(NSString *)linkOriginPropertyName;

// private setters
@property (nonatomic, assign) NSUInteger column;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite, assign) RLMPropertyType type;
@property (nonatomic, readwrite) BOOL indexed;
@property (nonatomic, readwrite) BOOL optional;
@property (nonatomic, copy) NSString *objectClassName;

// private properties
@property (nonatomic, assign) char objcType;
@property (nonatomic, copy) NSString *objcRawType;
@property (nonatomic, assign) BOOL isPrimary;
@property (nonatomic, assign) Ivar swiftIvar;

// getter and setter names
@property (nonatomic, copy) NSString *getterName;
@property (nonatomic, copy) NSString *setterName;
@property (nonatomic) SEL getterSel;
@property (nonatomic) SEL setterSel;

- (RLMProperty *)copyWithNewName:(NSString *)name;

@end

@interface RLMProperty (Dynamic)
/**
 This method is useful only in specialized circumstances, for example, in conjunction with
 +[RLMObjectSchema initWithClassName:objectClass:properties:]. If you are simply building an
 app on Realm, it is not recommened to use this method.
 
 Initialize an RLMProperty
 
 @warning This method is useful only in specialized circumstances.
 
 @param name            The property name.
 @param type            The property type.
 @param objectClassName The object type used for Object and Array types.
 @param linkOriginPropertyName The property name of the origin of a link. Used for linking objects properties.

 @return    An initialized instance of RLMProperty.
 */
- (instancetype)initWithName:(NSString *)name
                        type:(RLMPropertyType)type
             objectClassName:(NSString *)objectClassName
      linkOriginPropertyName:(NSString *)linkOriginPropertyName
                     indexed:(BOOL)indexed
                    optional:(BOOL)optional;
@end

