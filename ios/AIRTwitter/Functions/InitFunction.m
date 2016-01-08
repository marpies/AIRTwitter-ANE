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

#import "AIRTwitter.h"
#import "InitFunction.h"
#import "MPFREObjectUtils.h"
#import "AIRTwitterEvent.h"

FREObject tw_init( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* key = [MPFREObjectUtils getNSString:argv[0]];
    NSString* secret = [MPFREObjectUtils getNSString:argv[1]];
    NSString* urlScheme = [MPFREObjectUtils getNSString:argv[2]];
    BOOL showLogs = [MPFREObjectUtils getBOOL:argv[3]];
    
    [AIRTwitter showLogs:showLogs];
    /* If cached access tokens exist then verify credentials */
    if( [AIRTwitter initWithConsumerKey:key consumerSecret:secret urlScheme: urlScheme] ) {
        [[AIRTwitter api] verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            [AIRTwitter log:@"Verify credentials success"];
            [AIRTwitter dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"valid\" }"]];
        } errorBlock:^(NSError *error) {
            [AIRTwitter log:[NSString stringWithFormat:@"Verify credentials error %@", [error localizedDescription]]];
            [AIRTwitter dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"invalid\" }"]];
        }];
    } else {
        [AIRTwitter dispatchEvent:CREDENTIALS_CHECK withMessage:[NSString stringWithFormat:@"{ \"result\": \"missing\" }"]];
    }
    
    return nil;
}