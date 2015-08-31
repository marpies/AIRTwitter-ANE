/**
 * Copyright 2015 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "STTwitter.h"

@class AIRTwitterUser;

@interface AIRTwitter : NSObject

+ (BOOL) initWithConsumerKey:(NSString*) key consumerSecret:(NSString*) secret urlScheme:(NSString*) urlScheme;
+ (void) getAccessTokensForPIN:(NSString*) PIN;
+ (void) clearAccessTokens;

+ (STTwitterAPI*) api;
+ (STTwitterAPI*) api:(BOOL) newInstance;

+ (NSString*) urlScheme;
+ (NSString*) accessToken;
+ (NSString*) accessTokenSecret;

+ (BOOL) isLoginInProcess;
+ (void) setLoginInProcess:(BOOL) isLoginInProcess;

+ (AIRTwitterUser*) loggedInUser;
+ (void) setLoggedInUser:(AIRTwitterUser*) user;

@end
