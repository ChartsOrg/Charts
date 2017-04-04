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

// For compatibility with Xcode 7, before extensible string enums were introduced,
#ifdef NS_EXTENSIBLE_STRING_ENUM
#define RLM_EXTENSIBLE_STRING_ENUM NS_EXTENSIBLE_STRING_ENUM
#define RLM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(_, extensible_string_enum) NS_SWIFT_NAME(extensible_string_enum)
#else
#define RLM_EXTENSIBLE_STRING_ENUM
#define RLM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(fully_qualified, _) NS_SWIFT_NAME(fully_qualified)
#endif

#if __has_attribute(ns_error_domain) && (!defined(__cplusplus) || !__cplusplus || __cplusplus >= 201103L)
#define RLM_ERROR_ENUM(type, name, domain) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
    NS_ENUM(type, __attribute__((ns_error_domain(domain))) name) \
    _Pragma("clang diagnostic pop")
#else
#define RLM_ERROR_ENUM(type, name, domain) NS_ENUM(type, name)
#endif


#pragma mark - Enums

/**
 `RLMPropertyType` is an enumeration describing all property types supported in Realm models.

 For more information, see [Realm Models](https://realm.io/docs/objc/latest/#models).
 */
// Make sure numbers match those in <realm/data_type.hpp>
typedef NS_ENUM(int32_t, RLMPropertyType) {

#pragma mark - Primitive types

    /** Integers: `NSInteger`, `int`, `long`, `Int` (Swift) */
    RLMPropertyTypeInt    = 0,
    /** Booleans: `BOOL`, `bool`, `Bool` (Swift) */
    RLMPropertyTypeBool   = 1,
    /** Floating-point numbers: `float`, `Float` (Swift) */
    RLMPropertyTypeFloat  = 9,
    /** Double-precision floating-point numbers: `double`, `Double` (Swift) */
    RLMPropertyTypeDouble = 10,

#pragma mark - Object types

    /** Strings: `NSString`, `String` (Swift) */
    RLMPropertyTypeString = 2,
    /** Binary data: `NSData` */
    RLMPropertyTypeData   = 4,
    /** 
     Any object: `id`.
     
     This property type is no longer supported for new models. However, old models with any-typed properties are still
     supported for migration purposes.
     */
    RLMPropertyTypeAny    = 6,
    /** Dates: `NSDate` */
    RLMPropertyTypeDate   = 8,

#pragma mark - Array/Linked object types

    /** Realm model objects. See [Realm Models](https://realm.io/docs/objc/latest/#models) for more information. */
    RLMPropertyTypeObject = 12,
    /** Realm arrays. See [Realm Models](https://realm.io/docs/objc/latest/#models) for more information. */
    RLMPropertyTypeArray  = 13,
    /** Realm linking objects. See [Realm Models](https://realm.io/docs/objc/latest/#models) for more information. */
    RLMPropertyTypeLinkingObjects = 14,
};

/** An error domain identifying Realm-specific errors. */
extern NSString * const RLMErrorDomain;

/** An error domain identifying non-specific system errors. */
extern NSString * const RLMUnknownSystemErrorDomain;

/**
 `RLMError` is an enumeration representing all recoverable errors. It is associated with the
 Realm error domain specified in `RLMErrorDomain`.
 */
typedef RLM_ERROR_ENUM(NSInteger, RLMError, RLMErrorDomain) {
    /** Denotes a general error that occurred when trying to open a Realm. */
    RLMErrorFail                  = 1,

    /** Denotes a file I/O error that occurred when trying to open a Realm. */
    RLMErrorFileAccess            = 2,

    /** 
     Denotes a file permission error that ocurred when trying to open a Realm.
     
     This error can occur if the user does not have permission to open or create
     the specified file in the specified access mode when opening a Realm.
     */
    RLMErrorFilePermissionDenied  = 3,

    /** Denotes an error where a file was to be written to disk, but another file with the same name already exists. */
    RLMErrorFileExists            = 4,

    /**
     Denotes an error that occurs if a file could not be found.
     
     This error may occur if a Realm file could not be found on disk when trying to open a
     Realm as read-only, or if the directory part of the specified path was not found when
     trying to write a copy.
     */
    RLMErrorFileNotFound          = 5,

    /** 
     Denotes an error that occurs if a file format upgrade is required to open the file,
     but upgrades were explicitly disabled.
     */
    RLMErrorFileFormatUpgradeRequired = 6,

    /** 
     Denotes an error that occurs if the database file is currently open in another
     process which cannot share with the current process due to an
     architecture mismatch.
     
     This error may occur if trying to share a Realm file between an i386 (32-bit) iOS
     Simulator and the Realm Browser application. In this case, please use the 64-bit
     version of the iOS Simulator.
     */
    RLMErrorIncompatibleLockFile  = 8,

    /** Denotes an error that occurs when there is insufficient available address space. */
    RLMErrorAddressSpaceExhausted = 9,

    /** Denotes an error that occurs if there is a schema version mismatch, so that a migration is required. */
    RLMErrorSchemaMismatch = 10,
};

#pragma mark - Constants

#pragma mark - Notification Constants

/**
 A notification indicating that changes were made to a Realm.
*/
typedef NSString * RLMNotification RLM_EXTENSIBLE_STRING_ENUM;

/**
 This notification is posted by a Realm when the data in that Realm has changed.

 More specifically, this notification is posted after a Realm has been refreshed to
 reflect a write transaction. This can happen when an autorefresh occurs, when
 `-[RLMRealm refresh]` is called, after an implicit refresh from `-[RLMRealm beginWriteTransaction]`,
 or after a local write transaction is completed.
 */
extern RLMNotification const RLMRealmRefreshRequiredNotification
RLM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(RLMRealmRefreshRequiredNotification, RefreshRequired);

/**
 This notification is posted by a Realm when a write transaction has been
 committed to a Realm on a different thread for the same file.

 It is not posted if `-[RLMRealm autorefresh]` is enabled, or if the Realm is
 refreshed before the notification has a chance to run.

 Realms with autorefresh disabled should normally install a handler for this
 notification which calls `-[RLMRealm refresh]` after doing some work. Refreshing
 the Realm is optional, but not refreshing the Realm may lead to large Realm
 files. This is because Realm must keep an extra copy of the data for the stale
 Realm.
 */
extern RLMNotification const RLMRealmDidChangeNotification
RLM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(RLMRealmDidChangeNotification, DidChange);

#pragma mark - Other Constants

/** The schema version used for uninitialized Realms */
extern const uint64_t RLMNotVersioned;

/** The corresponding value is the name of an exception thrown by Realm. */
extern NSString * const RLMExceptionName;

/** The corresponding value is a Realm file version. */
extern NSString * const RLMRealmVersionKey;

/** The corresponding key is the version of the underlying database engine. */
extern NSString * const RLMRealmCoreVersionKey;

/** The corresponding key is the Realm invalidated property name. */
extern NSString * const RLMInvalidatedKey;

NS_ASSUME_NONNULL_END
