/*
 * Copyright 2017 Marcel Piestansky (http://marpies.com)
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

package com.marpies.ane.twitter.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.FREObjectUtils;
import com.marpies.ane.twitter.utils.StringUtils;
import twitter4j.AsyncTwitter;
import twitter4j.TwitterException;
import twitter4j.TwitterMethod;
import twitter4j.User;
import twitter4j.auth.AccessToken;

public class LoginWithAccessTokenFunction extends BaseFunction {

    private AccessToken mToken = null;

    @Override
    public FREObject call(FREContext context, FREObject[] args) {
        super.call(context, args);

        AIR.log( "Attempting login with access token" );

        if( TwitterAPI.hasAccessTokens() ) {
            AIR.log( "User is already logged in" );
            AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, "User is already logged in" );
            return null;
        }

        AIR.log( "Setting existing token / secret and verifying" );

        String accessToken = FREObjectUtils.getString( args[0] );
        String accessTokenSecret = FREObjectUtils.getString( args[1] );

        /* Create access token and verify credentials */
        mToken = new AccessToken( accessToken, accessTokenSecret );
        AsyncTwitter twitter = TwitterAPI.getAsyncInstance( mToken );
        twitter.addListener( this );
        twitter.verifyCredentials();

        return null;
    }

    @Override
    public void verifiedCredentials( User user ) {
        TwitterAPI.setLoggedInUser( user );
        TwitterAPI.storeAccessTokens( mToken );
        AIR.log( "Custom token / secret is valid for user: " + user.getScreenName() );
        AIR.dispatchEvent( AIRTwitterEvent.LOGIN_SUCCESS );
    }

    @Override
    public void onException(TwitterException te, TwitterMethod method ) {
        if( method == TwitterMethod.VERIFY_CREDENTIALS ) {
            AIR.log( "Verify credentials error: " + te.getMessage() );
            AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, StringUtils.removeLineBreaks( te.getMessage() ) );
        }
    }

}

