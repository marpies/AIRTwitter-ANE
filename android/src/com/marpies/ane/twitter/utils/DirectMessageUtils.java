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

package com.marpies.ane.twitter.utils;

import com.marpies.ane.twitter.data.AIRTwitterEvent;
import twitter4j.*;

public class DirectMessageUtils {

	/**
	 * Creates JSON from given response list and dispatches generic event.
	 * Helper method for queries like getDirectMessages, getSentDirectMessages...
	 * @param messages
	 * @param callbackID
	 */
	public static void dispatchDirectMessages( ResponseList<DirectMessage> messages, int callbackID ) {
		try {
			AIR.log( "Got response with " + messages.size() + " direct messages" );
			/* Create array of messages */
			JSONArray dms = new JSONArray();
			for( DirectMessage message : messages ) {
				/* Create JSON for the message and put it to the array */
				dms.put( getJSON( message ).toString() );
			}
			JSONObject result = new JSONObject();
			result.put( "messages", dms );
			result.put( "listenerID", callbackID );
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGES_QUERY_SUCCESS, result.toString() );
		} catch( JSONException e ) {
			AIR.dispatchEvent( AIRTwitterEvent.DIRECT_MESSAGES_QUERY_ERROR,
					StringUtils.getEventErrorJSON( callbackID, "Error creating result JSON: " + e.getMessage() )
			);
		}
	}

	public static JSONObject getJSON( DirectMessage message ) throws JSONException {
		JSONObject dmJSON = new twitter4j.JSONObject();
		dmJSON.put( "id", message.getId() );
		dmJSON.put( "idStr", String.valueOf( message.getId() ) );
		dmJSON.put( "text", message.getText() );
		dmJSON.put( "createdAt", message.getCreatedAt() );
		dmJSON.put( "recipient", UserUtils.getJSON( message.getRecipient() ) );
		dmJSON.put( "sender", UserUtils.getJSON( message.getSender() ) );
		return dmJSON;
	}

}
