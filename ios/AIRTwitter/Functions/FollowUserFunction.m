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

#import "FollowUserFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitter.h"
#import "AIR.h"
#import "StringUtils.h"
#import "UserUtils.h"
#import "AIRTwitterEvent.h"

FREObject followUser(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    double userIDDouble = [FREObjectUtils getDouble:argv[0]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : nil;
    NSString* screenName = (argv[1] == nil) ? nil : [FREObjectUtils getNSString:argv[1]];
    BOOL enableNotifications = [FREObjectUtils getBOOL:argv[2]];
    int callbackID = [FREObjectUtils getInt:argv[3]];

    [[AIRTwitter api] postFriendshipsCreateForScreenName:screenName
                                                orUserID:(screenName ? nil : userID)
                                     enableNotifications:@(enableNotifications)
                                            successBlock:^(NSDictionary* befriendedUser) {
                                                [AIR log:[NSString stringWithFormat:@"Success following user %@", befriendedUser[@"screen_name"]]];
                                                NSMutableDictionary* userJSON = [UserUtils getTrimmedJSON:befriendedUser];
                                                userJSON[@"callbackID"] = @(callbackID);
                                                userJSON[@"success"] = @(true);
                                                NSString* resultJSON = [StringUtils getJSONString:userJSON];
                                                if( resultJSON ) {
                                                    [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:resultJSON];
                                                } else {
                                                    [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"Follow query suceeded but could not parse returned user data."]];
                                                }
                                            }
                                              errorBlock:^(NSError* error) {
                                                  [AIR log:[NSString stringWithFormat:@"Error following user %@", error.localizedDescription]];
                                                  [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                              }];

    return nil;
}