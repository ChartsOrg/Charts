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

#import <Realm/RLMSyncUtil.h>

#import <Realm/RLMProperty.h>
#import <Realm/RLMRealmConfiguration.h>
#import <Realm/RLMSyncCredentials.h>

@class RLMSyncUser;

typedef void(^RLMSyncCompletionBlock)(NSError * _Nullable, NSDictionary * _Nullable);
typedef void(^RLMSyncBasicErrorReportingBlock)(NSError * _Nullable);

typedef NSString* RLMServerPath;

NS_ASSUME_NONNULL_BEGIN

@interface RLMRealmConfiguration (RealmSync)
+ (instancetype)managementConfigurationForUser:(RLMSyncUser *)user;
+ (instancetype)permissionConfigurationForUser:(RLMSyncUser *)user;
@end

extern RLMIdentityProvider const RLMIdentityProviderAccessToken;
extern RLMIdentityProvider const RLMIdentityProviderRealm;

extern NSString *const kRLMSyncAppIDKey;
extern NSString *const kRLMSyncDataKey;
extern NSString *const kRLMSyncErrorJSONKey;
extern NSString *const kRLMSyncErrorStatusCodeKey;
extern NSString *const kRLMSyncIdentityKey;
extern NSString *const kRLMSyncPasswordKey;
extern NSString *const kRLMSyncPathKey;
extern NSString *const kRLMSyncProviderKey;
extern NSString *const kRLMSyncRegisterKey;
extern NSString *const kRLMSyncUnderlyingErrorKey;

/// Convert sync management object status code (nil, 0 and others) to
/// RLMSyncManagementObjectStatus enum
FOUNDATION_EXTERN RLMSyncManagementObjectStatus RLMMakeSyncManagementObjectStatus(NSNumber<RLMInt> * _Nullable statusCode);

#define RLM_SYNC_UNINITIALIZABLE \
- (instancetype)init __attribute__((unavailable("This type cannot be created directly"))); \
+ (instancetype)new __attribute__((unavailable("This type cannot be created directly")));

NS_ASSUME_NONNULL_END

/// A macro to parse a string out of a JSON dictionary, or return nil.
#define RLM_SYNC_PARSE_STRING_OR_ABORT(json_macro_val, key_macro_val, prop_macro_val) \
{ \
id data = json_macro_val[key_macro_val]; \
if (![data isKindOfClass:[NSString class]]) { return nil; } \
self.prop_macro_val = data; \
} \

#define RLM_SYNC_PARSE_OPTIONAL_STRING(json_macro_val, key_macro_val, prop_macro_val) \
{ \
id data = json_macro_val[key_macro_val]; \
if (![data isKindOfClass:[NSString class]]) { data = nil; } \
self.prop_macro_val = data; \
} \

/// A macro to parse a double out of a JSON dictionary, or return nil.
#define RLM_SYNC_PARSE_DOUBLE_OR_ABORT(json_macro_val, key_macro_val, prop_macro_val) \
{ \
id data = json_macro_val[key_macro_val]; \
if (![data isKindOfClass:[NSNumber class]]) { return nil; } \
self.prop_macro_val = [data doubleValue]; \
} \

/// A macro to build a sub-model out of a JSON dictionary, or return nil.
#define RLM_SYNC_PARSE_MODEL_OR_ABORT(json_macro_val, key_macro_val, class_macro_val, prop_macro_val) \
{ \
id raw = json_macro_val[key_macro_val]; \
if (![raw isKindOfClass:[NSDictionary class]]) { return nil; } \
id model = [[class_macro_val alloc] initWithDictionary:raw]; \
if (!model) { return nil; } \
self.prop_macro_val = model; \
} \

#define RLM_SYNC_PARSE_OPTIONAL_MODEL(json_macro_val, key_macro_val, class_macro_val, prop_macro_val) \
{ \
id model; \
id raw = json_macro_val[key_macro_val]; \
if (![raw isKindOfClass:[NSDictionary class]]) { model = nil; } \
else { model = [[class_macro_val alloc] initWithDictionary:raw]; } \
self.prop_macro_val = model; \
} \
