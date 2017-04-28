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
import com.marpies.ane.twitter.utils.StatusUtils;
import com.marpies.ane.twitter.utils.StringUtils;
import twitter4j.*;

public class GetLikesFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		int count = FREObjectUtils.getInt( args[0] );
		long sinceID = (args[1] == null) ? -1 : Long.valueOf( FREObjectUtils.getString( args[1] ) );
		long maxID = (args[2] == null) ? -1 : Long.valueOf( FREObjectUtils.getString( args[2] ) );
        String userID = (args[3] == null) ? null : FREObjectUtils.getString( args[3] );
		String screenName = (args[4] == null) ? null : FREObjectUtils.getString( args[4] );
		mCallbackID = FREObjectUtils.getInt( args[5] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );

		/* If user ID was not provided then use the one of currently logged in user */
		if( userID == null ) {
            userID = String.valueOf( TwitterAPI.getLoggedInUser().getId() );
		}

		Paging paging = getPaging( count, sinceID, maxID );
		if( paging != null ) {
			if( screenName != null ) {
				twitter.getFavorites( screenName, paging );
			} else {
				twitter.getFavorites( Long.valueOf( userID ), paging );
			}
		} else {
			if( screenName != null ) {
				twitter.getFavorites( screenName );
			} else {
				twitter.getFavorites( Long.valueOf( userID ) );
			}
		}

		return null;
	}

	@Override
	public void gotFavorites( ResponseList<Status> statuses ) {
		/* Creates JSON out of the result statuses and dispatches event */
		StatusUtils.dispatchStatuses( statuses, false, mCallbackID );
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.FAVORITES ) {
			AIR.log( "Error retreiving liked statuses " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.TIMELINE_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

	private Paging getPaging( int count, long sinceID, long maxID ) {
		Paging paging = null;
		if( count != 20 ) {
			paging = new Paging();
			paging.setCount( count );
		}
		if( sinceID >= 0 ) {
			paging = (paging == null) ? new Paging() : paging;
			paging.setSinceId( sinceID );
		}
		if( maxID >= 0 ) {
			paging = (paging == null) ? new Paging() : paging;
			paging.setMaxId( maxID );
		}
		return paging;
	}

}
