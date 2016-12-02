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
#import "Functions/RequestAccountAccessFunction.h"
#import <objc/runtime.h>
#import <AIRExtHelpers/MPUIApplicationDelegate.h>

static AIRTwitter* mAIRTwitterSharedInstance = nil;

static BOOL mAIRTwitterLogEnabled = NO;
FREContext mAIRTwitterExtContext = nil;

@implementation AIRTwitter {
    BOOL mInitialized;
    NSString* mURLScheme;
    NSString* mConsumerKey;
    NSString* mConsumerSecret;
    AIRTwitterUser* mLoggedInUser;
    STTwitterAPI* mSTTwitterAPI;
}

+ (id) sharedInstance {
    if( mAIRTwitterSharedInstance == nil ) {
        mAIRTwitterSharedInstance = [[AIRTwitter alloc] init];
        [[MPUIApplicationDelegate sharedInstance] addListener:mAIRTwitterSharedInstance];
    }
    return mAIRTwitterSharedInstance;
}

- (id) init {
    self = [super init];
    if( self != nil ) {
        mInitialized = NO;
        
        // Swizzle iOS 9+ openURL handler
        if( NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0 ) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                id delegate = [[UIApplication sharedApplication] delegate];
                if( delegate != nil ) {
                    Class adobeDelegateClass = object_getClass( delegate );
                    
                    SEL delegateSelector = @selector(application:openURL:options:);
                    [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(airtwitter_application:openURL:options:)];
                }
            });
        }
    }
    return self;
}

- (BOOL) initWithConsumerKey:(NSString*) key consumerSecret:(NSString*) secret urlScheme:(NSString*) urlScheme {
    mInitialized = YES;
    
    mURLScheme = urlScheme;
    mConsumerKey = key;
    mConsumerSecret = secret;

    /* Check if we already have access token */
    NSString* accessToken = [self accessToken];
    if( accessToken ) {
        [AIRTwitter log:@"Initializing STTwitter w/ key, secret and user's access tokens"];
        mSTTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:key consumerSecret:secret oauthToken:accessToken oauthTokenSecret:[self accessTokenSecret]];
        return YES;
    }
    return NO;
}

- (void) getAccessTokensForPIN:(NSString*) PIN {
    [AIRTwitter log:@"Getting OAuth tokens for PIN"];

    [mSTTwitterAPI postAccessTokenRequestWithPIN:PIN successBlock:^(NSString* oauthToken, NSString* oauthTokenSecret, NSString* userID, NSString* screenName) {
        [AIRTwitter log:@"Successfully retrieved access token"];
        [self storeCredentials:screenName userID:userID accessToken:oauthToken accessTokenSecret:oauthTokenSecret];
        /* Dispatch login success */
        [AIRTwitter dispatchEvent:LOGIN_SUCCESS];
    } errorBlock:^(NSError* error) {
        [AIRTwitter log:[NSString stringWithFormat:@"Error retrieving access token: %@", error.localizedDescription]];
        [AIRTwitter dispatchEvent:LOGIN_ERROR withMessage:error.localizedDescription];
    }];
}

- (void) verifySystemAccount:(ACAccount*) account {
    [[self api] postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        [AIRTwitter log:@"Authentication header retrieved."];
        mSTTwitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
        [mSTTwitterAPI verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            [AIRTwitter log:@"Credentials for system account are valid."];
            [mSTTwitterAPI postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
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

- (void) storeCredentials:(NSString*) screenName userID:(NSString*) userID accessToken:(NSString*) accessToken accessTokenSecret:(NSString*) accessTokenSecret {
    /* There are not set when logging in after log out so we set them manually */
    [mSTTwitterAPI setUserName:screenName];
    [mSTTwitterAPI setUserID:userID];
    /* Store access tokens */
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"accessToken"];
    [defaults setObject:accessTokenSecret forKey:@"accessTokenSecret"];
    [defaults synchronize];
}

- (void) clearAccessTokens {
    mSTTwitterAPI = nil;
    mLoggedInUser = nil;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"accessToken"];
    [defaults removeObjectForKey:@"accessTokenSecret"];
    [defaults synchronize];
}


# pragma mark - Getters / Setters


- (STTwitterAPI*) api {
    return [self api:NO];
}

- (STTwitterAPI*) api:(BOOL) newInstance {
    if( !mSTTwitterAPI || newInstance ) {
        mSTTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:mConsumerKey consumerSecret:mConsumerSecret];
    }
    return mSTTwitterAPI;
}

- (NSString*) urlScheme {
    return mURLScheme;
}

- (NSString*) accessToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
}

- (NSString*) accessTokenSecret {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"accessTokenSecret"];
}

- (BOOL) isInitialized {
    return mInitialized;
}


# pragma mark - Logged in user info


- (AIRTwitterUser*) loggedInUser {
    return mLoggedInUser;
}

- (void) setLoggedInUser:(AIRTwitterUser*) user {
    mLoggedInUser = user;
}


# pragma mark - STTwitterAPIOSProtocol


- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    
}


# pragma mark - MPUIApplicationListener


- (BOOL) application:(nullable UIApplication *)application openURL:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    [AIRTwitter log:@"application openURL"];
    
    return [self handleOpenURL:url];
}

- (BOOL) airtwitter_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [AIRTwitter log:@"application openURL"];
    
    return [self handleOpenURL:url];
}


# pragma mark - AIR API


+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void)dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( mAIRTwitterExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void)log:(const NSString*) message {
    if( mAIRTwitterLogEnabled ) {
        NSLog( @"[iOS-AIRTwitter] %@", message );
    }
}

+ (void)showLogs:(BOOL) showLogs {
    mAIRTwitterLogEnabled = showLogs;
}


# pragma mark - Private


- (BOOL) handleOpenURL:(NSURL*) url {
    NSDictionary* urlParams = [self parametersDictionaryFromQueryString:url.query];
    
    //NSString* token = d[@"oauth_token"];
    NSString* verifier = urlParams[@"oauth_verifier"];  // PIN
    NSString* denied = urlParams[@"denied"];
    
    if( denied || !verifier ) {
        [AIRTwitter log:@"App was launched after cancelled attempt to login"];
        [AIRTwitter dispatchEvent:LOGIN_CANCEL];
        return NO;
    }
    
    [self getAccessTokensForPIN:verifier];
    
    return YES;
}


- (NSDictionary*) parametersDictionaryFromQueryString:(NSString*) queryString {
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


- (BOOL) overrideDelegate:(Class) delegateClass method:(SEL) delegateSelector withMethod:(SEL) swizzledSelector {
    Method originalMethod = class_getInstanceMethod(delegateClass, delegateSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(delegateClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    
    if (didAddMethod) {
        class_replaceMethod(delegateClass,
                            delegateSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return didAddMethod;
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
    uint32_t numFunctions = 26;
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
    AIRTwitterAddFunction( functionArray, "requestSystemAccountAccess", &tw_requestAccountAccess, &index );

    *functionsToSet = functionArray;

    mAIRTwitterExtContext = ctx;
}

void AIRTwitterContextFinalizer( FREContext ctx ) { }

void AIRTwitterInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AIRTwitterContextInitializer;
    *ctxFinalizerToSet = &AIRTwitterContextFinalizer;
}

void AIRTwitterFinalizer( void* extData ) { }





