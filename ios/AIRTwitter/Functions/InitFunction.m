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
#import "InitFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitterEvent.h"

FREObject init( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    NSString* key = [FREObjectUtils getNSString:argv[0]];
    NSString* secret = [FREObjectUtils getNSString:argv[1]];
    NSString* urlScheme = [FREObjectUtils getNSString:argv[2]];
    BOOL showLogs = [FREObjectUtils getBOOL:argv[3]];
    
    [AIR showLogs:showLogs];
    /* If cached access tokens exist then verify credentials */
    if( [AIRTwitter initWithConsumerKey:key consumerSecret:secret urlScheme: urlScheme] ) {
        [[AIRTwitter api] verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            [AIR log:@"Verify credentials success"];
            [AIR dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"valid\" }"]];
        } errorBlock:^(NSError *error) {
            [AIR log:[NSString stringWithFormat:@"Verify credentials error %@", [error localizedDescription]]];
            [AIR dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"invalid\" }"]];
        }];
    } else {
        [AIR dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"missing\" }"]];
    }
    
    return nil;
}