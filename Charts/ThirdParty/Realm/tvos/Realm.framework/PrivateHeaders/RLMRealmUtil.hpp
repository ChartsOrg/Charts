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
#import <memory>
#import <string>

@class RLMRealm;

namespace realm {
    class BindingContext;
}

// Add a Realm to the weak cache
void RLMCacheRealm(std::string const& path, RLMRealm *realm);
// Get a Realm for the given path which can be used on the current thread
RLMRealm *RLMGetThreadLocalCachedRealmForPath(std::string const& path);
// Get a Realm for the given path
RLMRealm *RLMGetAnyCachedRealmForPath(std::string const& path);
// Clear the weak cache of Realms
void RLMClearRealmCache();

// Install an uncaught exception handler that cancels write transactions
// for all cached realms on the current thread
void RLMInstallUncaughtExceptionHandler();

std::unique_ptr<realm::BindingContext> RLMCreateBindingContext(RLMRealm *realm);
