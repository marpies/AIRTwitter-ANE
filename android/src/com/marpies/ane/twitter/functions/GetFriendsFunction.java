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
import com.marpies.ane.twitter.utils.AIR;
import com.marpies.ane.twitter.utils.FREObjectUtils;
import com.marpies.ane.twitter.utils.StringUtils;
import com.marpies.ane.twitter.utils.UserUtils;
import twitter4j.*;

public class GetFriendsFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		long cursor = FREObjectUtils.getDouble( args[0] ).longValue();
		long userID = FREObjectUtils.getDouble( args[1] ).longValue();
		String screenName = (args[2] == null) ? null : FREObjectUtils.getString( args[2] );
		mCallbackID = FREObjectUtils.getInt( args[3] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );

		/* Query followers for screen name */
		if( screenName != null ) {
			twitter.getFriendsList( screenName, cursor );
		}
		/* Or query for user ID */
		else {
			/* If user ID was not provided then use the one of currently logged in user */
			if( userID < 0 ) {
				userID = TwitterAPI.getLoggedInUser().getId();
			}
			twitter.getFriendsList( userID, cursor );
		}

		return null;
	}

	@Override
	public void gotFriendsList( PagableResponseList<User> users ) {
		/* Creates JSON out of the result users and dispatches event */
		UserUtils.dispatchUsers( users, mCallbackID );
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.FRIENDS_LIST ) {
			AIR.dispatchEvent( AIRTwitterEvent.USERS_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

}
