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

#import "LikeStatusFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitterEvent.h"
#import "StatusUtils.h"
#import "AIRTwitter.h"

FREObject tw_likeStatus( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* statusID = [MPFREObjectUtils getNSString:argv[0]];
    int callbackID = [MPFREObjectUtils getInt:argv[1]];

    [[AIRTwitter api] postFavoriteCreateWithStatusID:statusID
                                     includeEntities:nil
                                        successBlock:^(NSDictionary* status) {
                                            [AIRTwitter log:[NSString stringWithFormat:@"Liked status w/ message %@", status[@"text"]]];
                                            NSMutableDictionary* statusJSON = [StatusUtils getJSON:status];
                                            statusJSON[@"listenerID"] = @(callbackID);
                                            statusJSON[@"success"] = @"true";
                                            /* Get JSON string from the status */
                                            NSString* jsonString = [MPStringUtils getJSONString:statusJSON];
                                            if( jsonString ) {
                                                [AIRTwitter dispatchEvent:STATUS_QUERY_SUCCESS withMessage:jsonString];
                                            } else {
                                                [AIRTwitter dispatchEvent:STATUS_QUERY_SUCCESS withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Successfully liked status but could not parse returned status data."]];
                                            }
                                        }
                                          errorBlock:^(NSError* error) {
                                              [AIRTwitter log:[NSString stringWithFormat:@"Error liking status: %@", error.localizedDescription]];
                                              [AIRTwitter dispatchEvent:STATUS_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                          }];
    return nil;
}