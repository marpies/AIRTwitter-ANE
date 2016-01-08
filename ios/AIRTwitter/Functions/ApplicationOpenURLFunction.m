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
#import "MPFREObjectUtils.h"
#import "ApplicationOpenURLFunction.h"
#import "AIRTwitterEvent.h"

NSDictionary* parametersDictionaryFromQueryString( NSString* queryString ) {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for( NSString *s in queryComponents ) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

FREObject tw_applicationOpenURL( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    NSString* url = [MPFREObjectUtils getNSString:argv[0]];
    NSURL* nsURL = [NSURL URLWithString:url];
    NSDictionary* urlParams = parametersDictionaryFromQueryString( nsURL.query );

//    NSString* token = d[@"oauth_token"];
    NSString* verifier = urlParams[@"oauth_verifier"];  // PIN
    NSString* denied = urlParams[@"denied"];

    if( denied || !verifier ) {
        [AIRTwitter log:@"App was launched after cancelled attempt to login"];
        [AIRTwitter dispatchEvent:LOGIN_CANCEL];
        return nil;
    }

    [AIRTwitter getAccessTokensForPIN:verifier];
    
    return nil;
}