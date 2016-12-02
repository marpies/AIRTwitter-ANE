/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
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

#import "RequestAccountAccessFunction.h"
#import <Accounts/Accounts.h>
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"

FREObject tw_requestAccountAccess( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    int callbackID = [MPFREObjectUtils getInt:argv[0]];
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    [accountStore requestAccessToAccountsWithType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]
                                          options:nil completion:^(BOOL granted, NSError *error) {
                                              NSMutableDictionary* response = [NSMutableDictionary dictionary];
                                              response[@"granted"] = @(granted);
                                              response[@"listenerID"] = @(callbackID);
                                              if( granted ) {
                                                  [AIRTwitter log:@"Granted access to system accounts"];
                                                  [AIRTwitter dispatchEvent:ACCESS_SYSTEM_ACCOUNTS withMessage:[MPStringUtils getJSONString:response]];
                                              } else {
                                                  [AIRTwitter log:@"Access to system accounts denied"];
                                                  [AIRTwitter dispatchEvent:ACCESS_SYSTEM_ACCOUNTS withMessage:[MPStringUtils getJSONString:response]];
                                              }
                                          }];
    return nil;
}
