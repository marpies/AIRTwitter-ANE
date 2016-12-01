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

package com.marpies.ane.twitter.utils;

import com.marpies.ane.twitter.data.AIRTwitterEvent;
import twitter4j.*;

public class StatusUtils {

	/**
	 * Creates JSON from given response list and dispatches generic event.
	 * Helper method for queries like getHomeTimeline, getLikes...
	 * @param statuses
	 * @param excludeReplies
	 * @param callbackID
	 */
	public static void dispatchStatuses( ResponseList<Status> statuses, boolean excludeReplies, final int callbackID ) {
		try {
			AIR.log( "Got response with " + statuses.size() + " statuses" + (excludeReplies ? " (yet to filter out replies)" : "") );
			/* Create array of statuses (tweets) */
			JSONArray tweets = new JSONArray();
			for( Status status : statuses ) {
				/* Exclude reply if requested */
				if( excludeReplies && status.getInReplyToUserId() >= 0 ) continue;
				/* Create JSON for the status and put it to the array */
				JSONObject statusJSON = getJSON( status );
				tweets.put( statusJSON.toString() );
			}
			JSONObject result = new JSONObject();
			result.put( "statuses", tweets );
			result.put( "listenerID", callbackID );
			AIR.dispatchEvent( AIRTwitterEvent.TIMELINE_QUERY_SUCCESS, result.toString() );
		} catch( JSONException e ) {
			AIR.dispatchEvent( AIRTwitterEvent.TIMELINE_QUERY_ERROR,
					StringUtils.getEventErrorJSON( callbackID, "Error creating result JSON: " + e.getMessage() )
			);
		}
	}

	public static JSONObject getJSON( Status status ) throws JSONException {
		JSONObject statusJSON = new JSONObject();
		statusJSON.put( "id", status.getId() );
		statusJSON.put( "idStr", String.valueOf( status.getId() ) );
		statusJSON.put( "text", status.getText() );
		statusJSON.put( "replyToUserID", status.getInReplyToUserId() );
		statusJSON.put( "replyToStatusID", status.getInReplyToStatusId() );
		statusJSON.put( "likesCount", status.getFavoriteCount() );
		statusJSON.put( "retweetCount", status.getRetweetCount() );
		statusJSON.put( "isRetweet", status.isRetweet() );
		statusJSON.put( "isSensitive", status.isPossiblySensitive() );
		statusJSON.put( "createdAt", status.getCreatedAt() );
		Status retweetedStatus = status.getRetweetedStatus();
		if( retweetedStatus != null ) {
			statusJSON.put( "retweetedStatus", getJSON( retweetedStatus ) );
		}
		User user = status.getUser();
		if( user != null ) {
			statusJSON.put( "user", UserUtils.getJSON( user ) );
		}
		return statusJSON;
	}

	public static void dispatchStatus( Status status, int callbackID ) {
		try {
			JSONObject statusJSON = StatusUtils.getJSON( status );
			statusJSON.put( "listenerID", callbackID );
			statusJSON.put( "success", "true" );
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_SUCCESS, statusJSON.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_SUCCESS,
					StringUtils.getEventErrorJSON( callbackID, e.getMessage() )
			);
		}
	}

}
