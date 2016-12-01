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
import com.adobe.fre.FREExtension;
import com.marpies.ane.twitter.utils.AIR;

public class AIRTwitterExtension implements FREExtension {

	@Override
	public void initialize() { }

	@Override
	public FREContext createContext( String s ) {
		AIR.setContext( new AIRTwitterExtensionContext() );
		return AIR.getContext();
	}

	@Override
	public void dispose() {
		AIR.setContext( null );
	}

}
