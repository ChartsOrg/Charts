////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
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

@class RLMRealm;
@class RLMSchema;
@class RLMObjectSchema;

/// :nodoc:
@interface RLMObjectBase : NSObject

@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

+ (NSString *)className;

// Returns whether the class is included in the default set of classes managed by a Realm.
+ (BOOL)shouldIncludeInDefaultSchema;

@end

NS_ASSUME_NONNULL_END
