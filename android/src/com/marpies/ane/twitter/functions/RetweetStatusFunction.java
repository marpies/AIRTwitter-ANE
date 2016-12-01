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

public class RetweetStatusFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		long statusID = Long.valueOf( FREObjectUtils.getString( args[0] ) );
		mCallbackID = FREObjectUtils.getInt( args[1] );

		AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );
		twitter.retweetStatus( statusID );

		return null;
	}

	@Override
	public void retweetedStatus( Status retweetedStatus ) {
		AIR.log( "Retweet of '" + retweetedStatus.getText() + "' success" );
		StatusUtils.dispatchStatus( retweetedStatus, mCallbackID );
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.RETWEET_STATUS ) {
			AIR.log( "Error retweeting status: " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

}
