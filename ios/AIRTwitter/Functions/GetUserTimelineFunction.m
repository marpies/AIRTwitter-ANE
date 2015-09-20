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

#import "GetUserTimelineFunction.h"
#import "FREObjectUtils.h"
#import "StringUtils.h"
#import "AIRTwitterEvent.h"
#import "AIR.h"
#import "StatusUtils.h"
#import "AIRTwitter.h"

FREObject getUserTimeline(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    NSString* count = [NSString stringWithFormat:@"%d", [FREObjectUtils getInt:argv[0]]];
    double sinceIDDouble = [FREObjectUtils getDouble:argv[1]];
    double maxIDDouble = [FREObjectUtils getDouble:argv[2]];
    NSString* sinceID = (sinceIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", sinceIDDouble] : nil;
    NSString* maxID = (maxIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", maxIDDouble] : nil;
    NSNumber* excludeReplies = @([FREObjectUtils getBOOL:argv[3]]);
    double userIDDouble = [FREObjectUtils getDouble:argv[4]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : [[AIRTwitter api] userID];
    NSString* screenName = (argv[5] == nil) ? nil : [FREObjectUtils getNSString:argv[5]];
    int callbackID = [FREObjectUtils getInt:argv[6]];

    [[AIRTwitter api] getStatusesUserTimelineForUserID:(screenName ? nil : userID)
                                            screenName:screenName
                                               sinceID:sinceID
                                                 count:count
                                                 maxID:maxID
                                              trimUser:@(0)
                                        excludeReplies:excludeReplies
                                    contributorDetails:nil
                                       includeRetweets:@(1)
                                          successBlock:^(NSArray* statuses) {
                                              [StatusUtils dispatchStatuses:statuses callbackID:callbackID];
                                          }
                                            errorBlock:^(NSError* error) {
                                                [AIR log:[NSString stringWithFormat:@"User timeline error: %@", error.localizedDescription]];
                                                [AIR dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                            }];
    return nil;
}