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

#import <AIRExtHelpers/MPStringUtils.h>

@implementation StringUtils

+ (NSString*) getEventErrorJSONString:(int) callbackID errorMessage:(NSString*) errorMessage {
    return [NSString stringWithFormat:@"{ \"callbackID\": %d, \"errorMessage\": \"%@\" }", callbackID, errorMessage];
}

+ (NSString*) getJSONString:(NSDictionary*) json {
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if( !jsonData ) {
        [AIR log:[NSString stringWithFormat:@"Error creating json for %@: %@", json, error.localizedDescription]];
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end