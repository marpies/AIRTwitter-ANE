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

#import "UserUtils.h"
#import "AIRTwitterUser.h"
#import "MPStringUtils.h"
#import "AIRTwitterEvent.h"
#import "AIRTwitter.h"


@implementation UserUtils

/**
 * Creates JSON from given response list and dispatches generic event.
 * Helper method for queries like getFollowers and getFriends.
 */
+ (void) dispatchUsers:(NSArray*) users previousCursor:(NSString*) previousCursor nextCursor:(NSString*) nextCursor callbackID:(int) callbackID {
    [AIRTwitter log:[NSString stringWithFormat:@"Got users query response with %lu user(s)", users.count]];
    /* Create array of JSON users */
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    for( NSUInteger i = 0; i < users.count; i++ ) {
        /* Create trimmed JSON for each user and put it to the array */
        [jsonArray addObject:[self getTrimmedJSON:users[i]]];
    }
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    if( previousCursor && ![previousCursor isEqualToString:@"0"] ) {
        result[@"previousCursor"] = previousCursor;
    }
    if( nextCursor && ![nextCursor isEqualToString:@"0"] ) {
        result[@"nextCursor"] = nextCursor;
    }
    result[@"callbackID"] = @(callbackID);
    result[@"users"] = jsonArray;
    /* Dispatch result in JSON format */
    NSString* resultJSON = [MPStringUtils getJSONString:result];
    if( resultJSON ) {
        [AIRTwitter dispatchEvent:USERS_QUERY_SUCCESS withMessage:resultJSON];
    } else {
        [AIRTwitter dispatchEvent:USERS_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:@"Users query succeeded but could not parse returned data."]];
    }
}

+ (NSMutableDictionary*) getJSON:(AIRTwitterUser*) user {
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    json[@"id"] = user.id;
    json[@"screenName"] = user.screenName;
    json[@"name"] = user.name;
    json[@"createdAt"] = user.createdAt;
    json[@"description"] = user.description;
    json[@"tweetsCount"] = user.tweetsCount;
    json[@"likesCount"] = user.likesCount;
    json[@"followersCount"] = user.followersCount;
    json[@"friendsCount"] = user.friendsCount;
    json[@"profileImageURL"] = user.profileImageURL;
    json[@"isProtected"] = @(user.isProtected);
    json[@"isVerified"] = @(user.isVerified);
    json[@"location"] = user.location;
    return json;
}

+ (NSMutableDictionary*) getTrimmedJSON:(NSDictionary*) json {
    NSMutableDictionary* userJSON = [[NSMutableDictionary alloc] init];
    userJSON[@"id"] = json[@"id_str"];
    userJSON[@"name"] = json[@"name"];
    userJSON[@"screenName"] = json[@"screen_name"];
    userJSON[@"createdAt"] = json[@"created_at"];
    userJSON[@"description"] = json[@"description"];
    userJSON[@"tweetsCount"] = json[@"statuses_count"];
    userJSON[@"likesCount"] = json[@"favourites_count"];
    userJSON[@"followersCount"] = json[@"followers_count"];
    userJSON[@"friendsCount"] = json[@"friends_count"];
    userJSON[@"profileImageURL"] = json[@"profile_image_url_https"];
    userJSON[@"isProtected"] = json[@"protected"];
    userJSON[@"isVerified"] = json[@"verified"];
    userJSON[@"location"] = json[@"location"];
    return userJSON;
}

+ (AIRTwitterUser*) getUser:(NSDictionary*) json {
    AIRTwitterUser* user = [[AIRTwitterUser alloc] init];
    user.id = json[@"id_str"];
    user.name = json[@"name"];
    user.screenName = json[@"screen_name"];
    user.createdAt = json[@"created_at"];
    user.description = json[@"description"];
    user.tweetsCount = json[@"statuses_count"];
    user.likesCount = json[@"favourites_count"];
    user.followersCount = json[@"followers_count"];
    user.friendsCount = json[@"friends_count"];
    user.profileImageURL = json[@"profile_image_url_https"];
    user.isProtected = [json[@"protected"] boolValue];
    user.isVerified = [json[@"verified"] boolValue];
    user.location = json[@"location"];
    return user;
}


@end