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

package com.marpies.ane.twitter.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.FREObjectUtils;
import com.marpies.ane.twitter.utils.StringUtils;
import com.marpies.ane.twitter.utils.UserUtils;
import twitter4j.*;
import twitter4j.auth.AccessToken;

public class GetLoggedInUserFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		mCallbackID = FREObjectUtils.getInt( args[0] );

		User user = TwitterAPI.getLoggedInUser();

		/* Return cached object */
		if( user != null ) {
			try {
				dispatchUser( user );
			} catch( Exception e ) {
				e.printStackTrace();
				AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_ERROR, StringUtils.getEventErrorJSON(
						mCallbackID, e.getMessage()
				) );
			}
		}
		/* Request user info */
		else if( TwitterAPI.hasAccessTokens() ) {
			AccessToken accessToken = TwitterAPI.getAccessToken();
			AsyncTwitter twitter = TwitterAPI.getAsyncInstance( accessToken );
			twitter.addListener( this );
			twitter.showUser( accessToken.getUserId() );
		}
		/* User not logged in, error */
		else {
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_ERROR, StringUtils.getEventErrorJSON(
			        mCallbackID, "User is not logged in."
			) );
		}

		return null;
	}

	@Override
	public void gotUserDetail( User user ) {
		AIR.log( "Successfully retrieved logged in user info" );
		TwitterAPI.setLoggedInUser( user );
		try {
			dispatchUser( user );
		} catch( JSONException e ) {
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_SUCCESS, StringUtils.getEventErrorJSON(
					mCallbackID, "Error parsing returned user info."
			) );
		}
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.SHOW_USER ) {
			AIR.log( "Error retrieving user info " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_ERROR, StringUtils.getEventErrorJSON(
					mCallbackID, te.getMessage()
			) );
		}
	}

	private void dispatchUser( User user ) throws JSONException {
		JSONObject userJSON = UserUtils.getJSON( user );
		userJSON.put( "listenerID", mCallbackID );
		userJSON.put( "success", true );
		userJSON.put( "loggedInUser", true );	// So that we can cache the user object in AS3
		AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_SUCCESS, userJSON.toString() );
	}

}
