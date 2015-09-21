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

#import "LoginWithAccount.h"
#import "FREObjectUtils.h"
#import "AccountSelectionHelper.h"
#import "AIR.h"
#import "AIRTwitterEvent.h"
#import "AIRTwitter.h"

FREObject loginWithAccount( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    if( [AIRTwitter accessToken] ) {
        [AIR log:@"User is already logged in."];
        [AIR dispatchEvent:LOGIN_ERROR withMessage:@"User is already logged in."];
    } else {
        [AccountSelectionHelper selectAccount:^( ACAccount *account, BOOL wasCancelled, NSString *errorMessage ) {
            if( account ) {
                [AIR log:[NSString stringWithFormat:@"Selected account: %@ - verifying credentials", account.username]];
                [AIRTwitter verifySystemAccount:account];
            } else if( wasCancelled ) {
                [AIR log:@"Account selection was cancelled."];
                [AIR dispatchEvent:LOGIN_CANCEL];
            } else {
                [AIR log:[NSString stringWithFormat:@"Error using Twitter system account: %@", errorMessage]];
                [AIR dispatchEvent:LOGIN_ERROR withMessage:errorMessage];
            }
        }];
    }
    return nil;
}