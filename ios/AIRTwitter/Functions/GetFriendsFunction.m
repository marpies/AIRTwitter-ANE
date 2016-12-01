/**
 * Copyright 2015-2016 Marcel Piestansky (http://marpies.com)
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

#import "GetFriendsFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "AIRTwitter.h"
#import "UserUtils.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitterEvent.h"

FREObject tw_getFriends( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* cursor = [NSString stringWithFormat:@"%.f", [MPFREObjectUtils getDouble:argv[0]]];
    double userIDDouble = [MPFREObjectUtils getDouble:argv[1]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : [[AIRTwitter api] userID];
    NSString* screenName = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    int callbackID = [MPFREObjectUtils getInt:argv[3]];

    [[AIRTwitter api] getFriendsListForUserID:(screenName ? nil : userID)
                                 orScreenName:screenName
                                       cursor:cursor
                                        count:@"20"
                                   skipStatus:@(1)
                          includeUserEntities:nil
                                 successBlock:^(NSArray* users, NSString* previousCursor, NSString* nextCursor) {
                                     [UserUtils dispatchUsers:users previousCursor:previousCursor nextCursor:nextCursor callbackID:callbackID];
                                 }
                                   errorBlock:^(NSError* error) {
                                       [AIRTwitter log:[NSString stringWithFormat:@"Friends error: %@", error.localizedDescription]];
                                       [AIRTwitter dispatchEvent:USERS_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                   }];

    return nil;
}