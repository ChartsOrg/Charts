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

#pragma mark - Enums

/**
 Property types supported in Realm models.

 See [Realm Models](https://realm.io/docs/objc/latest/#models)
 */
// Make sure numbers match those in <realm/data_type.hpp>
typedef NS_ENUM(int32_t, RLMPropertyType) {

#pragma mark - Primitive types

    /** Integer type: NSInteger, int, long, Int (Swift) */
    RLMPropertyTypeInt    = 0,
    /** Boolean type: BOOL, bool, Bool (Swift) */
    RLMPropertyTypeBool   = 1,
    /** Float type: float, Float (Swift) */
    RLMPropertyTypeFloat  = 9,
    /** Double type: double, Double (Swift) */
    RLMPropertyTypeDouble = 10,

#pragma mark - Object types

    /** String type: NSString, String (Swift) */
    RLMPropertyTypeString = 2,
    /** Data type: NSData */
    RLMPropertyTypeData   = 4,
    /** Any type: id, **not supported in Swift** */
    RLMPropertyTypeAny    = 6,
    /** Date type: NSDate */
    RLMPropertyTypeDate   = 7,

#pragma mark - Array/Linked object types

    /** Object type. See [Realm Models](https://realm.io/docs/objc/latest/#models) */
    RLMPropertyTypeObject = 12,
    /** Array type. See [Realm Models](http://realms.io/docs/objc/latest/#models) */
    RLMPropertyTypeArray  = 13,
};

/**
 Enum representing all recoverable errors in Realm.
 */
typedef NS_ENUM(NSInteger, RLMError) {
    /** Returned by RLMRealm if no other specific error is returned when a realm is opened. */
    RLMErrorFail                  = 1,
    /** Returned by RLMRealm for any I/O related exception scenarios when a realm is opened. */
    RLMErrorFileAccessError       = 2,
    /** Returned by RLMRealm if the user does not have permission to open or create
        the specified file in the specified access mode when the realm is opened. */
    RLMErrorFilePermissionDenied  = 3,
    /** Returned by RLMRealm if no_create was specified and the file did already exist when the realm is opened. */
    RLMErrorFileExists            = 4,
    /** Returned by RLMRealm if no_create was specified and the file was not found when the realm is opened. */
    RLMErrorFileNotFound          = 5,
    /** Returned by RLMRealm if a file format upgrade is required to open the file, but upgrades were explicilty disabled. */
    RLMErrorFileFormatUpgradeRequired = 6,
    /** Returned by RLMRealm if the database file is currently open in another
        process which cannot share with the current process due to an
        architecture mismatch. */
    RLMErrorIncompatibleLockFile  = 8,
};

#pragma mark - Constants

#pragma mark - Notification Constants

/**
 Posted by RLMRealm when the data in the realm has changed.

 DidChange are posted after a realm has been refreshed to reflect a write
 transaction, i.e. when an autorefresh occurs, `[RLMRealm refresh]` is
 called, after an implicit refresh from `[RLMRealm beginWriteTransaction]`,
 and after a local write transaction is committed.
 */
extern NSString * const RLMRealmRefreshRequiredNotification;

/**
 Posted by RLMRealm when a write transaction has been committed to an RLMRealm on
 a different thread for the same file. This is not posted if
 `[RLMRealm autorefresh]` is enabled or if the RLMRealm is
 refreshed before the notifcation has a chance to run.

 Realms with autorefresh disabled should normally have a handler for this
 notification which calls `[RLMRealm refresh]` after doing some work.
 While not refreshing is allowed, it may lead to large Realm files as Realm has
 to keep an extra copy of the data for the un-refreshed RLMRealm.
 */
extern NSString * const RLMRealmDidChangeNotification;

#pragma mark - Other Constants

/** Schema version used for uninitialized Realms */
extern const uint64_t RLMNotVersioned;

/** Error domain used in Realm. */
extern NSString * const RLMErrorDomain;

/** Key for name of Realm exceptions. */
extern NSString * const RLMExceptionName;

/** Key for Realm file version. */
extern NSString * const RLMRealmVersionKey;

/** Key for Realm core version. */
extern NSString * const RLMRealmCoreVersionKey;

/** Key for Realm invalidated property name. */
extern NSString * const RLMInvalidatedKey;
