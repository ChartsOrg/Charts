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

#import "RLMSyncPermissionOffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLMSyncPermissionOffer()

@property (readwrite) NSString *id;
@property (readwrite) NSDate *createdAt;
@property (readwrite) NSDate *updatedAt;
@property (nullable, readwrite) NSNumber<RLMInt> *statusCode;
@property (nullable, readwrite) NSString *statusMessage;

@property (nullable, readwrite) NSString *token;
@property (readwrite) NSString *realmUrl;

@property (readwrite) BOOL mayRead;
@property (readwrite) BOOL mayWrite;
@property (readwrite) BOOL mayManage;

@property (nullable, readwrite) NSDate *expiresAt;

@end

NS_ASSUME_NONNULL_END
