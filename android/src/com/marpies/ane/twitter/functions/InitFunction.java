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

package com.marpies.ane.twitter.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.FREObjectUtils;
import twitter4j.*;

public class InitFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		if( TwitterAPI.isInitialized() ) return null;

		String consumerKey = FREObjectUtils.getString( args[0] );
		String consumerSecret = FREObjectUtils.getString( args[1] );
		String urlScheme = FREObjectUtils.getString( args[2] );
		Boolean showLogs = FREObjectUtils.getBoolean( args[3] );

		AIR.setLogEnabled( showLogs );

		TwitterAPI.init( consumerKey, consumerSecret, urlScheme );

		/* Verify cached access tokens */
		if( TwitterAPI.hasAccessTokens() ) {
			AIR.log( "Verifying credentials" );
			AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
			twitter.addListener( this );
			twitter.verifyCredentials();
		} else {
			AIR.dispatchEvent( AIRTwitterEvent.CREDENTIALS_CHECK, "{ \"result\": \"missing\" }" );
		}

		return null;
	}

	@Override
	public void verifiedCredentials( User user ) {
		TwitterAPI.setLoggedInUser( user );
		AIR.log( "Verify credentials success" );
		AIR.dispatchEvent( AIRTwitterEvent.CREDENTIALS_CHECK, "{ \"result\": \"valid\" }" );
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.VERIFY_CREDENTIALS ) {
			AIR.log( "Verify credentials error: " + te.getMessage() );
			/* Cached credentials are invalid, remove them from preferences */
			TwitterAPI.removeAccessTokenPreferences();
			AIR.dispatchEvent( AIRTwitterEvent.CREDENTIALS_CHECK, "{ \"result\": \"invalid\" }" );
		}
	}

}
