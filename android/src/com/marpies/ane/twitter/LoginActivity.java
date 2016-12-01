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

package com.marpies.ane.twitter;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.StringUtils;
import twitter4j.*;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;

public class LoginActivity extends Activity {

	public static final String EXTRA_PREFIX = "com.marpies.ane.twitter.LoginActivity";

	/* Track if activity is resumed after being stopped to
	 * determine if the login attempt was cancelled.
	 * Correct order: create -> resume -> stop -> destroy.
	 * When cancelled: create -> resume -> stop -> resume ... */
	private Boolean mStopped;

	@Override
	protected void onCreate( Bundle savedInstanceState ) {
		super.onCreate( savedInstanceState );

		mStopped = false;

		Bundle extras = getIntent().getExtras();
		boolean forceLogin = extras.getBoolean( EXTRA_PREFIX + ".forceLogin" );

		/* If we have access tokens (user has logged in before) */
		if( TwitterAPI.hasAccessTokens() ) {
			AIR.log( "User is already logged in" );
			AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, "User is already logged in" );
			finish();
		}
		/* Get new access tokens */
		else {
			final AsyncTwitter twitter = TwitterAPI.getAsyncInstance();
			twitter.addListener( getOAuthRequestTokenListener( forceLogin ) );
			twitter.getOAuthRequestTokenAsync( TwitterAPI.getCallbackURL() );
		}
	}

	@Override
	public void onBackPressed() {
		finish();
	}

	@Override
	protected void onResume() {
		super.onResume();
		AIR.log( "LoginActivity onResume();" );
		/* If Activity is resumed after being stopped it most likely means the login was cancelled */
		if( mStopped ) {
			AIR.dispatchEvent( AIRTwitterEvent.LOGIN_CANCEL );
			finish();
		}
	}

	@Override
	protected void onStop() {
		super.onStop();
		mStopped = true;
		AIR.log( "LoginActivity onStop();" );
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		AIR.log( "LoginActivity onDestroy();" );
	}

	/**
	 *
	 *
	 * Private API
	 *
	 *
	 */

	private TwitterAdapter getOAuthRequestTokenListener( final boolean forceLogin ) {
		return new TwitterAdapter() {
			@Override
			public void gotOAuthRequestToken( RequestToken token ) {
				TwitterAPI.setRequestToken( token );
				StringBuilder urlBuilder = new StringBuilder( token.getAuthenticationURL() );
				if( forceLogin ) {
					urlBuilder.append( "&force_login=true" );
				}
				/* Launch browser */
				LoginActivity.this.startActivity( new Intent( Intent.ACTION_VIEW, Uri.parse( urlBuilder.toString() ) ) );
			}

			@Override
			public void onException( TwitterException te, TwitterMethod method ) {
				if( method == TwitterMethod.OAUTH_REQUEST_TOKEN ) {
					AIR.log( "Request token exception " + te.getMessage() );
					AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, StringUtils.removeLineBreaks( te.getMessage() ) );
				}
				finish();
			}
		};
	}

}