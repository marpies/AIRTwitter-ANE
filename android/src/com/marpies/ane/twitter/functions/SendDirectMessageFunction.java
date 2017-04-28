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
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.*;
import twitter4j.*;

public class SendDirectMessageFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		String message = FREObjectUtils.getString( args[0] );
        String userID = (args[1] == null) ? null : FREObjectUtils.getString( args[1] );
		String screenName = (args[2] == null) ? null : FREObjectUtils.getString( args[2] );
		mCallbackID = FREObjectUtils.getInt( args[3] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );
		if( screenName != null ) {
			twitter.sendDirectMessage( screenName, message );
		} else {
			twitter.sendDirectMessage( Long.valueOf( userID ), message );
		}

		return null;
	}

	@Override
	public void sentDirectMessage( DirectMessage message ) {
		AIR.log( "Success sending DM '" + message.getText() + "'" );
		try {
			JSONObject dmJSON = DirectMessageUtils.getJSON( message );
			dmJSON.put( "listenerID", mCallbackID );
			dmJSON.put( "success", "true" );
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGE_QUERY_SUCCESS, dmJSON.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGE_QUERY_SUCCESS,
					StringUtils.getEventErrorJSON( mCallbackID, e.getMessage() )
			);
		}
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.SEND_DIRECT_MESSAGE ) {
			AIR.log( "Error trying to send DM: " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGE_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}
}
