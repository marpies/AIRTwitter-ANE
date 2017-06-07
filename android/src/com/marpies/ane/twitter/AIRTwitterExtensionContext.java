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

package com.marpies.ane.twitter;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.marpies.ane.twitter.functions.*;
import com.marpies.ane.twitter.utils.AIR;

import java.util.HashMap;
import java.util.Map;

public class AIRTwitterExtensionContext extends FREContext {

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();

		functions.put( "init", new InitFunction() );
		functions.put( "login", new LoginFunction() );
		functions.put( "loginWithAccessToken", new LoginWithAccessTokenFunction() );
		functions.put( "logout", new LogoutFunction() );

		functions.put( "updateStatus", new UpdateStatusFunction() );
		functions.put( "getFollowers", new GetFollowersFunction() );
		functions.put( "getHomeTimeline", new GetHomeTimelineFunction() );
		functions.put( "getUserTimeline", new GetUserTimelineFunction() );
		functions.put( "getLikes", new GetLikesFunction() );
		functions.put( "getFriends", new GetFriendsFunction() );
		functions.put( "getLoggedInUser", new GetLoggedInUserFunction() );
		functions.put( "getUser", new GetUserFunction() );

		functions.put( "followUser", new FollowUserFunction() );
		functions.put( "unfollowUser", new UnfollowUserFunction() );

		functions.put( "retweetStatus", new RetweetStatusFunction() );
		functions.put( "likeStatus", new LikeStatusFunction() );
		functions.put( "undoLikeStatus", new UndoLikeStatusFunction() );
		functions.put( "deleteStatus", new DeleteStatusFunction() );

		functions.put( "sendDirectMessage", new SendDirectMessageFunction() );
		functions.put( "getDirectMessages", new GetDirectMessagesFunction() );
		functions.put( "getSentDirectMessages", new GetSentDirectMessagesFunction() );

		functions.put( "getAccessToken", new GetAccessTokenFunction() );
		functions.put( "getAccessTokenSecret", new GetAccessTokenSecretFunction() );

		functions.put( "applicationOpenURL", new ApplicationOpenURLFunction() );

		return functions;
	}

	@Override
	public void dispose() {
		AIR.setContext( null );
	}
}
