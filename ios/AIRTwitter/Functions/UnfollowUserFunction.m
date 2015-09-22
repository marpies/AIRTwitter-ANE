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

#import "UnfollowUserFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitter.h"
#import "UserUtils.h"
#import "AIR.h"
#import "StringUtils.h"
#import "AIRTwitterEvent.h"

FREObject unfollowUser(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    double userIDDouble = [FREObjectUtils getDouble:argv[0]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : nil;
    NSString* screenName = (argv[1] == nil) ? nil : [FREObjectUtils getNSString:argv[1]];
    int callbackID = [FREObjectUtils getInt:argv[2]];

    [[AIRTwitter api] postFriendshipsDestroyScreenName:screenName
                                              orUserID:(screenName ? nil : userID)
                                          successBlock:^(NSDictionary* unfollowedUser) {
                                              [AIR log:[NSString stringWithFormat:@"Success unfollowing user %@", unfollowedUser[@"screen_name"]]];
                                              NSMutableDictionary* userJSON = [UserUtils getTrimmedJSON:unfollowedUser];
                                              userJSON[@"callbackID"] = @(callbackID);
                                              userJSON[@"success"] = @(true);
                                              NSString* resultJSON = [StringUtils getJSONString:userJSON];
                                              if( resultJSON ) {
                                                  [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:resultJSON];
                                              } else {
                                                  [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"Unfollow query suceeded but could not parse returned user data."]];
                                              }
                                          }
                                            errorBlock:^(NSError* error) {
                                                [AIR log:[NSString stringWithFormat:@"Error unfollowing user %@", error.localizedDescription]];
                                                [AIR dispatchEvent:USER_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                            }];

    return nil;
}