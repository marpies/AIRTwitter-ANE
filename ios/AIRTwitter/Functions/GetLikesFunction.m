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

#import "GetLikesFunction.h"
#import "MPStringUtils.h"
#import "MPFREObjectUtils.h"
#import "AIRTwitter.h"
#import "StatusUtils.h"
#import "AIRTwitterEvent.h"

FREObject tw_getLikes( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* count = [NSString stringWithFormat:@"%d", [MPFREObjectUtils getInt:argv[0]]];
    NSString* sinceID = (argv[1] == nil) ? nil : [MPFREObjectUtils getNSString:argv[1]];
    NSString* maxID = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    double userIDDouble = [MPFREObjectUtils getDouble:argv[3]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : [[AIRTwitter api] userID];
    NSString* screenName = (argv[4] == nil) ? nil : [MPFREObjectUtils getNSString:argv[4]];
    int callbackID = [MPFREObjectUtils getInt:argv[5]];

    [[AIRTwitter api] getFavoritesListWithUserID:(screenName ? nil : userID)
                                    orScreenName:screenName
                                           count:count
                                         sinceID:sinceID
                                           maxID:maxID
                                 includeEntities:nil
                                    successBlock:^(NSArray* statuses) {
                                        [StatusUtils dispatchStatuses:statuses callbackID:callbackID];
                                    }
                                      errorBlock:^(NSError* error) {
                                          [AIRTwitter log:[NSString stringWithFormat:@"GetLikes error: %@", error.localizedDescription]];
                                          [AIRTwitter dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                      }];

    return nil;
}