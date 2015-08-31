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

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

import java.net.URL;

public class AsyncImageLoader extends AsyncTask<String, Void, Bitmap> {

	@Override
	protected Bitmap doInBackground( String... strings ) {
		String imageURL = strings[0];
		URL url;
		Bitmap bmp = null;
		try {
			if( imageURL.startsWith( "http" ) ) {
				url = new URL( imageURL );
				bmp = BitmapFactory.decodeStream( url.openConnection().getInputStream() );
			} else {
				bmp = BitmapFactory.decodeFile( imageURL );
			}
		} catch( Exception e ) { }
		return bmp;
	}

}
