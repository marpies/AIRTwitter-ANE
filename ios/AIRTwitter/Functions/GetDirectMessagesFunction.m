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

#import "GetDirectMessagesFunction.h"
#import "MPFREObjectUtils.h"
#import "AIRTwitter.h"
#import "DirectMessageUtils.h"
#import "AIRTwitterEvent.h"
#import "MPStringUtils.h"

FREObject tw_getDirectMessages( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* count = [NSString stringWithFormat:@"%d", [MPFREObjectUtils getInt:argv[0]]];
    NSString* sinceID = (argv[1] == nil) ? nil : [MPFREObjectUtils getNSString:argv[1]];
    NSString* maxID = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString:argv[2]];
    int callbackID = [MPFREObjectUtils getInt:argv[3]];
    
    [[AIRTwitter api] getDirectMessagesSinceID:sinceID maxID:maxID count:count fullText:@(1) includeEntities:@(0) skipStatus:@(1) successBlock:^(NSArray *messages) {
        [DirectMessageUtils dispatchDirectMesages:messages callbackID:callbackID];
    } errorBlock:^(NSError *error) {
        [AIRTwitter dispatchEvent:DIRECT_MESSAGES_QUERY_ERROR withMessage:[MPStringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
    }];
    
    return nil;
}