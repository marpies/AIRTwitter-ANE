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

public class UserUtils {

	/**
	 * Creates JSON from given response list and dispatches generic event.
	 * Helper method for queries like getFollowers and getFriends.
	 * @param users
	 * @param callbackID
	 */
	public static void dispatchUsers( PagableResponseList<User> users, final int callbackID ) {
		try {
			AIR.log( "Got response with " + users.size() + " users" );
			/* Create array of JSON users */
			JSONArray usersJSON = new JSONArray();
			for( User user : users ) {
				/* Create JSON for each user and put it to the array */
				JSONObject userJSON = getJSON( user );
				usersJSON.put( userJSON.toString() );
			}
			JSONObject result = new JSONObject();
			result.put( "users", usersJSON );
			if( users.hasNext() ) {
				result.put( "nextCursor", users.getNextCursor() );
			}
			if( users.hasPrevious() ) {
				result.put( "previousCursor", users.getPreviousCursor() );
			}
			result.put( "listenerID", callbackID );
			AIR.dispatchEvent( AIRTwitterEvent.USERS_QUERY_SUCCESS, result.toString() );
		} catch( JSONException e ) {
			AIR.dispatchEvent( AIRTwitterEvent.USERS_QUERY_ERROR,
					StringUtils.getEventErrorJSON( callbackID, "Error creating result JSON: " + e.getMessage() )
			);
		}
	}

	public static JSONObject getJSON( User user ) throws JSONException {
		JSONObject userJSON = new JSONObject();
		userJSON.put( "id", user.getId() );
		userJSON.put( "screenName", user.getScreenName() );
		userJSON.put( "name", user.getName() );
		userJSON.put( "createdAt", user.getCreatedAt() );
		userJSON.put( "description", user.getDescription() );
		userJSON.put( "tweetsCount", user.getStatusesCount() );
		userJSON.put( "likesCount", user.getFavouritesCount() );
		userJSON.put( "followersCount", user.getFollowersCount() );
		userJSON.put( "friendsCount", user.getFriendsCount() );
		userJSON.put( "profileImageURL", user.getProfileImageURL() );
		userJSON.put( "isProtected", user.isProtected() );
		userJSON.put( "isVerified", user.isVerified() );
		userJSON.put( "location", user.getLocation() );
		return userJSON;
	}

}
