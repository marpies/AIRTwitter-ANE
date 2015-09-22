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
import com.marpies.ane.twitter.utils.DirectMessageUtils;
import com.marpies.ane.twitter.utils.FREObjectUtils;
import com.marpies.ane.twitter.utils.StringUtils;
import twitter4j.*;

public class GetSentDirectMessagesFunction extends BaseFunction {
	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		int count = FREObjectUtils.getInt( args[0] );
		long sinceID = FREObjectUtils.getDouble( args[1] ).longValue();
		long maxID = FREObjectUtils.getDouble( args[2] ).longValue();
		int page = FREObjectUtils.getInt( args[3] );
		mCallbackID = FREObjectUtils.getInt( args[4] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );

		Paging paging = getPaging( count, sinceID, maxID, page );
		if( paging != null ) {
			twitter.getSentDirectMessages( paging );
		} else {
			twitter.getSentDirectMessages();
		}

		return null;
	}

	@Override
	public void gotSentDirectMessages( ResponseList<DirectMessage> messages ) {
		DirectMessageUtils.dispatchDirectMessages( messages, mCallbackID );
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.SENT_DIRECT_MESSAGES ) {
			AIR.log( "SENT DIRECT MESSAGES QUERY ERROR " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGES_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

	private Paging getPaging( int count, long sinceID, long maxID, int page ) {
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
		if( page > 0 ) {
			paging = (paging == null) ? new Paging() : paging;
			paging.setPage( page );
		}
		return paging;
	}

}
