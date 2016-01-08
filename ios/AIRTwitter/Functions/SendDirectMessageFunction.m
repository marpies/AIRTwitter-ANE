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
#import "MPFREObjectUtils.h"
#import "MPStringUtils.h"
#import "AIRTwitterEvent.h"
#import "StatusUtils.h"
#import "AIRTwitter.h"
#import "DirectMessageUtils.h"

FREObject tw_sendDirectMessage( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* text = [MPFREObjectUtils getNSString:argv[0]];
    double userIDDouble = [MPFREObjectUtils getDouble:argv[1]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : nil;
    NSString* screenName = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    int callbackID = [MPFREObjectUtils getInt:argv[3]];
    
    [[AIRTwitter api] postDirectMessage:text
                          forScreenName:screenName
                               orUserID:(screenName ? nil : userID)
                           successBlock:^(NSDictionary *message) {
//                               [AIR log:[NSString stringWithFormat:@"Success sending DM %@", message]];
                               NSMutableDictionary* dmJSON = [DirectMessageUtils getJSON:message];
                               dmJSON[@"callbackID"] = @(callbackID);
                               dmJSON[@"success"] = @(true);
                               NSString* resultJSON = [MPStringUtils getJSONString:dmJSON];
                               if( resultJSON ) {
                                   [AIRTwitter dispatchEvent:DIRECT_MESSAGE_QUERY_SUCCESS withMessage:resultJSON];
                               } else {
                                   [AIRTwitter dispatchEvent:DIRECT_MESSAGE_QUERY_SUCCESS withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Succesfully sent direct message but could not parse returned message data."]];
                               }
                           }
                             errorBlock:^(NSError *error) {
                                 [AIRTwitter log:[NSString stringWithFormat:@"Error sending DM %@", error.localizedDescription]];
                                 [AIRTwitter dispatchEvent:DIRECT_MESSAGE_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                             }];
    
    return nil;
}