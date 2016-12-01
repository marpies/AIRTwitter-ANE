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

package com.marpies.ane.twitter.data;

import android.content.Context;
import android.content.SharedPreferences;
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.StringUtils;
import twitter4j.*;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;

public class TwitterAPI {

	private static Configuration mConfiguration;
	private static TwitterFactory mTwitterFactory;
	private static AsyncTwitterFactory mAsyncTwitterFactory;
	private static RequestToken mRequestToken;
	private static AccessToken mAccessToken;
	private static User mLoggedInUser;

	private static SharedPreferences mPreferences;
	private static String mURLScheme;
	private static Boolean mIsInitialized = false;

	/**
	 *
	 *
	 * Public API
	 *
	 *
	 */

	public static void init( String consumerKey, String consumerSecret, String urlScheme ) {
		if( mIsInitialized ) return;

		mURLScheme = urlScheme;
		ConfigurationBuilder builder = new ConfigurationBuilder();
		builder.setOAuthConsumerKey( consumerKey );
		builder.setOAuthConsumerSecret( consumerSecret );
		mConfiguration = builder.build();
		mIsInitialized = true;
	}

	public static void getAccessTokensForPIN( String PIN ) {
		final AsyncTwitter twitter = getAsyncInstance();
		twitter.addListener( new TwitterAdapter() {
			@Override
			public void gotOAuthAccessToken( AccessToken token ) {
				AIR.log( "Retrieved access tokens" );
				/* Store access tokens */
				TwitterAPI.storeAccessTokens( token );
				AIR.dispatchEvent( AIRTwitterEvent.LOGIN_SUCCESS );
			}

			@Override
			public void onException( TwitterException te, TwitterMethod method ) {
				if( method == TwitterMethod.OAUTH_ACCESS_TOKEN ) {
					AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, StringUtils.removeLineBreaks( te.getMessage() ) );
				}
			}
		} );
		twitter.getOAuthAccessTokenAsync( mRequestToken, PIN );
	}

	public static void clearAccessTokens() {
		mAccessToken = null;
		mLoggedInUser = null;
		mRequestToken = null;

		getInstance().setOAuthAccessToken( null );
		getAsyncInstance().setOAuthAccessToken( null );

		removeAccessTokenPreferences();
	}

	public static void removeAccessTokenPreferences() {
		SharedPreferences.Editor editor = getPreferences().edit();
		editor.remove( "accessToken" ).remove( "accessTokenSecret" );
		editor.apply();
	}

	/**
	 *
	 *
	 * Private API
	 *
	 *
	 */

	private static void storeAccessTokens( AccessToken token ) {
		mAccessToken = token;

		SharedPreferences.Editor editor = getPreferences().edit();
		editor.putString( "accessToken", token.getToken() )
				.putString( "accessTokenSecret", token.getTokenSecret() );
		editor.apply();
	}

	private static SharedPreferences getPreferences() {
		if( mPreferences == null ) {
			mPreferences = AIR.getContext().getActivity().getApplicationContext().getSharedPreferences( "TwitterTokens", Context.MODE_PRIVATE );
		}
		return mPreferences;
	}

	/**
	 *
	 *
	 * Getters / Setters
	 *
	 *
	 */

	public static Boolean hasAccessTokens() {
		return getPreferences().contains( "accessToken" );
	}

	public static User getLoggedInUser() {
		return mLoggedInUser;
	}

	public static void setLoggedInUser( User user ) {
		mLoggedInUser = user;
	}

	public static AccessToken getAccessToken() {
		if( mAccessToken != null ) {
			return mAccessToken;
		}
		if( hasAccessTokens() ) {
			mAccessToken = new AccessToken( getPreferences().getString( "accessToken", "" ), getPreferences().getString( "accessTokenSecret", "" ) );
			return mAccessToken;
		}
		return null;
	}

	public static Twitter getInstance() {
		if( mTwitterFactory == null ) {
			mTwitterFactory = new TwitterFactory( mConfiguration );
		}
		return mTwitterFactory.getInstance();
	}

	public static Twitter getInstance( AccessToken token ) {
		if( mTwitterFactory == null ) {
			mTwitterFactory = new TwitterFactory( mConfiguration );
		}
		return mTwitterFactory.getInstance( token );
	}

	public static AsyncTwitter getAsyncInstance() {
		if( mAsyncTwitterFactory == null ) {
			mAsyncTwitterFactory = new AsyncTwitterFactory( mConfiguration );
		}
		return mAsyncTwitterFactory.getInstance();
	}

	public static AsyncTwitter getAsyncInstance( AccessToken token ) {
		if( mAsyncTwitterFactory == null ) {
			mAsyncTwitterFactory = new AsyncTwitterFactory( mConfiguration );
		}
		return mAsyncTwitterFactory.getInstance( token );
	}

	public static String getCallbackURL() {
		return mURLScheme + "://twitter_access_tokens";
	}

	public static void setRequestToken( RequestToken token ) {
		mRequestToken = token;
	}

	public static Boolean isInitialized() {
		return mIsInitialized;
	}

}
