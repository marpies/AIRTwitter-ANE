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

#import "UnfollowUserFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "AIRTwitter.h"
#import "UserUtils.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitterEvent.h"

FREObject tw_unfollowUser( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* userID = (argv[0] == nil) ? nil : [MPFREObjectUtils getNSString:argv[0]];
    NSString* screenName = (argv[1] == nil) ? nil : [MPFREObjectUtils getNSString:argv[1]];
    int callbackID = [MPFREObjectUtils getInt:argv[2]];

    [[[AIRTwitter sharedInstance] api] postFriendshipsDestroyScreenName:screenName
                                              orUserID:(screenName ? nil : userID)
                                          successBlock:^(NSDictionary* unfollowedUser) {
                                              [AIRTwitter log:[NSString stringWithFormat:@"Success unfollowing user %@", unfollowedUser[@"screen_name"]]];
                                              NSMutableDictionary* userJSON = [UserUtils getTrimmedJSON:unfollowedUser];
                                              userJSON[@"listenerID"] = @(callbackID);
                                              userJSON[@"success"] = @(true);
                                              NSString* resultJSON = [MPStringUtils getJSONString:userJSON];
                                              if( resultJSON ) {
                                                  [AIRTwitter dispatchEvent:USER_QUERY_SUCCESS withMessage:resultJSON];
                                              } else {
                                                  [AIRTwitter dispatchEvent:USER_QUERY_SUCCESS withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Unfollow query suceeded but could not parse returned user data."]];
                                              }
                                          }
                                            errorBlock:^(NSError* error) {
                                                [AIRTwitter log:[NSString stringWithFormat:@"Error unfollowing user %@", error.localizedDescription]];
                                                [AIRTwitter dispatchEvent:USER_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                            }];

    return nil;
}
