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

#import <Realm/RLMRealmConfiguration.h>

#import "RLMSyncUtil.h"

@class RLMSyncConfiguration;

/// :nodoc:
@interface RLMRealmConfiguration (Sync)

NS_ASSUME_NONNULL_BEGIN

/**
 A configuration object representing configuration state for Realms intended to sync with a Realm Object Server.
 
 This property is mutually exclusive with both `inMemoryIdentifier` and `fileURL`; setting one will nil out the other
 two.
 
 @see `RLMSyncConfiguration`
 */
@property (nullable, nonatomic) RLMSyncConfiguration *syncConfiguration;

NS_ASSUME_NONNULL_END

@end
