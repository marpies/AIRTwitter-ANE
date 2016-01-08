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

#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"
#import "UpdateStatusFunction.h"
#import "MPFREObjectUtils.h"
#import "MediaSourceProcessor.h"
#import "MPStringUtils.h"
#import "StatusUtils.h"

void updateStatusWith(NSString* text, int callbackID, NSString* inReplyToStatusID, NSArray* mediaIDs);

FREObject tw_updateStatus( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* text = (argv[0] == nil) ? nil : [MPFREObjectUtils getNSString:argv[0]];
    int callbackID = [MPFREObjectUtils getInt:argv[1]];
    NSString* inReplyToStatusID = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    NSArray* mediaSources = (argv[3] == nil) ? nil : [MPFREObjectUtils getMediaSourcesArray:argv[3]];

    /* Create NSData out of media files and upload to twitter */
    if( mediaSources ) {
        [AIRTwitter log:@"Processing media..."];
        [MediaSourceProcessor process:mediaSources completionHandler:^(NSArray* mediaIDs, NSString* errorMessage) {
            if( errorMessage ) {
                [AIRTwitter log:errorMessage];
                [AIRTwitter dispatchEvent:STATUS_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:errorMessage]];
            } else {
                [AIRTwitter log:@"Successfully uploaded media to twitter - updating status now"];
                updateStatusWith(text, callbackID, inReplyToStatusID, mediaIDs);
            }
        }];
    }
    /* Share now without media */
    else {
        [AIRTwitter log:@"Sharing without media"];
        updateStatusWith(text, callbackID, inReplyToStatusID, nil);
    }

    return nil;
}

void updateStatusWith(NSString* text, int callbackID, NSString* inReplyToStatusID, NSArray* mediaIDs) {
    [[AIRTwitter api] postStatusUpdate:text
                     inReplyToStatusID:inReplyToStatusID
                              mediaIDs:mediaIDs
                              latitude:nil
                             longitude:nil
                               placeID:nil
                    displayCoordinates:nil
                              trimUser:@(0)
                          successBlock:^(NSDictionary* status) {
                              [AIRTwitter log:[NSString stringWithFormat:@"Updated status w/ message %@", status[@"text"]]];
                              NSMutableDictionary* statusJSON = [StatusUtils getJSON:status];
                              statusJSON[@"callbackID"] = @(callbackID);
                              statusJSON[@"success"] = @"true";
                              /* Get JSON string from the status */
                              NSString* jsonString = [MPStringUtils getJSONString:statusJSON];
                              if( jsonString ) {
                                  [AIRTwitter dispatchEvent:STATUS_QUERY_SUCCESS withMessage:jsonString];
                              } else {
                                  [AIRTwitter dispatchEvent:STATUS_QUERY_SUCCESS withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Status update succeeded but could not parse returned status."]];
                              }
                          }
                            errorBlock:^(NSError* error) {
                                [AIRTwitter log:[NSString stringWithFormat:@"Error updating status: %@", error.localizedDescription]];
                                [AIRTwitter dispatchEvent:STATUS_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                            }];
}


