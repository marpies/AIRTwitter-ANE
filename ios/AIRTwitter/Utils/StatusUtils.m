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

#import "StatusUtils.h"
#import "AIRTwitterEvent.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "UserUtils.h"
#import "AIRTwitter.h"

@implementation StatusUtils

/**
 * Creates JSON from given response list and dispatches generic event.
 * Helper method for queries like getHomeTimeline, getLikes...
 */
+ (void) dispatchStatuses:(NSArray*) statuses callbackID:(int) callbackID {
    [AIRTwitter log:[NSString stringWithFormat:@"Got statuses query response with %lu tweets", (unsigned long) statuses.count]];
    /* Create array of statuses (tweets) */
    NSMutableArray* tweets = [[NSMutableArray alloc] init];
    for( NSUInteger i = 0; i < statuses.count; ++i ) {
        /* Unlike Twitter4J the replies are excluded already (if requested) */
//        [AIR log:[NSString stringWithFormat:@"Status: %@", statuses[i]]];
        /* Create JSON for the status and put it to the array */
        [tweets addObject:[self getJSON:statuses[i]]];
    }
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    result[@"statuses"] = tweets;
    result[@"listenerID"] = @(callbackID);
    NSString* resultJSON = [MPStringUtils getJSONString:result];
    if( resultJSON ) {
        [AIRTwitter dispatchEvent:TIMELINE_QUERY_SUCCESS withMessage:resultJSON];
    } else {
        [AIRTwitter dispatchEvent:TIMELINE_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Statuses query succeeded but could not parse returned data."]];
    }
}

+ (NSMutableDictionary*) getJSON:(NSDictionary*) status {
    NSNumber* isSensitive = status[@"possibly_sensitive"];
    NSMutableDictionary* statusJSON = [[NSMutableDictionary alloc] init];
    statusJSON[@"id"] = status[@"id"];
    statusJSON[@"idStr"] = status[@"id_str"];
    statusJSON[@"text"] = status[@"text"];
    statusJSON[@"inReplyToUserID"] = status[@"in_reply_to_user_id"];
    statusJSON[@"inReplyToStatusID"] = status[@"in_reply_to_status_id"];
    statusJSON[@"likesCount"] = status[@"favorite_count"];
    statusJSON[@"retweetCount"] = status[@"retweet_count"];
    statusJSON[@"isRetweet"] = status[@"retweeted"];
    statusJSON[@"isSensitive"] = isSensitive ? isSensitive : @(0);
    statusJSON[@"createdAt"] = status[@"created_at"];
    id retweetedStatus = status[@"retweeted_status"];
    if( retweetedStatus ) {
        statusJSON[@"retweetedStatus"] = [self getJSON:retweetedStatus];
    }
    id user = status[@"user"];
    if( user ) {
        statusJSON[@"user"] = [UserUtils getTrimmedJSON:user];
    }
    return statusJSON;
}

@end