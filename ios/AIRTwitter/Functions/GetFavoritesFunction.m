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

#import "GetFavoritesFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitter.h"
#import "StatusUtils.h"
#import "StringUtils.h"
#import "AIR.h"
#import "AIRTwitterEvent.h"

FREObject getFavorites(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    NSString* count = [NSString stringWithFormat:@"%d", [FREObjectUtils getInt:argv[0]]];
    double sinceIDDouble = [FREObjectUtils getDouble:argv[1]];
    double maxIDDouble = [FREObjectUtils getDouble:argv[2]];
    NSString* sinceID = (sinceIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", sinceIDDouble] : nil;
    NSString* maxID = (maxIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", maxIDDouble] : nil;
    double userIDDouble = [FREObjectUtils getDouble:argv[3]];
    NSString* userID = (userIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", userIDDouble] : [[AIRTwitter api] userID];
    NSString* screenName = (argv[4] == nil) ? nil : [FREObjectUtils getNSString:argv[4]];
    int callbackID = [FREObjectUtils getInt:argv[5]];

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
                                          [AIR log:[NSString stringWithFormat:@"GetFavorites error: %@", error.localizedDescription]];
                                          [AIR dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                      }];

    return nil;
}