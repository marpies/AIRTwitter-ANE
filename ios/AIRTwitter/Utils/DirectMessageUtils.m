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

#import "DirectMessageUtils.h"
#import "UserUtils.h"
#import "AIRTwitterEvent.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRTwitter.h"

@implementation DirectMessageUtils

/**
 * Creates JSON from given response list and dispatches generic event.
 * Helper method for queries like getDirectMessages, getSentDirectMessages...
 */
+ (void) dispatchDirectMesages:(NSArray*) messages callbackID:(int) callbackID {
    [AIRTwitter log:[NSString stringWithFormat:@"Got DMs query response with %lu messages", (unsigned long) messages.count]];
    /* Create array of direct messages */
    NSMutableArray* dms = [[NSMutableArray alloc] init];
    for( NSUInteger i = 0; i < messages.count; ++i ) {
//        [AIR log:[NSString stringWithFormat:@"DM: %@", messages[i]]];
        /* Create JSON for the message and put it to the array */
        [dms addObject:[self getJSON:messages[i]]];
    }
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    result[@"messages"] = dms;
    result[@"listenerID"] = @(callbackID);
    NSString* resultJSON = [MPStringUtils getJSONString:result];
    if( resultJSON ) {
        [AIRTwitter dispatchEvent:DIRECT_MESSAGES_QUERY_SUCCESS withMessage:resultJSON];
    } else {
        [AIRTwitter dispatchEvent:DIRECT_MESSAGES_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Successfully retrieved direct messages but could not parse returned data."]];
    }
}

+ (NSMutableDictionary*) getJSON:(NSDictionary*) message {
    NSMutableDictionary* dmJSON = [[NSMutableDictionary alloc] init];
    dmJSON[@"id"] = message[@"id_str"];
    dmJSON[@"idStr"] = message[@"id_str"];
    dmJSON[@"text"] = message[@"text"];
    dmJSON[@"createdAt"] = message[@"created_at"];
    dmJSON[@"recipient"] = [UserUtils getTrimmedJSON:message[@"recipient"]];
    dmJSON[@"sender"] = [UserUtils getTrimmedJSON:message[@"sender"]];
    return dmJSON;
}

@end
