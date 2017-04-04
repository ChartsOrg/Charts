////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
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

/// NSError category extension providing methods to get data out of Realm's
/// "client reset" error.
@interface NSError (RLMSync)

/**
 Given a Realm Object Server client reset error, return the block that can
 be called to manually initiate the client reset process, or nil if the
 error isn't a client reset error.
 */
- (nullable void(^)(void))rlmSync_clientResetBlock NS_REFINED_FOR_SWIFT;

/**
 Given a Realm Object Server client reset error, return the path where the
 backup copy of the Realm will be placed once the client reset process is
 complete.
 */
- (nullable NSString *)rlmSync_clientResetBackedUpRealmPath NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
