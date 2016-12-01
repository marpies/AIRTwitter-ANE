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

#import "AIRTwitter.h"
#import "AIRTwitterEvent.h"
#import "AIRTwitterUser.h"
#import <AIRExtHelpers/FlashRuntimeExtensions.h>
#import "Functions/InitFunction.h"
#import "Functions/LoginFunction.h"
#import "Functions/LogoutFunction.h"
#import "Functions/UpdateStatusFunction.h"
#import "Functions/GetFollowersFunction.h"
#import "Functions/GetHomeTimelineFunction.h"
#import "Functions/GetUserTimelineFunction.h"
#import "Functions/GetLikesFunction.h"
#import "Functions/GetFriendsFunction.h"
#import "Functions/FollowUserFunction.h"
#import "Functions/UnfollowUserFunction.h"
#import "Functions/RetweetStatusFunction.h"
#import "Functions/LikeStatusFunction.h"
#import "Functions/UndoLikeStatusFunction.h"
#import "Functions/DeleteStatusFunction.h"
#import "Functions/SendDirectMessageFunction.h"
#import "Functions/GetDirectMessagesFunction.h"
#import "Functions/GetSentDirectMessagesFunction.h"
#import "Functions/GetLoggedInUserFunction.h"
#import "Functions/GetUserFunction.h"
#import "Functions/GetAccessTokenFunction.h"
#import "Functions/GetAccessTokenSecretFunction.h"
#import "Functions/ApplicationOpenURLFunction.h"
#import "Functions/LoginWithAccount.h"
#import "Functions/IsSystemAccountAvailableFunction.h"

static STTwitterAPI* mTwitter = nil;

static NSString* mAIRTwitterURLScheme = nil;
static NSString* mAIRTwitterConsumerKey = nil;
static NSString* mAIRTwitterConsumerSecret = nil;

static AIRTwitterUser* mAIRTwitterLoggedInUser = nil;

static BOOL airTwitterLogEnabled = NO;
FREContext airTwitterContext = nil;

@interface AIRTwitter ()
@end

@implementation AIRTwitter

+ (BOOL) initWithConsumerKey:(NSString*) key consumerSecret:(NSString*) secret urlScheme:(NSString*) urlScheme {
    mAIRTwitterURLScheme = urlScheme;
    mAIRTwitterConsumerKey = key;
    mAIRTwitterConsumerSecret = secret;

    /* Check if we already have access token */
    NSString* accessToken = [self accessToken];
    if( accessToken ) {
        [AIRTwitter log:@"Initializing STTwitter w/ key, secret and user's access tokens"];
        mTwitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:key consumerSecret:secret oauthToken:accessToken oauthTokenSecret:[self accessTokenSecret]];
        return YES;
    }
    return NO;
}

+ (void) getAccessTokensForPIN:(NSString*) PIN {
    [AIRTwitter log:@"Getting OAuth tokens for PIN"];

    [mTwitter postAccessTokenRequestWithPIN:PIN successBlock:^(NSString* oauthToken, NSString* oauthTokenSecret, NSString* userID, NSString* screenName) {
        [AIRTwitter log:@"Successfully retrieved access token"];
        [self storeCredentials:screenName userID:userID accessToken:oauthToken accessTokenSecret:oauthTokenSecret];
        /* Dispatch login success */
        [AIRTwitter dispatchEvent:LOGIN_SUCCESS];
    } errorBlock:^(NSError* error) {
        [AIRTwitter log:[NSString stringWithFormat:@"Error retrieving access token: %@", error.localizedDescription]];
        [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
    }];
}

+ (void) verifySystemAccount:(ACAccount*) account {
    [[self api] postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        [AIRTwitter log:@"Authentication header retrieved."];
        mTwitter = [STTwitterAPI twitterAPIOSWithAccount:account];
        [mTwitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            [AIRTwitter log:@"Credentials for system account are valid."];
            [mTwitter postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
                [AIRTwitter log:@"Access token for authentication header retrieved."];
                [self storeCredentials:username userID:userID accessToken:oAuthToken accessTokenSecret:oAuthTokenSecret];
                /* Dispatch login success */
                [AIRTwitter dispatchEvent:LOGIN_SUCCESS];
            } errorBlock:^(NSError *error) {
                [AIRTwitter log:[NSString stringWithFormat:@"Error retrieving access token for authentication header: %@", error.localizedDescription]];
                [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
            }];
        } errorBlock:^(NSError *error) {
            [AIRTwitter log:[NSString stringWithFormat:@"Error verifying system account credentials: %@", error.localizedDescription]];
            [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
        }];
    } errorBlock:^(NSError *error) {
        [AIRTwitter log:[NSString stringWithFormat:@"Error retrieving authentication header: %@", error.localizedDescription]];
        [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
    }];
}

+ (void) storeCredentials:(NSString*) screenName userID:(NSString*) userID accessToken:(NSString*) accessToken accessTokenSecret:(NSString*) accessTokenSecret {
    /* There are not set when logging in after log out so we set them manually */
    [mTwitter setUserName:screenName];
    [mTwitter setUserID:userID];
    /* Store access tokens */
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"accessToken"];
    [defaults setObject:accessTokenSecret forKey:@"accessTokenSecret"];
    [defaults synchronize];
}

+ (void) clearAccessTokens {
    mTwitter = nil;
    mAIRTwitterLoggedInUser = nil;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"accessToken"];
    [defaults removeObjectForKey:@"accessTokenSecret"];
    [defaults synchronize];
}

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void)dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( airTwitterContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void)log:(const NSString*) message {
    if( airTwitterLogEnabled ) {
        NSLog( @"[iOS-AIRTwitter] %@", message );
    }
}

+ (void)showLogs:(BOOL) showLogs {
    airTwitterLogEnabled = showLogs;
}

/**
 *
 *
 * Getters / Setters
 *
 *
 */

+ (STTwitterAPI*) api {
    return [self api:NO];
}

+ (STTwitterAPI*) api:(BOOL) newInstance {
    if( !mTwitter || newInstance ) {
        mTwitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:mAIRTwitterConsumerKey consumerSecret:mAIRTwitterConsumerSecret];
    }
    return mTwitter;
}

+ (NSString*) urlScheme {
    return mAIRTwitterURLScheme;
}

+ (NSString*) accessToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
}

+ (NSString*) accessTokenSecret {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"accessTokenSecret"];
}

/**
 * Logged in user info
 */

+ (AIRTwitterUser*) loggedInUser {
    return mAIRTwitterLoggedInUser;
}

+ (void) setLoggedInUser:(AIRTwitterUser*) user {
    mAIRTwitterLoggedInUser = user;
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
    uint32_t numFunctions = 25;
    *numFunctionsToSet = numFunctions;

    FRENamedFunction* functionArray = (FRENamedFunction*) malloc( sizeof( FRENamedFunction ) * numFunctions );

    uint32_t index = 0;
    AIRTwitterAddFunction( functionArray, "init", &tw_init, &index );
    AIRTwitterAddFunction( functionArray, "login", &tw_login, &index );
    AIRTwitterAddFunction( functionArray, "loginWithAccount", &tw_loginWithAccount, &index );
    AIRTwitterAddFunction( functionArray, "logout", &tw_logout, &index );

    AIRTwitterAddFunction( functionArray, "updateStatus", &tw_updateStatus, &index );
    AIRTwitterAddFunction( functionArray, "getFollowers", &tw_getFollowers, &index );
    AIRTwitterAddFunction( functionArray, "getHomeTimeline", &tw_getHomeTimeline, &index );
    AIRTwitterAddFunction( functionArray, "getUserTimeline", &tw_getUserTimeline, &index );
    AIRTwitterAddFunction( functionArray, "getLikes", &tw_getLikes, &index );
    AIRTwitterAddFunction( functionArray, "getFriends", &tw_getFriends, &index );
    AIRTwitterAddFunction( functionArray, "getLoggedInUser", &tw_getLoggedInUser, &index );
    AIRTwitterAddFunction( functionArray, "getUser", &tw_getUser, &index );

    AIRTwitterAddFunction( functionArray, "followUser", &tw_followUser, &index );
    AIRTwitterAddFunction( functionArray, "unfollowUser", &tw_unfollowUser, &index );

    AIRTwitterAddFunction( functionArray, "retweetStatus", &tw_retweetStatus, &index );
    AIRTwitterAddFunction( functionArray, "likeStatus", &tw_likeStatus, &index );
    AIRTwitterAddFunction( functionArray, "undoLikeStatus", &tw_undoLikeStatus, &index );
    AIRTwitterAddFunction( functionArray, "deleteStatus", &tw_deleteStatus, &index );

    AIRTwitterAddFunction( functionArray, "sendDirectMessage", &tw_sendDirectMessage, &index );
    AIRTwitterAddFunction( functionArray, "getDirectMessages", &tw_getDirectMessages, &index );
    AIRTwitterAddFunction( functionArray, "getSentDirectMessages", &tw_getSentDirectMessages, &index );

    AIRTwitterAddFunction( functionArray, "getAccessToken", &tw_getAccessToken, &index );
    AIRTwitterAddFunction( functionArray, "getAccessTokenSecret", &tw_getAccessTokenSecret, &index );

    AIRTwitterAddFunction( functionArray, "applicationOpenURL", &tw_applicationOpenURL, &index );

    AIRTwitterAddFunction( functionArray, "isSystemAccountAvailable", &tw_isSystemAccountAvailable, &index );

    *functionsToSet = functionArray;

    airTwitterContext = ctx;
}

void AIRTwitterContextFinalizer( FREContext ctx ) { }

void AIRTwitterInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AIRTwitterContextInitializer;
    *ctxFinalizerToSet = &AIRTwitterContextFinalizer;
}

void AIRTwitterFinalizer( void* extData ) { }





