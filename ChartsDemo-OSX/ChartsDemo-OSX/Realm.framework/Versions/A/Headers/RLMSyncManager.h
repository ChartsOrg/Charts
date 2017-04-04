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

#import "RLMSyncUtil.h"

@class RLMSyncSession;

/// An enum representing different levels of sync-related logging that can be configured.
typedef NS_ENUM(NSUInteger, RLMSyncLogLevel) {
    /// Nothing will ever be logged.
    RLMSyncLogLevelOff,
    /// Only fatal errors will be logged.
    RLMSyncLogLevelFatal,
    /// Only errors will be logged.
    RLMSyncLogLevelError,
    /// Warnings and errors will be logged.
    RLMSyncLogLevelWarn,
    /// Information about sync events will be logged. Fewer events will be logged in order to avoid overhead.
    RLMSyncLogLevelInfo,
    /// Information about sync events will be logged. More events will be logged than with `RLMSyncLogLevelInfo`.
    RLMSyncLogLevelDetail,
    /// Log information that can aid in debugging.
    ///
    /// - warning: Will incur a measurable performance impact.
    RLMSyncLogLevelDebug,
    /// Log information that can aid in debugging. More events will be logged than with `RLMSyncLogLevelDebug`.
    ///
    /// - warning: Will incur a measurable performance impact.
    RLMSyncLogLevelTrace,
    /// Log information that can aid in debugging. More events will be logged than with `RLMSyncLogLevelTrace`.
    ///
    /// - warning: Will incur a measurable performance impact.
    RLMSyncLogLevelAll
};

NS_ASSUME_NONNULL_BEGIN

/// A block type representing a block which can be used to report a sync-related error to the application. If the error
/// pertains to a specific session, that session will also be passed into the block.
typedef void(^RLMSyncErrorReportingBlock)(NSError *, RLMSyncSession * _Nullable);

/**
 A singleton manager which serves as a central point for sync-related configuration.
 */
@interface RLMSyncManager : NSObject

/**
 An optional block which can be used to report sync-related errors to your application. Errors reported through this
 mechanism are always fatal; they represent attempts to open sessions which are invalid (for example, using malformed
 URLs).
 */
@property (nullable, nonatomic, copy) RLMSyncErrorReportingBlock errorHandler;

/**
 A reverse-DNS string uniquely identifying this application. In most cases this is automatically set by the SDK, and
 does not have to be explicitly configured.
 */
@property (nonatomic, copy) NSString *appID;

/**
 Whether SSL certificate validation should be disabled. SSL certificate validation is ON by default. Setting this
 property after at least one synced Realm or standalone Session has been opened is a no-op.

 @warning NEVER disable certificate validation for clients and servers in production.
 */
@property (nonatomic) BOOL disableSSLValidation;

/**
 The logging threshold which newly opened synced Realms will use. Defaults to `RLMSyncLogLevelInfo`. Set this before
 any synced Realms are opened. Logging strings are output to ASL.
 */
@property (nonatomic) RLMSyncLogLevel logLevel;

/// The sole instance of the singleton.
+ (instancetype)sharedManager NS_REFINED_FOR_SWIFT;

/// :nodoc:
- (instancetype)init __attribute__((unavailable("RLMSyncManager cannot be created directly")));

/// :nodoc:
+ (instancetype)new __attribute__((unavailable("RLMSyncManager cannot be created directly")));

NS_ASSUME_NONNULL_END

@end
