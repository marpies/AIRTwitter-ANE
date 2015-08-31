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

package com.marpies.ane.twitter.data;

public class AIRTwitterEvent {

	public static final String LOGIN_SUCCESS = "loginSuccess";
	public static final String LOGIN_ERROR = "loginError";
	public static final String LOGIN_CANCEL = "loginCancel";

	public static final String CREDENTIALS_CHECK = "credentialsCheck";

	public static final String STATUS_QUERY_SUCCESS = "statusQuerySuccess";
	public static final String STATUS_QUERY_ERROR = "statusQueryError";

	public static final String USERS_QUERY_SUCCESS = "usersQuerySuccess";
	public static final String USERS_QUERY_ERROR = "usersQueryError";

	public static final String TIMELINE_QUERY_SUCCESS = "timelineQuerySuccess";
	public static final String TIMELINE_QUERY_ERROR = "timelineQueryError";

	public static final String USER_QUERY_SUCCESS = "userQuerySuccess";
	public static final String USER_QUERY_ERROR = "userQueryError";
}
