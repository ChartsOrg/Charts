////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
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

@class RLMObject;

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#pragma mark - Generics

#if __has_extension(objc_generics)
#define RLM_GENERIC(...) <__VA_ARGS__>
#define RLM_GENERIC_COLLECTION <RLMObjectType: RLMObject *>
#define RLM_GENERIC_RETURN <RLMObjectType>
#define RLMObjectArgument RLMObjectType
#else
#define RLM_GENERIC(...)
#define RLM_GENERIC_COLLECTION
#define RLM_GENERIC_RETURN
typedef id RLMObjectType;
typedef RLMObject * RLMObjectArgument;
#endif

#pragma mark - Nullability

#if !__has_feature(nullability)
#ifndef __nullable
#define __nullable
#endif
#ifndef __nonnull
#define __nonnull
#endif
#ifndef __null_unspecified
#define __null_unspecified
#endif
#ifndef nullable
#define nullable
#endif
#ifndef nonnull
#define nonnull
#endif
#ifndef null_unspecified
#define null_unspecified
#endif
#endif

#if defined(NS_ASSUME_NONNULL_BEGIN) && defined(NS_ASSUME_NONNULL_END)
#define RLM_ASSUME_NONNULL_BEGIN NS_ASSUME_NONNULL_BEGIN
#define RLM_ASSUME_NONNULL_END NS_ASSUME_NONNULL_END
#else
#define RLM_ASSUME_NONNULL_BEGIN
#define RLM_ASSUME_NONNULL_END
#endif

#pragma mark - Escaping

#if __has_attribute(noescape)
#  define RLM_NOESCAPE __attribute__((noescape))
#else
#  define RLM_NOESCAPE
#endif

#pragma mark - Unused Result

#if __has_attribute(warn_unused_result)
#  define RLM_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
#  define RLM_WARN_UNUSED_RESULT
#endif

#pragma mark - Swift Availability

#if defined(NS_SWIFT_UNAVAILABLE)
#  define RLM_SWIFT_UNAVAILABLE(msg) NS_SWIFT_UNAVAILABLE(msg)
#else
#  define RLM_SWIFT_UNAVAILABLE(msg)
#endif
