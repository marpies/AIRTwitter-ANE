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

#import "GetUserTimelineFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitterEvent.h"
#import "StatusUtils.h"
#import "AIRTwitter.h"

FREObject tw_getUserTimeline( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* count = [NSString stringWithFormat:@"%d", [MPFREObjectUtils getInt:argv[0]]];
    NSString* sinceID = (argv[1] == nil) ? nil : [MPFREObjectUtils getNSString:argv[1]];
    NSString* maxID = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    NSNumber* excludeReplies = @([MPFREObjectUtils getBOOL:argv[3]]);
    NSString* userID = (argv[4] == nil) ? [[[AIRTwitter sharedInstance] api] userID] : [MPFREObjectUtils getNSString:argv[4]];
    NSString* screenName = (argv[5] == nil) ? nil : [MPFREObjectUtils getNSString:argv[5]];
    int callbackID = [MPFREObjectUtils getInt:argv[6]];

    [[[AIRTwitter sharedInstance] api] getStatusesUserTimelineForUserID:(screenName ? nil : userID)
                                            screenName:screenName
                                               sinceID:sinceID
                                                 count:count
                                                 maxID:maxID
                                              trimUser:@(0)
                                        excludeReplies:excludeReplies
                                    contributorDetails:nil
                                       includeRetweets:@(1)
                                  useExtendedTweetMode:nil
                                          successBlock:^(NSArray* statuses) {
                                              [StatusUtils dispatchStatuses:statuses callbackID:callbackID];
                                          }
                                            errorBlock:^(NSError* error) {
                                                [AIRTwitter log:[NSString stringWithFormat:@"User timeline error: %@", error.localizedDescription]];
                                                [AIRTwitter dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                            }];
    return nil;
}
