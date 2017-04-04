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

#import "RLMRealm.h"

/**
 The current state of the session represented by an `RLMSyncSession` object.
 */
typedef NS_ENUM(NSUInteger, RLMSyncSessionState) {
    /// The sync session is bound to the Realm Object Server and communicating with it.
    RLMSyncSessionStateActive,
    /// The sync session is not currently communicating with the Realm Object Server.
    RLMSyncSessionStateInactive,
    /// The sync session encountered a fatal error and is permanently invalid; it should be discarded.
    RLMSyncSessionStateInvalid
};

/**
 The transfer direction (upload or download) tracked by a given progress notification block.

 Progress notification blocks can be registered on sessions if your app wishes to be informed
 how many bytes have been uploaded or downloaded, for example to show progress indicator UIs.
 */
typedef NS_ENUM(NSUInteger, RLMSyncProgressDirection) {
    /// For monitoring upload progress.
    RLMSyncProgressDirectionUpload,
    /// For monitoring download progress.
    RLMSyncProgressDirectionDownload,
};

/**
 The desired behavior of a progress notification block.

 Progress notification blocks can be registered on sessions if your app wishes to be informed
 how many bytes have been uploaded or downloaded, for example to show progress indicator UIs.
 */
typedef NS_ENUM(NSUInteger, RLMSyncProgress) {
    /**
     The block will be called forever, or until it is unregistered by calling
     `-[RLMProgressNotificationToken stop]`.

     Notifications will always report the latest number of transferred bytes, and the
     most up-to-date number of total transferrable bytes.
     */
    RLMSyncProgressReportIndefinitely,
    /**
     The block will, upon registration, store the total number of bytes
     to be transferred. When invoked, it will always report the most up-to-date number
     of transferrable bytes out of that original number of transferrable bytes.

     When the number of transferred bytes reaches or exceeds the
     number of transferrable bytes, the block will be unregistered.
     */
    RLMSyncProgressForCurrentlyOutstandingWork,
};

@class RLMSyncUser, RLMSyncConfiguration;

/**
 The type of a progress notification block intended for reporting a session's network
 activity to the user.

 `transferredBytes` refers to the number of bytes that have been uploaded or downloaded.
 `transferrableBytes` refers to the total number of bytes transferred, and pending transfer.
 */
typedef void(^RLMProgressNotificationBlock)(NSUInteger transferredBytes, NSUInteger transferrableBytes);

NS_ASSUME_NONNULL_BEGIN

/**
 A token object corresponding to a progress notification block on an `RLMSyncSession`.

 To stop notifications manually, call `-stop` on it. Notifications should be stopped before
 the token goes out of scope or is destroyed.
 */
@interface RLMProgressNotificationToken : RLMNotificationToken
@end

/**
 An object encapsulating a Realm Object Server "session". Sessions represent the
 communication between the client (and a local Realm file on disk), and the server
 (and a remote Realm at a given URL stored on a Realm Object Server).

 Sessions are always created by the SDK and vended out through various APIs. The lifespans
 of sessions associated with Realms are managed automatically.
 */
@interface RLMSyncSession : NSObject

/// The session's current state.
@property (nonatomic, readonly) RLMSyncSessionState state;

/// The Realm Object Server URL of the remote Realm this session corresponds to.
@property (nullable, nonatomic, readonly) NSURL *realmURL;

/// The user that owns this session.
- (nullable RLMSyncUser *)parentUser;

/**
 If the session is valid, return a sync configuration that can be used to open the Realm
 associated with this session.
 */
- (nullable RLMSyncConfiguration *)configuration;

/**
 Register a progress notification block.

 Multiple blocks can be registered with the same session at once. Each block
 will be invoked on a side queue devoted to progress notifications.
 
 If the session has already received progress information from the
 synchronization subsystem, the block will be called immediately. Otherwise, it
 will be called as soon as progress information becomes available.

 The token returned by this method must be retained as long as progress
 notifications are desired, and the `-stop` method should be called on it
 when notifications are no longer needed and before the token is destroyed.

 If no token is returned, the notification block will never be called again.
 There are a number of reasons this might be true. If the session has previously
 experienced a fatal error it will not accept progress notification blocks. If
 the block was configured in the `RLMSyncProgressForCurrentlyOutstandingWork`
 mode but there is no additional progress to report (for example, the number
 of transferrable bytes and transferred bytes are equal), the block will not be
 called again.

 @param direction The transfer direction (upload or download) to track in this progress notification block.
 @param mode      The desired behavior of this progress notification block.
 @param block     The block to invoke when notifications are available.

 @return A token which must be held for as long as you want notifications to be delivered.

 @see `RLMSyncProgressDirection`, `RLMSyncProgress`, `RLMProgressNotificationBlock`, `RLMProgressNotificationToken`
 */
- (nullable RLMProgressNotificationToken *)addProgressNotificationForDirection:(RLMSyncProgressDirection)direction
                                                                          mode:(RLMSyncProgress)mode
                                                                         block:(RLMProgressNotificationBlock)block
NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
