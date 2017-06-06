/**
 * Copyright 2015-2016 Marcel Piestansky (http://marpies.com)
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
#import <AIRExtHelpers/MPUIApplicationListener.h>

@class AIRTwitterUser;

@interface AIRTwitter : NSObject<STTwitterAPIOSProtocol, MPUIApplicationListener>

+ (nonnull id) sharedInstance;
- (BOOL) initWithConsumerKey:(nullable NSString*) key consumerSecret:(nullable NSString*) secret urlScheme:(nullable NSString*) urlScheme;
- (nonnull STTwitterAPI*) setAccessToken:(nonnull NSString*) token secret:(nonnull NSString*) secret;
- (void) getAccessTokensForPIN:(nullable NSString*) PIN;
- (void) verifySystemAccount:(nullable ACAccount*) account;
- (void) clearAccessTokens;
- (void) storeCredentials:(nonnull NSString*) screenName userID:(nonnull NSString*) userID accessToken:(nonnull NSString*) accessToken accessTokenSecret:(nonnull NSString*) accessTokenSecret;

- (nonnull STTwitterAPI*) api;
- (nonnull STTwitterAPI*) api:(BOOL) newInstance;

- (nullable NSString*) urlScheme;
- (nullable NSString*) accessToken;
- (nullable NSString*) accessTokenSecret;
- (BOOL) isInitialized;

- (nullable AIRTwitterUser*) loggedInUser;
- (void) setLoggedInUser:(nullable AIRTwitterUser*) user;

/**
 * Helpers
 */

+ (void) dispatchEvent:(nonnull const NSString*) eventName;

+ (void) dispatchEvent:(nonnull const NSString*) eventName withMessage:(nonnull NSString*) message;

+ (void)log:(nonnull const NSString*) message;

+ (void)showLogs:(BOOL) showLogs;

@end
