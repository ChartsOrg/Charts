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

NS_ASSUME_NONNULL_BEGIN

/**
 This model is used to reflect permissions.

 It should be used in conjunction with a `RLMSyncUser`'s Permission Realm.
 You can only read this Realm. Use the objects in Management Realm to
 make request for modifications of permissions.

 See https://realm.io/docs/realm-object-server/#permissions for general
 documentation.
 */
@interface RLMSyncPermission : RLMObject

/// The date this object was last modified.
@property (readonly) NSDate *updatedAt;

/// The identity of a user affected by this permission.
@property (readonly) NSString *userId;

/// The path to the realm.
@property (readonly) NSString *path;

/// Whether the affected user is allowed to read from the Realm.
@property (readonly) BOOL mayRead;
/// Whether the affected user is allowed to write to the Realm.
@property (readonly) BOOL mayWrite;
/// Whether the affected user is allowed to manage the access rights for others.
@property (readonly) BOOL mayManage;

@end

NS_ASSUME_NONNULL_END
