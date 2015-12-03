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

#import "GetHomeTimelineFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitter.h"
#import "StatusUtils.h"
#import "AIR.h"
#import "AIRTwitterEvent.h"
#import "StringUtils.h"

FREObject getHomeTimeline(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    NSString* count = [NSString stringWithFormat:@"%d", [FREObjectUtils getInt:argv[0]]];
    NSString* sinceID = (argv[1] == nil) ? nil : [FREObjectUtils getNSString:argv[1]];
    NSString* maxID = (argv[2] == nil) ? nil : [FREObjectUtils getNSString:argv[2]];
    NSNumber* excludeReplies = @([FREObjectUtils getBOOL:argv[3]]);
    int callbackID = [FREObjectUtils getInt:argv[4]];

    [[AIRTwitter api] getStatusesHomeTimelineWithCount:count
                                               sinceID:sinceID
                                                 maxID:maxID
                                              trimUser:@(0)
                                        excludeReplies:excludeReplies
                                    contributorDetails:nil
                                       includeEntities:nil
                                          successBlock:^(NSArray* statuses) {
                                              [StatusUtils dispatchStatuses:statuses callbackID:callbackID];
                                          }
                                            errorBlock:^(NSError* error) {
                                                [AIR log:[NSString stringWithFormat:@"Home timeline error: %@", error.localizedDescription]];
                                                [AIR dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                            }];
    return nil;
}