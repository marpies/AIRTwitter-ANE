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
import com.marpies.ane.twitter.utils.StringUtils;
import com.marpies.ane.twitter.utils.UserUtils;
import twitter4j.*;

public class UnfollowUserFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		long userID = FREObjectUtils.getDouble( args[0] ).longValue();
		String screenName = (args[1] == null) ? null : FREObjectUtils.getString( args[1] );
		mCallbackID = FREObjectUtils.getInt( args[2] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );
		if( screenName != null ) {
			twitter.destroyFriendship( screenName );
		} else {
			twitter.destroyFriendship( userID );
		}

		return null;
	}

	@Override
	public void destroyedFriendship( User user ) {
		AIR.log( "Success unfollowing user: " + user.getScreenName() );
		try {
			JSONObject userJSON = UserUtils.getJSON( user );
			userJSON.put( "callbackID", mCallbackID );
			userJSON.put( "success", "true" );
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_SUCCESS, userJSON.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_SUCCESS,
					StringUtils.getEventErrorJSON( mCallbackID, e.getMessage() )
			);
		}
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.DESTROY_FRIENDSHIP ) {
			AIR.log( "Error trying to unfollow user: " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.USER_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

}
