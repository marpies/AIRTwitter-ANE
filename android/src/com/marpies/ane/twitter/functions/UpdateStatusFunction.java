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

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.twitter.data.AIRTwitterEvent;
import com.marpies.ane.twitter.data.MediaSource;
import com.marpies.ane.twitter.data.TwitterAPI;
import com.marpies.ane.twitter.utils.*;
import twitter4j.*;

import java.io.File;
import java.util.List;

public class UpdateStatusFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		String text = (args[0] == null) ? null : FREObjectUtils.getString( args[0] );
		mCallbackID = FREObjectUtils.getInt( args[1] );
		long inReplyToStatusID = FREObjectUtils.getDouble( args[2] ).longValue();
		final List<MediaSource> mediaSources = (args[3] == null) ? null : FREObjectUtils.getListOfMediaSource( (FREArray) args[3] );

		final AsyncTwitter twitter = TwitterAPI.getAsyncInstance( TwitterAPI.getAccessToken() );
		twitter.addListener( this );

		final StatusUpdate status = new StatusUpdate( text );
		if( inReplyToStatusID >= 0 ) {
			status.setInReplyToStatusId( inReplyToStatusID );
		}
		/* If we have some media, system files must be created and uploaded to Twitter */
		if( mediaSources != null ) {
			/* Save cache dir path before running the async task */
			AIR.setCacheDir( AIR.getContext().getActivity().getCacheDir().getAbsolutePath() );
			/* Execute async task that creates files out of the given sources (URLs and Bitmaps) */
			createFilesFromSources( mediaSources, twitter, status );
			return null;
		}

		/* Posts status without media */
		twitter.updateStatus( status );

		return null;
	}

	private void createFilesFromSources( final List<MediaSource> mediaSources, final AsyncTwitter twitter, final StatusUpdate status ) {
		new MediaSourceProcessor() {
			@Override
			protected void onPostExecute( List<File> files ) {
				super.onPostExecute( files );
				/* If the number of created files does not equal to the number
				 * of sources we provided then we consider that a fail */
				if( files.size() != mediaSources.size() ) {
					/* Failed to create media files, let's not update status without the media */
					AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_ERROR,
							StringUtils.getEventErrorJSON( mCallbackID, "Failed to create media files." )
					);
					return;
				}
				/* Otherwise proceed with uploading the files to Twitter */
				else {
					uploadMedia( twitter, status, files, mCallbackID );
				}
			}
		}.execute( mediaSources );
	}

	private void uploadMedia( final AsyncTwitter twitter, final StatusUpdate status, final List<File> mediaList, final Integer callbackID ) {
		/* Run the upload in separate thread */
		new Thread( new Runnable() {
			@Override
			public void run() {
				final long[] mediaIDs = new long[ mediaList.size() ];
				try {
					/* Synchronous twitter4j must be used in order to upload the media */
					Twitter syncTwitter = TwitterAPI.getInstance( TwitterAPI.getAccessToken() );
					for( int i = 0; i < mediaIDs.length; i++ ) {
						File mediaFile = mediaList.get( i );
						AIR.log( "Uploading media " + mediaFile.getAbsolutePath() );
						UploadedMedia uploadedMedia = syncTwitter.uploadMedia( mediaFile );
						mediaIDs[i] = uploadedMedia.getMediaId();
					}
					// todo: remove cached media files
					status.setMediaIds( mediaIDs );
					/* Update status only if there is no exception during media upload */
					twitter.updateStatus( status );
				} catch( TwitterException e ) {
					AIR.log( "Error uploading media " + e.getMessage() );
					/* Failed to upload media, let's not update status without the media */
					AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_ERROR,
							StringUtils.getEventErrorJSON( callbackID, StringUtils.removeLineBreaks( e.getMessage() ) )
					);
				}
			}
		} ).start();
	}

	@Override
	public void updatedStatus( Status status ) {
		AIR.log( "Updated status w/ message " + status.getText() );
		try {
			JSONObject statusJSON = StatusUtils.getJSON( status );
			statusJSON.put( "callbackID", mCallbackID );
			statusJSON.put( "success", true );
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_SUCCESS, statusJSON.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_SUCCESS,
					StringUtils.getEventErrorJSON( mCallbackID, "Status update succeeded but could not parse returned status." )
			);
		}
	}

	@Override
	public void onException( TwitterException te, TwitterMethod method ) {
		if( method == TwitterMethod.UPDATE_STATUS ) {
			AIR.log( "Error updating status " + te.getMessage() );
			AIR.dispatchEvent( AIRTwitterEvent.STATUS_QUERY_ERROR,
					StringUtils.getEventErrorJSON( mCallbackID, te.getMessage() )
			);
		}
	}

}
