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

#import "SendDirectMessageFunction.h"
#import "FREObjectUtils.h"
#import "StringUtils.h"
#import "AIRTwitterEvent.h"
#import "AIR.h"
#import "StatusUtils.h"
#import "AIRTwitter.h"
#import "DirectMessageUtils.h"

FREObject sendDirectMessage( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    NSString* text = [FREObjectUtils getNSString:argv[0]];
    double userIDDouble = [FREObjectUtils getDouble:argv[1]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : nil;
    NSString* screenName = (argv[2] == nil) ? nil : [FREObjectUtils getNSString:argv[2]];
    int callbackID = [FREObjectUtils getInt:argv[3]];
    
    [[AIRTwitter api] postDirectMessage:text
                          forScreenName:screenName
                               orUserID:(screenName ? nil : userID)
                           successBlock:^(NSDictionary *message) {
//                               [AIR log:[NSString stringWithFormat:@"Success sending DM %@", message]];
                               NSMutableDictionary* dmJSON = [DirectMessageUtils getJSON:message];
                               dmJSON[@"callbackID"] = @(callbackID);
                               dmJSON[@"success"] = @(true);
                               NSString* resultJSON = [StringUtils getJSONString:dmJSON];
                               if( resultJSON ) {
                                   [AIR dispatchEvent:DIRECT_MESSAGE_QUERY_SUCCESS withMessage:resultJSON];
                               } else {
                                   [AIR dispatchEvent:DIRECT_MESSAGE_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"Succesfully sent direct message but could not parse returned message data."]];
                               }
                           }
                             errorBlock:^(NSError *error) {
                                 [AIR log:[NSString stringWithFormat:@"Error sending DM %@", error.localizedDescription]];
                                 [AIR dispatchEvent:DIRECT_MESSAGE_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                             }];
    
    return nil;
}