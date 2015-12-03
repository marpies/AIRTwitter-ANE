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

#import "RetweetStatusFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitter.h"
#import "AIR.h"
#import "StatusUtils.h"
#import "StringUtils.h"
#import "AIRTwitterEvent.h"

FREObject retweetStatus(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    NSString* statusID = [FREObjectUtils getNSString:argv[0]];
    int callbackID = [FREObjectUtils getInt:argv[1]];

    [[AIRTwitter api] postStatusRetweetWithID:statusID
                                 successBlock:^(NSDictionary* status) {
                                     [AIR log:[NSString stringWithFormat:@"Retweeted status w/ message %@", status[@"text"]]];
                                     NSMutableDictionary* statusJSON = [StatusUtils getJSON:status];
                                     statusJSON[@"callbackID"] = @(callbackID);
                                     statusJSON[@"success"] = @"true";
                                     /* Get JSON string from the status */
                                     NSString* jsonString = [StringUtils getJSONString:statusJSON];
                                     if( jsonString ) {
                                         [AIR dispatchEvent:STATUS_QUERY_SUCCESS withMessage:jsonString];
                                     } else {
                                         [AIR dispatchEvent:STATUS_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"Successfully retweeted status but could not parse returned status data."]];
                                     }
                                 }
                                   errorBlock:^(NSError* error) {
                                       [AIR log:[NSString stringWithFormat:@"Error retweeting status: %@", error.localizedDescription]];
                                       [AIR dispatchEvent:STATUS_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                                   }];
    return nil;
}