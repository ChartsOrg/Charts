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

NS_ASSUME_NONNULL_BEGIN

/// A token representing an identity provider's credentials.
typedef NSString *RLMSyncCredentialsToken;

/// A type representing the unique identifier of a Realm Object Server identity provider.
typedef NSString *RLMIdentityProvider RLM_EXTENSIBLE_STRING_ENUM;

/// The debug identity provider, which accepts any token string and creates a user associated with that token if one
/// does not yet exist. Not enabled for Realm Object Server configured for production.
extern RLMIdentityProvider const RLMIdentityProviderDebug;

/// The username/password identity provider. User accounts are handled by the Realm Object Server directly without the
/// involvement of a third-party identity provider.
extern RLMIdentityProvider const RLMIdentityProviderUsernamePassword;

/// A Facebook account as an identity provider.
extern RLMIdentityProvider const RLMIdentityProviderFacebook;

/// A Google account as an identity provider.
extern RLMIdentityProvider const RLMIdentityProviderGoogle;

/// A CloudKit account as an identity provider.
extern RLMIdentityProvider const RLMIdentityProviderCloudKit;

/**
 Opaque credentials representing a specific Realm Object Server user.
 */
@interface RLMSyncCredentials : NSObject

/// An opaque credentials token containing information that uniquely identifies a Realm Object Server user.
@property (nonatomic, readonly) RLMSyncCredentialsToken token;

/// The name of the identity provider which generated the credentials token.
@property (nonatomic, readonly) RLMIdentityProvider provider;

/// A dictionary containing additional pertinent information. In most cases this is automatically configured.
@property (nonatomic, readonly) NSDictionary<NSString *, id> *userInfo;

/**
 Construct and return credentials from a Facebook account token.
 */
+ (instancetype)credentialsWithFacebookToken:(RLMSyncCredentialsToken)token;

/**
 Construct and return credentials from a Google account token.
 */
+ (instancetype)credentialsWithGoogleToken:(RLMSyncCredentialsToken)token;

/**
 Construct and return credentials from an CloudKit account token.
 */
+ (instancetype)credentialsWithCloudKitToken:(RLMSyncCredentialsToken)token;

/**
 Construct and return credentials from a Realm Object Server username and password.
 */
+ (instancetype)credentialsWithUsername:(NSString *)username
                               password:(NSString *)password
                               register:(BOOL)shouldRegister;

/**
 Construct and return special credentials representing a token that can be directly used to open a Realm. The identity
 is used to uniquely identify the user across application launches.
 */
+ (instancetype)credentialsWithAccessToken:(RLMServerToken)accessToken identity:(NSString *)identity;

/**
 Construct and return credentials with a custom token string, identity provider string, and optional user info. In most
 cases, the convenience initializers should be used instead.
 */
- (instancetype)initWithCustomToken:(RLMSyncCredentialsToken)token
                           provider:(RLMIdentityProvider)provider
                           userInfo:(nullable NSDictionary *)userInfo NS_DESIGNATED_INITIALIZER;

/// :nodoc:
- (instancetype)init __attribute__((unavailable("RLMSyncCredentials cannot be created directly")));

/// :nodoc:
+ (instancetype)new __attribute__((unavailable("RLMSyncCredentials cannot be created directly")));

NS_ASSUME_NONNULL_END

@end
