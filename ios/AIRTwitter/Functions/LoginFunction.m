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

#import "AIR.h"
#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"
#import "STTwitter.h"
#import "LoginFunction.h"
#import "FREObjectUtils.h"

#import <UIKit/UIKit.h>

FREObject login(FREContext context, void* functionData, uint32_t argc, FREObject argv[]) {
    [AIR log:@"Attempting login"];

    if( [AIRTwitter accessToken] ) {
        [AIR log:@"User is already logged in."];
        [AIR dispatchEvent:LOGIN_ERROR withMessage:@"User is already logged in."];
    } else {
        [AIRTwitter setLoginInProcess:YES];
        [[AIRTwitter api:YES] postTokenRequest:^(NSURL* url, NSString* oauthToken) {
                    [[UIApplication sharedApplication] openURL:url];
                } authenticateInsteadOfAuthorize:NO
                                      forceLogin:@(NO)  // todo: parametrize
                                      screenName:nil
                                   oauthCallback:[NSString stringWithFormat:@"%@://twitter_access_tokens/", [AIRTwitter urlScheme]]
                                      errorBlock:^(NSError* error) {
                                          [AIR log:[NSString stringWithFormat:@"Error logging in: %@", error.localizedDescription]];
                                          [AIR dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
                                      }];
    }

    return nil;
}