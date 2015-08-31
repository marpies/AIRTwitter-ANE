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
import com.marpies.ane.twitter.utils.FREObjectUtils;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class ApplicationOpenURLFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		try {
			// todo: handle standard invoke
			String url = FREObjectUtils.getString( args[0] );
			/* URL class does not parse custom protocols, replace it with http */
			url = url.replaceFirst( ".*:", "http:" );
			String query = new URL( url ).getQuery();
			Map<String, String> parameters = parametersFromQuery( query );
//			String token = parameters.get( "oauth_token" );
			String verifier = parameters.get( "oauth_verifier" );
			String denied = parameters.get( "denied" );
			if( denied != null || verifier == null ) {
				AIR.log( "App was launched after cancelled attempt to login" );
				AIR.dispatchEvent( AIRTwitterEvent.LOGIN_CANCEL );
				return null;
			} else {
				AIR.log( "App launched with PIN" );
			}
			TwitterAPI.getAccessTokensForPIN( verifier );
		} catch( MalformedURLException e ) {
			AIR.dispatchEvent( AIRTwitterEvent.LOGIN_ERROR, e.getMessage() );
		}

		return null;
	}

	private Map<String, String> parametersFromQuery( String query ) {
		String[] params = query.split( "&" );
		Map<String, String> map = new HashMap<String, String>();
		for( String param : params ) {
			String[] pair = param.split( "=" );
			if( pair.length != 2 ) continue;

			String name = pair[0];
			String value = pair[1];
			map.put( name, value );
		}
		return map;
	}

}
