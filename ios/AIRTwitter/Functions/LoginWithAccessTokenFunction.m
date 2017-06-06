/**
 * Copyright 2017 Marcel Piestansky (http://marpies.com)
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

#import "LoginWithAccessTokenFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"

FREObject tw_loginWithAccessToken( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [AIRTwitter log:@"Attempting login with access token"];
    
    AIRTwitter* twitter = [AIRTwitter sharedInstance];
    
    if( [twitter accessToken] ) {
        [AIRTwitter log:@"User is already logged in."];
        [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:@"User is already logged in."];
    } else {
        /* Set the access token and secret and verify it */
        NSString* token = [MPFREObjectUtils getNSString:argv[0]];
        NSString* secret = [MPFREObjectUtils getNSString:argv[1]];
        
        [AIRTwitter log:@"Setting existing token / secret and verifying"];
        
        STTwitterAPI* api = [twitter setAccessToken:token secret:secret];
        
        [api verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            [twitter storeCredentials:username userID:userID accessToken:token accessTokenSecret:secret];
            [AIRTwitter log:[NSString stringWithFormat:@"Custom token / secret is valid for user: %@", username]];
            [AIRTwitter dispatchEvent:LOGIN_SUCCESS];
        } errorBlock:^(NSError *error) {
            [AIRTwitter log:[NSString stringWithFormat:@"Verify credentials error %@", [error localizedDescription]]];
            [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:[error localizedDescription]];
        }];
    }
    return nil;
}
