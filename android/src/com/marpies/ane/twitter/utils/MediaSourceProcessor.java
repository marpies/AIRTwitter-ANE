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

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import com.marpies.ane.twitter.data.MediaSource;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Creates Files from media sources (local and remote URLs and Bitmap).
 */
public class MediaSourceProcessor extends AsyncTask<List<MediaSource>, Void, List<File>> {

	@Override
	protected List<File> doInBackground( List<MediaSource>... params ) {
		List<MediaSource> mediaSources = params[0];
		List<File> mediaFiles = new ArrayList<File>();
		for( MediaSource asset : mediaSources ) {
			if( asset.isBitmap() ) {
				addFileFromBitmap( asset.getBitmap(), mediaFiles );
			} else {
				String url = asset.getURL();
				/* Remote URL */
				if( url.startsWith( "http" ) ) {
					addFileFromBitmap( loadRemoteImage( url ), mediaFiles );
				}
				/* Local URL */
				else {
					mediaFiles.add( new File( url ) );
				}
			}
		}
		return mediaFiles;
	}

	private void addFileFromBitmap( Bitmap bmp, List<File> mediaFiles ) {
		if( bmp == null ) return;

		File tempFile = null;
		FileOutputStream fos = null;
		try {
			String fileName = UUID.randomUUID().toString() + ".tmp";
			tempFile = new File( AIR.getCacheDir(), fileName );
			fos = new FileOutputStream( tempFile );
			bmp.compress( Bitmap.CompressFormat.PNG, 1, fos );
			fos.flush();
		} catch( IOException e ) {
			AIR.log( "Error creating temporary bitmap file: " + e.getMessage() );
			e.printStackTrace();
		} finally {
			closeOutputStream( fos );
		}
		mediaFiles.add( tempFile );
	}

	private Bitmap loadRemoteImage( String imageURL ) {
		URL url;
		Bitmap bmp = null;
		try {
			url = new URL( imageURL );
			bmp = BitmapFactory.decodeStream( url.openConnection().getInputStream() );
		} catch( Exception e ) { }
		return bmp;
	}

	private void closeOutputStream( FileOutputStream fos ) {
		try {
			if( fos != null ) fos.close();
		} catch( IOException e ) { }
	}

}
