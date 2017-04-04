////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
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
#import <Realm/RLMObject.h>
#import <Realm/RLMProperty.h>
#import <Realm/RLMSyncUtil.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This model is used for requesting changes to a Realm's permissions.

 It should be used in conjunction with an `RLMSyncUser`'s Management Realm.

 See https://realm.io/docs/realm-object-server/#permissions for general
 documentation.
 */
@interface RLMSyncPermissionChange : RLMObject

/// The globally unique ID string of this permission change object.
@property (readonly) NSString *id;

/// The date this object was initially created.
@property (readonly) NSDate *createdAt;

/// The date this object was last modified.
@property (readonly) NSDate *updatedAt;

/// The status code of the object that was processed by Realm Object Server.
@property (nullable, readonly) NSNumber<RLMInt> *statusCode;

/// An error or informational message, typically written to by the Realm Object Server.
@property (nullable, readonly) NSString *statusMessage;

/// Sync management object status.
@property (readonly) RLMSyncManagementObjectStatus status;

/// The remote URL to the realm.
@property (readonly) NSString *realmUrl;

/// The identity of a user affected by this permission change.
@property (readonly) NSString *userId;

/// Define read access. Set to `YES` or `NO` to update this value. Leave unset to preserve the existing setting.
@property (nullable, readonly) NSNumber<RLMBool> *mayRead;
/// Define write access. Set to `YES` or `NO` to update this value. Leave unset to preserve the existing setting.
@property (nullable, readonly) NSNumber<RLMBool> *mayWrite;
/// Define management access. Set to `YES` or `NO` to update this value. Leave unset to preserve the existing setting.
@property (nullable, readonly) NSNumber<RLMBool> *mayManage;

/**
 Construct a permission change object used to change the access permissions for a user on a Realm.

 @param realmURL  The Realm URL whose permissions settings should be changed.
                  Use `*` to change the permissions of all Realms managed by the Management Realm's `RLMSyncUser`.
 @param userID    The user or users who should be granted these permission changes.
                  Use `*` to change the permissions for all users.
 @param mayRead   Define read access. Set to `YES` or `NO` to update this value.
                  Leave unset to preserve the existing setting.
 @param mayWrite  Define write access. Set to `YES` or `NO` to update this value.
                  Leave unset to preserve the existing setting.
 @param mayManage Define management access. Set to `YES` or `NO` to update this value.
                  Leave unset to preserve the existing setting.
 */
+ (instancetype)permissionChangeWithRealmURL:(NSString *)realmURL
                                      userID:(NSString *)userID
                                        read:(nullable NSNumber<RLMBool> *)mayRead
                                       write:(nullable NSNumber<RLMBool> *)mayWrite
                                      manage:(nullable NSNumber<RLMBool> *)mayManage;

@end

NS_ASSUME_NONNULL_END
