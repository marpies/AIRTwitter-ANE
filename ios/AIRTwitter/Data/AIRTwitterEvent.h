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

#ifndef AIRTwitter_AIRTwitterEvent_h
#define AIRTwitter_AIRTwitterEvent_h

#import <Foundation/Foundation.h>

static const NSString* LOGIN_ERROR = @"loginError";
static const NSString* LOGIN_CANCEL = @"loginCancel";
static const NSString* LOGIN_SUCCESS = @"loginSuccess";

static const NSString* CREDENTIALS_CHECK = @"credentialsCheck";

static const NSString* ACCESS_SYSTEM_ACCOUNTS = @"accessSystemAccounts";

static const NSString* STATUS_QUERY_SUCCESS = @"statusQuerySuccess";
static const NSString* STATUS_QUERY_ERROR = @"statusQueryError";

static const NSString* USERS_QUERY_SUCCESS = @"usersQuerySuccess";
static const NSString* USERS_QUERY_ERROR = @"usersQueryError";

static const NSString* TIMELINE_QUERY_SUCCESS = @"timelineQuerySuccess";
static const NSString* TIMELINE_QUERY_ERROR = @"timelineQueryError";

static const NSString* USER_QUERY_SUCCESS = @"userQuerySuccess";
static const NSString* USER_QUERY_ERROR = @"userQueryError";

static const NSString* DIRECT_MESSAGE_QUERY_SUCCESS = @"directMessageQuerySuccess";
static const NSString* DIRECT_MESSAGE_QUERY_ERROR = @"directMessageQueryError";

static const NSString* DIRECT_MESSAGES_QUERY_SUCCESS = @"directMessagesQuerySuccess";
static const NSString* DIRECT_MESSAGES_QUERY_ERROR = @"directMessagesQueryError";

#endif
