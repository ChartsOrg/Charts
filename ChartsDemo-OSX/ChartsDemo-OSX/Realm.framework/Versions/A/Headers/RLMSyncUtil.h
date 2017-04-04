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

#import <Realm/RLMConstants.h>

/// A token originating from the Realm Object Server.
typedef NSString* RLMServerToken;

NS_ASSUME_NONNULL_BEGIN

/// A user info key for use with `RLMSyncErrorClientResetError`.
extern NSString *const kRLMSyncPathOfRealmBackupCopyKey;

/// A user info key for use with `RLMSyncErrorClientResetError`.
extern NSString *const kRLMSyncInitiateClientResetBlockKey;

/// The error domain string for all SDK errors related to synchronization functionality.
extern NSString *const RLMSyncErrorDomain;

/// An error which is related to authentication to a Realm Object Server.
typedef RLM_ERROR_ENUM(NSInteger, RLMSyncAuthError, RLMSyncErrorDomain) {
    /// An error that indicates that the provided credentials are invalid.
    RLMSyncAuthErrorInvalidCredential   = 611,

    /// An error that indicates that the user with provided credentials does not exist.
    RLMSyncAuthErrorUserDoesNotExist    = 612,

    /// An error that indicates that the user cannot be registered as it exists already.
    RLMSyncAuthErrorUserAlreadyExists   = 613,
};

/// An error which is related to synchronization with a Realm Object Server.
typedef RLM_ERROR_ENUM(NSInteger, RLMSyncError, RLMSyncErrorDomain) {
    /// An error that indicates that the response received from the authentication server was malformed.
    RLMSyncErrorBadResponse             = 1,

    /// An error that indicates that the supplied Realm path was invalid, or could not be resolved by the authentication
    /// server.
    RLMSyncErrorBadRemoteRealmPath      = 2,

    /// An error that indicates that the response received from the authentication server was an HTTP error code. The
    /// `userInfo` dictionary contains the actual error code value.
    RLMSyncErrorHTTPStatusCodeError     = 3,

    /// An error that indicates a problem with the session (a specific Realm opened for sync).
    RLMSyncErrorClientSessionError      = 4,

    /// An error that indicates a problem with a specific user.
    RLMSyncErrorClientUserError         = 5,

    /// An error that indicates an internal, unrecoverable error with the underlying synchronization engine.
    RLMSyncErrorClientInternalError     = 6,

    /**
     An error that indicates the Realm needs to be reset.

     A synced Realm may need to be reset because the Realm Object Server encountered an
     error and had to be restored from a backup. If the backup copy of the remote Realm
     is of an earlier version than the local copy of the Realm, the server will ask the
     client to reset the Realm.

     The reset process is as follows: the local copy of the Realm is copied into a recovery
     directory for safekeeping, and then deleted from the original location. The next time
     the Realm for that URL is opened, the Realm will automatically be re-downloaded from the
     Realm Object Server, and can be used as normal.

     Data written to the Realm after the local copy of the Realm diverged from the backup
     remote copy will be present in the local recovery copy of the Realm file. The
     re-downloaded Realm will initially contain only the data present at the time the Realm
     was backed up on the server.

     The client reset process can be initiated in one of two ways. The block provided in the
     `userInfo` dictionary under `kRLMSyncInitiateClientResetBlockKey` can be called to
     initiate the reset process. This block can be called any time after the error is
     received, but should only be called if and when your app closes and invalidates every
     instance of the offending Realm on all threads (note that autorelease pools may make this
     difficult to guarantee).

     If the block is not called, the client reset process will be automatically carried out
     the next time the app is launched and the `RLMSyncManager` singleton is accessed.

     The value for the `kRLMSyncPathOfRealmBackupCopyKey` key in the `userInfo` dictionary
     describes the path of the recovered copy of the Realm. This copy will not actually be
     created until the client reset process is initiated.

     @see: `-[NSError rlmSync_clientResetBlock]`, `-[NSError rlmSync_clientResetBackedUpRealmPath]`
     */
    RLMSyncErrorClientResetError        = 7,
};

/// An enum representing the different states a sync management object can take.
typedef NS_ENUM(NSUInteger, RLMSyncManagementObjectStatus) {
    /// The management object has not yet been processed by the object server.
    RLMSyncManagementObjectStatusNotProcessed,
    /// The operations encoded in the management object have been successfully
    /// performed by the object server.
    RLMSyncManagementObjectStatusSuccess,
    /**
     The operations encoded in the management object were not successfully
     performed by the object server.
     Refer to the `statusCode` and `statusMessage` properties for more details
     about the error.
     */
    RLMSyncManagementObjectStatusError,
};

NS_ASSUME_NONNULL_END
