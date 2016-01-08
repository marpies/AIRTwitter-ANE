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

package com.marpies.ane.twitter {

    import com.marpies.ane.twitter.data.AIRTwitterDirectMessage;
    import com.marpies.ane.twitter.data.AIRTwitterStatus;
    import com.marpies.ane.twitter.data.AIRTwitterUser;

    import flash.desktop.NativeApplication;
    import flash.events.InvokeEvent;
    import flash.events.StatusEvent;
    import flash.events.TimerEvent;
    import flash.external.ExtensionContext;
    import flash.system.Capabilities;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    public class AIRTwitter {

        private static const TAG:String = "[AIRTwitter]";
        private static const EXTENSION_ID:String = "com.marpies.ane.twitter";

        /* Event codes */
        private static const LOGIN_ERROR:String = "loginError";
        private static const LOGIN_CANCEL:String = "loginCancel";
        private static const LOGIN_SUCCESS:String = "loginSuccess";

        private static const CREDENTIALS_CHECK:String = "credentialsCheck";

        /* Event name for queries that return single status (retweetStatus, updateStatus...) */
        private static const STATUS_QUERY_SUCCESS:String = "statusQuerySuccess";
        private static const STATUS_QUERY_ERROR:String = "statusQueryError";

        /* Event name for queries that return list with users (getFollowers, getFriends...) */
        private static const USERS_QUERY_SUCCESS:String = "usersQuerySuccess";
        private static const USERS_QUERY_ERROR:String = "usersQueryError";

        /* Event name for queries that return list with statuses (getHomeTimeline, getLikes...) */
        private static const TIMELINE_QUERY_SUCCESS:String = "timelineQuerySuccess";
        private static const TIMELINE_QUERY_ERROR:String = "timelineQueryError";

        /* Event name for queries that return single user (un/followUser, getLoggedInUser...) */
        private static const USER_QUERY_SUCCESS:String = "userQuerySuccess";
        private static const USER_QUERY_ERROR:String = "userQueryError";

        /* Event name for queries that return single direct message */
        private static const DIRECT_MESSAGE_QUERY_SUCCESS:String = "directMessageQuerySuccess";
        private static const DIRECT_MESSAGE_QUERY_ERROR:String = "directMessageQueryError";

        /* Event name for queries that return list with direct messages (getDirectMessages, getSentDirectMessages) */
        private static const DIRECT_MESSAGES_QUERY_SUCCESS:String = "directMessagesQuerySuccess";
        private static const DIRECT_MESSAGES_QUERY_ERROR:String = "directMessagesQueryError";

        /* Misc */
        private static var mLogEnabled:Boolean;
        private static var mLoginInProgress:Boolean;
        private static var mStandardInvokeTimer:Timer;

        /* Callbacks */
        private static var mLoginCallback:Function;
        private static var mCredentialsCallback:Function;
        private static var mCallbackMap:Dictionary;

        /* Twitter vars */
        private static var mContext:ExtensionContext;
        private static var mURLScheme:String;
        private static var mLoggedInUser:AIRTwitterUser;

        /**
         * @private
         * Do not use. AIRTwitter is a static class.
         */
        public function AIRTwitter() {
            throw Error( "AIRTwitter is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Initializes extension context.
         *
         * @param consumerKey Consumer key of your Twitter application.
         * @param consumerSecret Consumer secret of your Twitter application.
         * @param urlScheme URL scheme for your application. Must match the values specified in the app descriptor XML.
         * @param callback Function with signature <code>callback(credentialsValid:Boolean, credentialsMissing:Boolean):void</code>.
         *                 The parameters indicate the state of cached user credentials. User does not need to login again if
         *                 credentials are valid. If credentials are missing or invalid then user must login again.
         * @param showLogs Set to <code>true</code> to show extension log messages.
         * @return <code>true</code> if the extension context was created, <code>false</code> otherwise
         */
        public static function init( consumerKey:String, consumerSecret:String, urlScheme:String, callback:Function = null, showLogs:Boolean = false ):Boolean {
            if( !isSupported ) return false;

            if( !consumerKey ) throw new ArgumentError( "Parameter consumerKey cannot be null." );
            if( !consumerSecret ) throw new ArgumentError( "Parameter consumerSecret cannot be null." );
            if( !urlScheme ) throw new ArgumentError( "Parameter urlScheme cannot be null." );

            mURLScheme = urlScheme;
            mCredentialsCallback = callback;
            mLogEnabled = showLogs;
            mCallbackMap = new Dictionary();

            /* Initialize context */
            mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
            if( !mContext ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }
            /* Listen for native library events */
            mContext.addEventListener( StatusEvent.STATUS, onStatus );
            /* Listen for invoke event */
            NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, onInvokeHandler );

            /* Call init */
            mContext.call( "init", consumerKey, consumerSecret, urlScheme, showLogs );
            return true;
        }

        /**
         * Initiates login process via browser.
         * @param callback Function with signature <code>callback(errorMessage:String, wasCancelled:Boolean):void</code>.
         * @param forceLogin If <code>true</code>, user will be forced to enter his name and password, even if he's logged in the browser.
         */
        public static function login( callback:Function, forceLogin:Boolean = false ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mLoginInProgress = true;
            mLoginCallback = callback;

            mContext.call( "login", forceLogin );
        }

        /**
         * Initiates login process using an account set in user's iOS settings.
         * @param callback Function with signature <code>callback(errorMessage:String, wasCancelled:Boolean):void</code>.
         * @param dialogTitle Title for the pop up that appears when more Twitter accounts are available in the system.
         * @param cancelButtonLabel Label for the cancel button that is part of the pop up. The button may not appear on
         *                          iOS 8+ as the dialog is cancelled by tapping outside of its bounds.
         *
         * @see #isLoginWithAccountSupported
         * @see #isSystemAccountAvailable
         */
        public static function loginWithAccount( callback:Function, dialogTitle:String = "Select an account", cancelButtonLabel:String = "Cancel" ):void {
            if( !isLoginWithAccountSupported ) {
                log( "Method loginWithAccount is only supported on iOS." );
                return;
            }
            validateExtensionContext();

            if( !dialogTitle ) throw new ArgumentError( "Parameter dialogTitle cannot be null." );
            if( !cancelButtonLabel ) throw new ArgumentError( "Parameter cancelButtonLabel cannot be null." );

            mLoginCallback = callback;

            mContext.call( "loginWithAccount", dialogTitle, cancelButtonLabel );
        }

        /**
         * Logs out current and clears access tokens.
         */
        public static function logout():void {
            if( !isSupported ) return;
            validateExtensionContext();

            mLoggedInUser = null;

            mContext.call( "logout" );
        }

        /**
         * Requests info for logged in user. Returns cached user object (from earlier request), or <code>null</code>
         * if it does not exist. Callback will not be called if cached user object exists.
         * @param callback Function with signature <code>callback(user:AIRTwitterUser, errorMessage:String):void</code>.
         * @return Cached user object (from earlier request), or <code>null</code> if cache does not exist.
         */
        public static function getLoggedInUser( callback:Function = null ):AIRTwitterUser {
            if( !isSupported ) return null;
            validateExtensionContext();

            if( mLoggedInUser ) return mLoggedInUser;

            mContext.call( "getLoggedInUser", registerCallback( callback ) );
            return null;
        }

        /**
         * Updates status with given text and optional media files.
         * @param text Status message.
         * @param callback Function with signature <code>callback(status:AIRTwitterStatus, errorMessage:String):void</code>.
         * @param inReplyToStatusID ID of the status to which will be replied.
         * @param media List of media files (<code>String</code> - URLs to local and remote images, <code>BitmapData</code>) - max. 4.
         */
        public static function updateStatus( text:String, callback:Function = null, inReplyToStatusID:String = null, media:Array = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            if( !text && (!media || media.length == 0) ) throw ArgumentError( "Either parameter text or media must be set." );
            if( media && media.length > 4 ) throw new Error( "Maximum number of media files is 4." );

            mContext.call( "updateStatus", text, registerCallback( callback ), inReplyToStatusID, media );
        }

        /**
         * Deletes status with given ID.
         * @param statusID ID of the status to delete.
         * @param callback Function with signature <code>callback(deletedStatus:AIRTwitterStatus, errorMessage:String):void</code>.
         */
        public static function deleteStatusWithID( statusID:String, callback:Function ):void {
            if( !isSupported ) return;
            validateExtensionContext();
            validateStatusID( statusID );

            mContext.call( "deleteStatus", statusID, registerCallback( callback ) );
        }

        /**
         * Retweets status with given ID.
         * @param statusID ID of the status to retweet.
         * @param callback Function with signature <code>callback(retweetedStatus:AIRTwitterStatus, errorMessage:String):void</code>
         */
        public static function retweetStatusWithID( statusID:String, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();
            validateStatusID( statusID );

            mContext.call( "retweetStatus", statusID, registerCallback( callback ) );
        }

        /**
         * Likes status with given ID.
         * @param statusID ID of the status to retweet.
         * @param callback Function with signature <code>callback(likedStatus:AIRTwitterStatus, errorMessage:String):void</code>
         */
        public static function likeStatusWithID( statusID:String, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();
            validateStatusID( statusID );

            mContext.call( "likeStatus", statusID, registerCallback( callback ) );
        }

        /**
         * Removes status with given ID from likes.
         * @param statusID ID of the status to retweet.
         * @param callback Function with signature <code>callback(unlikedStatus:AIRTwitterStatus, errorMessage:String):void</code>
         */
        public static function undoLikeStatusWithID( statusID:String, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();
            validateStatusID( statusID );

            mContext.call( "undoLikeStatus", statusID, registerCallback( callback ) );
        }

        /**
         * Requests (up to) 20 followers for logged in user.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(followers:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFollowers( cursor:Number = -1, callback:Function = null ):void {
            getFollowersInternal( cursor, callback );
        }

        /**
         * Requests (up to) 20 followers for user with given ID.
         * @param userID ID of the user for whom the followers will be requested.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(followers:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFollowersForUserID( userID:Number, cursor:Number = -1, callback:Function = null ):void {
            validateUserID( userID );

            getFollowersInternal( cursor, callback, userID );
        }

        /**
         * Requests (up to) 20 followers for user with given screen name.
         * @param screenName Screen name of the user for whom the followers will be requested.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(followers:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFollowersForScreenName( screenName:String, cursor:Number = -1, callback:Function = null ):void {
            validateScreenName( screenName );

            getFollowersInternal( cursor, callback, -1, screenName );
        }

        /**
         * Requests home timeline for logged in user.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param excludeReplies Set to <code>true</code> to prevent replies from appearing in the returned list of tweets.
         *                       You will receive up-to <code>count</code> tweets — this is because the <code>count</code>
         *                       parameter retrieves that many tweets before filtering out replies.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getHomeTimeline( count:uint = 20, sinceID:String = null, maxID:String = null, excludeReplies:Boolean = false, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            if( count > 200 || count < 1 ) throw new RangeError( "Value of parameter count must be between 1-200" );

            mContext.call( "getHomeTimeline", count, sinceID, maxID, excludeReplies, registerCallback( callback ) );
        }

        /**
         * Requests timeline (the statuses user has (re)tweeted) for logged in user.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param excludeReplies Set to <code>true</code> to prevent replies from appearing in the returned list of tweets.
         *                       You will receive up-to <code>count</code> tweets — this is because the <code>count</code>
         *                       parameter retrieves that many tweets before filtering out replies.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getUserTimeline( count:uint = 20, sinceID:String = null, maxID:String = null, excludeReplies:Boolean = false, callback:Function = null ):void {
            getUserTimelineInternal( count, sinceID, maxID, excludeReplies, -1, null, callback );
        }

        /**
         * Requests timeline (the statuses user has (re)tweeted) for user with given ID.
         * @param userID ID of the user for whom to request the timeline.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param excludeReplies Set to <code>true</code> to prevent replies from appearing in the returned list of tweets.
         *                       You will receive up-to <code>count</code> tweets — this is because the <code>count</code>
         *                       parameter retrieves that many tweets before filtering out replies.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getUserTimelineForUserID( userID:Number, count:uint = 20, sinceID:String = null, maxID:String = null, excludeReplies:Boolean = false, callback:Function = null ):void {
            validateUserID( userID );

            getUserTimelineInternal( count, sinceID, maxID, excludeReplies, userID, null, callback );
        }

        /**
         * Requests timeline (the statuses user has (re)tweeted) for user with given screen name.
         * @param screenName Screen name of the user for whom to request the timeline.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param excludeReplies Set to <code>true</code> to prevent replies from appearing in the returned list of tweets.
         *                       You will receive up-to <code>count</code> tweets — this is because the <code>count</code>
         *                       parameter retrieves that many tweets before filtering out replies.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getUserTimelineForScreenName( screenName:String, count:uint = 20, sinceID:String = null, maxID:String = null, excludeReplies:Boolean = false, callback:Function = null ):void {
            validateScreenName( screenName );

            getUserTimelineInternal( count, sinceID, maxID, excludeReplies, -1, screenName, callback );
        }

        /**
         * Requests info for user with given ID.
         * @param userID ID of the user for whom info to request the info.
         * @param callback Function with signature <code>callback(user:AIRTwitterUser, errorMessage:String):void</code>.
         */
        public static function getUserForID( userID:Number, callback:Function = null ):void {
            validateUserID( userID );

            getUserInternal( userID, null, callback );
        }

        /**
         * Requests info for user with given screen name.
         * @param screenName Screen name of the user for whom info to request the info.
         * @param callback Function with signature <code>callback(user:AIRTwitterUser, errorMessage:String):void</code>.
         */
        public static function getUserForScreenName( screenName:String, callback:Function = null ):void {
            validateScreenName( screenName );

            getUserInternal( -1, screenName, callback );
        }

        /**
         * Requests liked statuses for logged in user user.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getLikes( count:uint = 20, sinceID:String = null, maxID:String = null, callback:Function = null ):void {
            getLikesInternal( count, sinceID, maxID, -1, null, callback );
        }

        /**
         * Requests liked statuses for user with given ID.
         * @param userID ID of the user for whom to request a list of liked statuses.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getLikesForUserID( userID:Number, count:uint = 20, sinceID:String = null, maxID:String = null, callback:Function = null ):void {
            validateUserID( userID );

            getLikesInternal( count, sinceID, maxID, userID, null, callback );
        }

        /**
         * Requests liked statuses for user with given screen name.
         * @param screenName Screen name of the user for whom to request a list of liked statuses.
         * @param count Specifies the number of tweets to retrieve. Must be less than or equal to 200.
         *              The value of <code>count</code> is best thought of as a limit to the number of tweets
         *              to return because suspended or deleted content is removed after the count has been applied.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID. There
         *                are limits to the number of Tweets which can be accessed through the API. If the limit of
         *                Tweets has occurred since the <code>sinceID</code>, the <code>sinceID</code> will be forced to the oldest ID available.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param callback Function with signature <code>callback(statuses:Vector.&lt;AIRTwitterStatus&gt;, errorMessage:String):void</code>.
         */
        public static function getLikesForScreenName( screenName:String, count:uint = 20, sinceID:String = null, maxID:String = null, callback:Function = null ):void {
            validateScreenName( screenName );

            getLikesInternal( count, sinceID, maxID, -1, screenName, callback );
        }

        /**
         * Requests friends (people who the user is following) for user with given ID.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(friends:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFriends( cursor:Number = -1, callback:Function = null ):void {
            getFriendsInternal( cursor, -1, null, callback );
        }

        /**
         * Requests friends (people who the user is following) for user with given ID.
         * @param userID ID of the user for whom to request the friends.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(friends:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFriendsForUserID( userID:Number, cursor:Number = -1, callback:Function = null ):void {
            validateUserID( userID );

            getFriendsInternal( cursor, userID, null, callback );
        }

        /**
         * Requests friends (people who the user is following) for user with given screen name.
         * @param screenName Screen name of the user for whom to request the friends.
         * @param cursor Cursor denoting the page of the result set. Value of -1 retrieves the first page. Use the callback
         *               parameters <code>nextCursor</code> and <code>previousCursor</code> to query next and previous pages.
         * @param callback Function with signature <code>callback(friends:Vector.&lt;AIRTwitterUser&gt;, nextCursor:Number, previousCursor:Number, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/overview/api/cursoring
         */
        public static function getFriendsForScreenName( screenName:String, cursor:Number = -1, callback:Function = null ):void {
            validateScreenName( screenName );

            getFriendsInternal( cursor, -1, screenName, callback );
        }

        /**
         * Sends a follow request from logged in user to user with given ID.
         * @param userID ID of the user to follow.
         * @param enableNotifications Enable notifications for the target user in addition to becoming friends.
         * @param callback Function with signature <code>callback(targetUser:AIRTwitterUser, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/rest/reference/post/friendships/create
         */
        public static function followUserWithID( userID:Number, enableNotifications:Boolean = false, callback:Function = null ):void {
            validateUserID( userID );

            followUserInternal( userID, null, enableNotifications, callback );
        }

        /**
         * Sends a follow request from logged in user to user with given screen name.
         * @param screenName Screen name of the user to follow.
         * @param enableNotifications Enable notifications for the target user in addition to becoming friends.
         * @param callback Function with signature <code>callback(targetUser:AIRTwitterUser, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/rest/reference/post/friendships/create
         */
        public static function followUserWithScreenName( screenName:String, enableNotifications:Boolean = false, callback:Function = null ):void {
            validateScreenName( screenName );

            followUserInternal( -1, screenName, enableNotifications, callback );
        }

        /**
         * Unfollows user with given ID.
         * @param userID ID of the user to unfollow.
         * @param callback Function with signature <code>callback(targetUser:AIRTwitterUser, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/rest/reference/post/friendships/destroy
         */
        public static function unfollowUserWithID( userID:Number, callback:Function = null ):void {
            validateUserID( userID );

            unfollowUserInternal( userID, null, callback );
        }

        /**
         * Unfollows user with given screen name.
         * @param screenName Screen name of the user to unfollow.
         * @param callback Function with signature <code>callback(targetUser:AIRTwitterUser, errorMessage:String):void</code>.
         *
         * @see http://dev.twitter.com/rest/reference/post/friendships/destroy
         */
        public static function unfollowUserWithScreenName( screenName:String, callback:Function = null ):void {
            validateScreenName( screenName );

            unfollowUserInternal( -1, screenName, callback );
        }

        /**
         * Sends direct message to user with given ID.
         * @param text Text of the message.
         * @param userID ID of the user to send the message to.
         * @param callback Function with signature <code>callback(message:AIRTwitterDirectMessage, errorMessage:String):void</code>.
         */
        public static function sendDirectMessageToUserWithID( text:String, userID:Number, callback:Function ):void {
            if( !text ) throw new ArgumentError( "Parameter text cannot be null." );
            validateUserID( userID );

            sendDirectMessageInternal( text, userID, null, callback );
        }

        /**
         * Sends direct message to user with given screen name.
         * @param text Text of the message.
         * @param screenName Screen name of the user to send the message to.
         * @param callback Function with signature <code>callback(message:AIRTwitterDirectMessage, errorMessage:String):void</code>.
         */
        public static function sendDirectMessageToUserWithScreenName( text:String, screenName:String, callback:Function ):void {
            if( !text ) throw new ArgumentError( "Parameter text cannot be null." );
            validateScreenName( screenName );

            sendDirectMessageInternal( text, -1, screenName, callback );
        }

        /**
         * Returns the <code>count</code> most recent direct messages sent to the authenticated user.
         * @param count Specifies the number of records to retrieve. Must be less than or equal to 200.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param callback Function with signature <code>callback(messages:Vector.&lt;AIRTwitterDirectMessage&gt;, errorMessage:String):void</code>.
         */
        public static function getDirectMessages( count:uint = 20, sinceID:String = null, maxID:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getDirectMessages", count, sinceID, maxID, registerCallback( callback ) );
        }

        /**
         * Returns the <code>count</code> most recent direct messages sent by the authenticated user.
         * @param count Specifies the number of records to retrieve. Must be less than or equal to 200.
         * @param sinceID Returns results with an ID greater than (that is, more recent than) the specified ID.
         * @param maxID Returns results with an ID less than (that is, older than) or equal to the specified ID.
         * @param page Specifies the page of results to retrieve.
         * @param callback Function with signature <code>callback(messages:Vector.&lt;AIRTwitterDirectMessage&gt;, errorMessage:String):void</code>.
         */
        public static function getSentDirectMessages( count:uint = 20, sinceID:String = null, maxID:String = null, page:uint = 1, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getSentDirectMessages", count, sinceID, maxID, page, registerCallback( callback ) );
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.removeEventListener( StatusEvent.STATUS, onStatus );
            NativeApplication.nativeApplication.removeEventListener( InvokeEvent.INVOKE, onInvokeHandler );

            if( mStandardInvokeTimer ) {
                mStandardInvokeTimer.stop();
                disposeStandardInvokeTimer();
            }

            mContext.dispose();
            mContext = null;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        public static function get version():String {
            return "0.7.2-beta";
        }

        /**
         * Supported on iOS and Android.
         */
        public static function get isSupported():Boolean {
            return iOS || Capabilities.manufacturer.indexOf( "Android" ) > -1;
        }

        /**
         * Supported on iOS only.
         */
        public static function get isLoginWithAccountSupported():Boolean {
            return iOS;
        }

        /**
         * Checks if a Twitter account is set in the user's iOS settings
         * and your app was granted access to use it.
         */
        public static function get isSystemAccountAvailable():Boolean {
            if( !iOS ) return false;
            validateExtensionContext();

            return mContext.call( "isSystemAccountAvailable" );
        }

        /**
         * Access token.
         * @return Access token, or <code>null</code> if user is not logged in.
         */
        public static function get accessToken():String {
            if( !isSupported ) return null;
            validateExtensionContext();

            return mContext.call( "getAccessToken" ) as String;
        }

        /**
         * Access token secret.
         * @return Access token secret, or <code>null</code> if user is not logged in.
         */
        public static function get accessTokenSecret():String {
            if( !isSupported ) return null;
            validateExtensionContext();

            return mContext.call( "getAccessTokenSecret" ) as String;
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private static function getFollowersInternal( cursor:Number = -1, callback:Function = null, userID:Number = -1, screenName:String = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getFollowers", cursor, userID, screenName, registerCallback( callback ) );
        }

        private static function getUserTimelineInternal( count:uint = 20, sinceID:String = null, maxID:String = null, excludeReplies:Boolean = false, userID:Number = -1, screenName:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getUserTimeline", count, sinceID, maxID, excludeReplies, userID, screenName, registerCallback( callback ) );
        }

        private static function getUserInternal( userID:Number = -1, screenName:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getUser", userID, screenName, registerCallback( callback ) );
        }

        private static function getLikesInternal( count:uint = 20, sinceID:String = null, maxID:String = null, userID:Number = -1, screenName:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getLikes", count, sinceID, maxID, userID, screenName, registerCallback( callback ) );
        }

        private static function getFriendsInternal( cursor:Number = -1, userID:Number = -1, screenName:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "getFriends", cursor, userID, screenName, registerCallback( callback ) );
        }

        private static function followUserInternal( userID:Number = -1, screenName:String = null, enableNotifications:Boolean = false, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "followUser", userID, screenName, enableNotifications, registerCallback( callback ) );
        }

        private static function unfollowUserInternal( userID:Number = -1, screenName:String = null, callback:Function = null ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "unfollowUser", userID, screenName, registerCallback( callback ) );
        }

        private static function sendDirectMessageInternal( text:String, userID:Number, screenName:String, callback:Function ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mContext.call( "sendDirectMessage", text, userID, screenName, registerCallback( callback ) );
        }

        /**
         * Registers given callback and generates ID which is used to look the callback up when it is time to call it.
         * @param callback Function to register.
         * @return ID of the callback.
         */
        private static function registerCallback( callback:Function ):int {
            if( callback == null ) return -1;

            var id:int;
            do {
                id = Math.random() * 100;
            } while( id in mCallbackMap );

            mCallbackMap[id] = callback;
            return id;
        }

        /**
         * Gets registered callback with given ID.
         * @param callbackID ID of the callback to retrieve.
         * @return Callback registered with given ID, or <code>null</code> if no such callback exists.
         */
        private static function getCallback( callbackID:int ):Function {
            if( callbackID == -1 || !(callbackID in mCallbackMap) ) return null;
            return mCallbackMap[callbackID];
        }

        /**
         * Unregisters callback with given ID.
         * @param callbackID ID of the callback to unregister.
         */
        private static function unregisterCallback( callbackID:int ):void {
            if( callbackID in mCallbackMap ) {
                delete mCallbackMap[callbackID];
            }
        }

        private static function getUsersFromJSONArray( jsonArray:Array ):Vector.<AIRTwitterUser> {
            const length:uint = jsonArray.length;
            const result:Vector.<AIRTwitterUser> = new <AIRTwitterUser>[];
            for( var i:uint = 0; i < length; i++ ) {
                var userInfo:Object = jsonArray[i];
                if( userInfo is String ) {
                    userInfo = JSON.parse( String( userInfo ) );
                }
                result[result.length] = getUserFromJSON( userInfo );
            }
            return result;
        }

        private static function getUserFromJSON( json:Object ):AIRTwitterUser {
            const user:AIRTwitterUser = new AIRTwitterUser();
            user.ns_airtwitter_internal::id = json.id;
            user.ns_airtwitter_internal::screenName = json.screenName;
            user.ns_airtwitter_internal::name = json.name;
            user.ns_airtwitter_internal::createdAt = json.createdAt;
            user.ns_airtwitter_internal::description = json.description;
            user.ns_airtwitter_internal::tweetsCount = json.tweetsCount;
            user.ns_airtwitter_internal::likesCount = json.likesCount;
            user.ns_airtwitter_internal::followersCount = json.followersCount;
            user.ns_airtwitter_internal::friendsCount = json.friendsCount;
            user.ns_airtwitter_internal::profileImageURL = json.profileImageURL;
            user.ns_airtwitter_internal::isProtected = json.isProtected;
            user.ns_airtwitter_internal::isVerified = json.isVerified;
            user.ns_airtwitter_internal::location = json.location;
            return user;
        }

        private static function getStatusesFromJSONArray( jsonArray:Array ):Vector.<AIRTwitterStatus> {
            const length:uint = jsonArray.length;
            const result:Vector.<AIRTwitterStatus> = new <AIRTwitterStatus>[];
            for( var i:uint = 0; i < length; i++ ) {
                var statusInfo:Object = jsonArray[i];
                if( statusInfo is String ) {
                    statusInfo = JSON.parse( String( statusInfo ) );
                }
                result[result.length] = getStatusFromJSON( statusInfo );
            }
            return result;
        }

        private static function getStatusFromJSON( json:Object ):AIRTwitterStatus {
            const status:AIRTwitterStatus = new AIRTwitterStatus();
            status.ns_airtwitter_internal::id = json.id;
            status.ns_airtwitter_internal::idString = json.idStr;
            status.ns_airtwitter_internal::text = json.text;
            status.ns_airtwitter_internal::replyToUserID = json.replyToUserID;
            status.ns_airtwitter_internal::replyToStatusID = json.replyToStatusID;
            status.ns_airtwitter_internal::likesCount = json.likesCount;
            status.ns_airtwitter_internal::retweetCount = json.retweetCount;
            status.ns_airtwitter_internal::createdAt = json.createdAt;
            status.ns_airtwitter_internal::isRetweet = json.isRetweet;
            status.ns_airtwitter_internal::isSensitive = json.isSensitive;
            if( "retweetedStatus" in json ) {
                status.ns_airtwitter_internal::retweetedStatus = getStatusFromJSON( json.retweetedStatus );
            }
            if( "user" in json ) {
                status.ns_airtwitter_internal::user = getUserFromJSON( json.user );
            }
            return status;
        }

        private static function getDirectMessagesFromJSONArray( jsonArray:Array ):Vector.<AIRTwitterDirectMessage> {
            const length:uint = jsonArray.length;
            const result:Vector.<AIRTwitterDirectMessage> = new <AIRTwitterDirectMessage>[];
            for( var i:uint = 0; i < length; i++ ) {
                var messageInfo:Object = jsonArray[i];
                if( messageInfo is String ) {
                    messageInfo = JSON.parse( String( messageInfo ) );
                }
                result[result.length] = getDirectMessageFromJSON( messageInfo );
            }
            return result;
        }

        private static function getDirectMessageFromJSON( json:Object ):AIRTwitterDirectMessage {
            const dm:AIRTwitterDirectMessage = new AIRTwitterDirectMessage();
            dm.ns_airtwitter_internal::id = json.id;
            dm.ns_airtwitter_internal::idString = json.idStr;
            dm.ns_airtwitter_internal::createdAt = json.createdAt;
            dm.ns_airtwitter_internal::text = json.text;
            dm.ns_airtwitter_internal::recipient = getUserFromJSON( json.recipient );
            dm.ns_airtwitter_internal::sender = getUserFromJSON( json.sender );
            return dm;
        }

        private static function onStatus( event:StatusEvent ):void {
            var json:Object;
            var callbackID:int;
            var callback:Function;

            const eventCode:String = event.code;
            if( eventCode != LOGIN_SUCCESS && eventCode != LOGIN_CANCEL && eventCode != LOGIN_ERROR ) {
                json = JSON.parse( event.level );
                callbackID = ("callbackID" in json) ? json.callbackID : -1;
                callback = getCallback( callbackID );
                unregisterCallback( callbackID );
            }

            switch( event.code ) {
                case LOGIN_SUCCESS:
                    mLoginInProgress = false;
                    log( "Login success" );
                    if( mLoginCallback != null ) {
                        mLoginCallback( null, false );
                        mLoginCallback = null;
                    }
                    return;

                case LOGIN_ERROR:
                    mLoginInProgress = false;
                    log( "Login error " + event.level );
                    if( mLoginCallback != null ) {
                        mLoginCallback( event.level, false );
                        mLoginCallback = null;
                    }
                    return;

                case LOGIN_CANCEL:
                    mLoginInProgress = false;
                    if( mLoginCallback != null ) {
                        mLoginCallback( null, true );
                        mLoginCallback = null;
                    }
                    return;

                case CREDENTIALS_CHECK:
                    const result:String = json.result;
                    log( "User credentials result: " + result );
                    if( mCredentialsCallback != null ) {
                        mCredentialsCallback( result == "valid", result == "missing" );
                        mCredentialsCallback = null;
                    }
                    return;

                case STATUS_QUERY_SUCCESS:
                    log( "Status query success" );
                    if( callback != null ) {
                        /* JSON will contain status info */
                        if( "success" in json ) {
                            callback( getStatusFromJSON( json ), null );
                        }
                        /* Status query did happen but there was an error parsing the status info */
                        else {
                            callback( null, json.errorMessage );
                        }
                    }
                    return;

                case STATUS_QUERY_ERROR:
                    log( "Status query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, json.errorMessage );
                    }
                    return;

                case USERS_QUERY_SUCCESS:
                    log( "Users query success" );
                    if( callback != null ) {
                        const users:Vector.<AIRTwitterUser> = getUsersFromJSONArray( json.users as Array );
                        const nextCursor:Number = (json.nextCursor == undefined) ? 0 : json.nextCursor;
                        const previousCursor:Number = (json.previousCursor == undefined) ? 0 : json.previousCursor;
                        callback( users, nextCursor, previousCursor, null );
                    }
                    return;

                case USERS_QUERY_ERROR:
                    log( "Users query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, 0, 0, json.errorMessage );
                    }
                    return;

                case TIMELINE_QUERY_SUCCESS:
                    log( "Timeline query success" );
                    if( callback != null ) {
                        const statuses:Vector.<AIRTwitterStatus> = getStatusesFromJSONArray( json.statuses as Array );
                        callback( statuses, null );
                    }
                    return;

                case TIMELINE_QUERY_ERROR:
                    log( "Timeline query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, json.errorMessage );
                    }
                    return;

                case USER_QUERY_SUCCESS:
                    log( "User query success" );
                    if( callback != null ) {
                        /* JSON will contain target user info */
                        if( "success" in json ) {
                            const user:AIRTwitterUser = getUserFromJSON( json );
                            /* Cache the user object if the query returned info for logged in user */
                            if( json.loggedInUser ) {
                                mLoggedInUser = user;
                            }
                            callback( user, null );
                        }
                        /* User query did succeed but there was an error parsing the user info */
                        else {
                            callback( null, json.errorMessage );
                        }
                    }
                    return;

                case USER_QUERY_ERROR:
                    log( "User query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, json.errorMessage );
                    }
                    return;

                case DIRECT_MESSAGE_QUERY_SUCCESS:
                    log( "Direct message query success" );
                    if( callback != null ) {
                        /* JSON will contain target message info */
                        if( "success" in json ) {
                            const message:AIRTwitterDirectMessage = getDirectMessageFromJSON( json );
                            callback( message, null );
                        }
                        /* User query did succeed but there was an error parsing the message info */
                        else {
                            callback( null, json.errorMessage );
                        }
                    }
                    return;

                case DIRECT_MESSAGE_QUERY_ERROR:
                    log( "Direct message query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, json.errorMessage );
                    }
                    return;

                case DIRECT_MESSAGES_QUERY_SUCCESS:
                    log( "Direct messages query success" );
                    if( callback != null ) {
                        const messages:Vector.<AIRTwitterDirectMessage> = getDirectMessagesFromJSONArray( json.messages as Array );
                        callback( messages, null );
                    }
                    return;

                case DIRECT_MESSAGES_QUERY_ERROR:
                    log( "Direct messages query error " + json.errorMessage );
                    if( callback != null ) {
                        callback( null, json.errorMessage );
                    }
                    return;
            }

        }

        private static function validateExtensionContext():void {
            if( !mContext ) throw new Error( "AIRTwitter extension was not initialized. Call init() first." );
        }

        private static function validateUserID( userID:Number ):void {
            if( userID < 0 ) throw new ArgumentError( "Parameter userID must be greater than zero." );
        }

        private static function validateStatusID( statusID:String ):void {
            if( !statusID ) throw new ArgumentError( "Parameter statusID cannot be null." );
            if( Number( statusID ) < 0 ) throw new ArgumentError( "Parameter statusID must be greater than zero." );
        }

        private static function validateScreenName( screenName:String ):void {
            if( !screenName ) throw new ArgumentError( "Parameter screenName cannot be null." );
        }

        private static function onInvokeHandler( event:InvokeEvent ):void {
            log( "onInvoke " + event.reason );

            /* We are interested in "standard" invoke reason to check if user is
             * manually returning to app after closing the login browser tab */
            if( mLoginInProgress && event.reason && event.reason.toLowerCase() == "standard" ) {
                mStandardInvokeTimer = new Timer( 50, 1 );
                mStandardInvokeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onStandardInvoke );
                mStandardInvokeTimer.start();
                return;
            }

            /* Handle openURL invoke event */
            if( event.reason && event.reason.toLowerCase() == "openurl" ) {
                /* "openurl" invoke was dispatched shortly after "standard" (happens on iOS), we want to stop the timer */
                if( mStandardInvokeTimer ) {
                    mStandardInvokeTimer.stop();
                    disposeStandardInvokeTimer();
                }

                var url:String = String( event.arguments[0] );
                if( url && url.indexOf( mURLScheme ) == 0 ) {
                    mContext.call( "applicationOpenURL", url );
                }
            }
        }

        private static function onStandardInvoke( event:TimerEvent ):void {
            disposeStandardInvokeTimer();

            log( "Returned to app manually after login attempt, thus login cancelled" );
            mLoginInProgress = false;
            /* Dispatch login callback with "wasCancelled" flag */
            if( mLoginCallback != null ) {
                mLoginCallback( null, true );
                mLoginCallback = null;
            }
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

        private static function disposeStandardInvokeTimer():void {
            mStandardInvokeTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, onStandardInvoke );
            mStandardInvokeTimer = null;
        }

        private static function get iOS():Boolean {
            return Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        }

    }
}
