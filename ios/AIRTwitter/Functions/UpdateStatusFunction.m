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

#import "AIR.h"
#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"
#import "UpdateStatusFunction.h"
#import "FREObjectUtils.h"
#import "MediaSource.h"
#import "MediaSourceProcessor.h"
#import "StringUtils.h"
#import "StatusUtils.h"

void updateStatusWith(NSString* text, int callbackID, NSString* inReplyToStatusID, NSArray* mediaIDs);

FREObject updateStatus(FREContext context, void* functionData, uint32_t argc, FREObject argv[]) {
    NSString* text = (argv[0] == nil) ? nil : [FREObjectUtils getNSString:argv[0]];
    int callbackID = [FREObjectUtils getInt:argv[1]];
    double statusIDDouble = [FREObjectUtils getDouble:argv[2]];
    NSString* inReplyToStatusID = (statusIDDouble >= 0) ? [NSString stringWithFormat:@"%.f", statusIDDouble] : nil;
    NSArray* mediaSources = (argv[3] == nil) ? nil : [FREObjectUtils getMediaSourcesArray:argv[3]];

    /* Create NSData out of media files and upload to twitter */
    if( mediaSources ) {
        [AIR log:@"Processing media..."];
        [MediaSourceProcessor process:mediaSources completionHandler:^(NSArray* mediaIDs, NSString* errorMessage) {
            if( errorMessage ) {
                [AIR log:errorMessage];
                [AIR dispatchEvent:STATUS_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:errorMessage]];
            } else {
                [AIR log:@"Successfully uploaded media to twitter - updating status now"];
                updateStatusWith(text, callbackID, inReplyToStatusID, mediaIDs);
            }
        }];
    }
    /* Share now without media */
    else {
        [AIR log:@"Sharing without media"];
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
                              trimUser:nil
                          successBlock:^(NSDictionary* status) {
                              [AIR log:[NSString stringWithFormat:@"Updated status w/ message %@", status[@"text"]]];
                              NSMutableDictionary* statusJSON = [StatusUtils getJSON:status];
                              statusJSON[@"callbackID"] = @(callbackID);
                              statusJSON[@"success"] = @"true";
                              /* Get JSON string from the status */
                              NSString* jsonString = [StringUtils getJSONString:statusJSON];
                              if( jsonString ) {
                                  [AIR dispatchEvent:STATUS_QUERY_SUCCESS withMessage:jsonString];
                              } else {
                                  [AIR dispatchEvent:STATUS_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"Status update succeeded but could not parse returned status."]];
                              }
                          }
                            errorBlock:^(NSError* error) {
                                [AIR log:[NSString stringWithFormat:@"Error updating status: %@", error.localizedDescription]];
                                [AIR dispatchEvent:STATUS_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
                            }];
}


