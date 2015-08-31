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
#import "FREObjectUtils.h"
#import "GetFollowersFunction.h"
#import "StringUtils.h"
#import "UserUtils.h"

FREObject getFollowers(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    NSString* cursor = [NSString stringWithFormat:@"%.f", [FREObjectUtils getDouble:argv[0]]];
    double userIDDouble = [FREObjectUtils getDouble:argv[1]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : [[AIRTwitter api] userID];
    NSString* screenName = (argv[2] == nil) ? nil : [FREObjectUtils getNSString:argv[2]];
    int callbackID = [FREObjectUtils getInt:argv[3]];

    [[AIRTwitter api] getFollowersListForUserID:(screenName ? nil : userID)
                                   orScreenName:screenName
                                          count:@"20"
                                         cursor:cursor
                                     skipStatus:nil
                            includeUserEntities:nil
                                   successBlock:^(NSArray* users, NSString* previousCursor, NSString* nextCursor) {
                                       [UserUtils dispatchUsers:users previousCursor:previousCursor nextCursor:nextCursor callbackID:callbackID];
                                   } errorBlock:^(NSError* error) {
                [AIR log:[NSString stringWithFormat:@"Followers error: %@", error.localizedDescription]];
                [AIR dispatchEvent:USERS_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
            }];


    return nil;
}