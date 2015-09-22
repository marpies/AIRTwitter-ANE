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
#import "Functions/InitFunction.h"
#import "Functions/LoginFunction.h"
#import "Functions/LogoutFunction.h"
#import "Functions/UpdateStatusFunction.h"
#import "Functions/GetFollowersFunction.h"
#import "Functions/GetHomeTimelineFunction.h"
#import "Functions/GetUserTimelineFunction.h"
#import "Functions/GetFavoritesFunction.h"
#import "Functions/GetFriendsFunction.h"
#import "Functions/FollowUserFunction.h"
#import "Functions/UnfollowUserFunction.h"
#import "Functions/RetweetStatusFunction.h"
#import "Functions/FavoriteStatusFunction.h"
#import "Functions/UndoFavoriteStatusFunction.h"
#import "Functions/DeleteStatusFunction.h"
#import "Functions/SendDirectMessageFunction.h"
#import "Functions/GetDirectMessagesFunction.h"
#import "Functions/GetSentDirectMessagesFunction.h"
#import "Functions/GetLoggedInUserFunction.h"
#import "Functions/ApplicationOpenURLFunction.h"
#import "Functions/LoginWithAccount.h"
#import "Functions/IsSystemAccountAvailableFunction.h"

static BOOL logEnabled = NO;
FREContext extensionContext = nil;

@implementation AIR

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( extensionContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( logEnabled ) {
        NSLog( @"[iOS-AIRTwitter] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    logEnabled = showLogs;
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/

void AIRTwitterAddFunction( FRENamedFunction* array, const char* name, FREFunction function, uint32_t* index ) {
    array[(*index)].name = (const uint8_t*) name;
    array[(*index)].functionData = NULL;
    array[(*index)].function = function;
    (*index)++;
}

void AIRTwitterContextInitializer( void* extData,
                                  const uint8_t* ctxType,
                                  FREContext ctx,
                                  uint32_t* numFunctionsToSet,
                                  const FRENamedFunction** functionsToSet ) {
    uint32_t numFunctions = 22;
    *numFunctionsToSet = numFunctions;
    
    FRENamedFunction* functionArray = (FRENamedFunction*) malloc( sizeof( FRENamedFunction ) * numFunctions );
    
    uint32_t index = 0;
    AIRTwitterAddFunction( functionArray, "init", &init, &index );
    AIRTwitterAddFunction( functionArray, "login", &login, &index );
    AIRTwitterAddFunction( functionArray, "loginWithAccount", &loginWithAccount, &index );
    AIRTwitterAddFunction( functionArray, "logout", &logout, &index );

    AIRTwitterAddFunction( functionArray, "updateStatus", &updateStatus, &index );
    AIRTwitterAddFunction( functionArray, "getFollowers", &getFollowers, &index );
    AIRTwitterAddFunction( functionArray, "getHomeTimeline", &getHomeTimeline, &index );
    AIRTwitterAddFunction( functionArray, "getUserTimeline", &getUserTimeline, &index );
    AIRTwitterAddFunction( functionArray, "getFavorites", &getFavorites, &index );
    AIRTwitterAddFunction( functionArray, "getFriends", &getFriends, &index );
    AIRTwitterAddFunction( functionArray, "getLoggedInUser", &getLoggedInUser, &index );

    AIRTwitterAddFunction( functionArray, "followUser", &followUser, &index );
    AIRTwitterAddFunction( functionArray, "unfollowUser", &unfollowUser, &index );

    AIRTwitterAddFunction( functionArray, "retweetStatus", &retweetStatus, &index );
    AIRTwitterAddFunction( functionArray, "favoriteStatus", &favoriteStatus, &index );
    AIRTwitterAddFunction( functionArray, "undoFavoriteStatus", &undoFavoriteStatus, &index );
    AIRTwitterAddFunction( functionArray, "deleteStatus", &deleteStatus, &index );

    AIRTwitterAddFunction( functionArray, "sendDirectMessage", &sendDirectMessage, &index );
    AIRTwitterAddFunction( functionArray, "getDirectMessages", &getDirectMessages, &index );
    AIRTwitterAddFunction( functionArray, "getSentDirectMessages", &getSentDirectMessages, &index );

    AIRTwitterAddFunction( functionArray, "applicationOpenURL", &applicationOpenURL, &index );
    
    AIRTwitterAddFunction( functionArray, "isSystemAccountAvailable", &isSystemAccountAvailable, &index );
    
    *functionsToSet = functionArray;
    
    extensionContext = ctx;
}

void AIRTwitterContextFinalizer( FREContext ctx ) { }

void AIRTwitterInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AIRTwitterContextInitializer;
    *ctxFinalizerToSet = &AIRTwitterContextFinalizer;
}

void AIRTwitterFinalizer( void* extData ) { }







