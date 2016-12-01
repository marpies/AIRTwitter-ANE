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

public class StringUtils {

	public static String getEventErrorJSON( final int callbackID, String errorMessage ) {
		return String.format( "{ \"callbackID\": %d, \"errorMessage\": \"%s\" }",
				callbackID,
				/* The error message may contain line breaks - these need
				 * to be removed so that JSON parsing errors do not occur */
				removeLineBreaks( errorMessage ) );
	}

	public static String removeLineBreaks( String message ) {
		return message.replace( "\n", "" ).replace( "\r", "" );
	}

}
