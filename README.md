# AIRTwitter | Twitter extension for Adobe AIR (iOS & Android)

The extension is built on top of [Twitter4j](http://twitter4j.org/en/index.html) and [STTwitter](https://github.com/nst/STTwitter).

ANE is currently in development and offers the following features:
* User login via browser and using system account (iOS)
* Updating status with text and images (URLs and BitmapData)
* Retrieving home and user timelines, retweeting, creating favorite tweets
* Retrieving followers, friends, sending (un)follow requests

The following is at the top of todo list:
* Private messaging
* Search
* Login via in-app web view

## Getting started

Choose ideally unique URL scheme for your application (alphanumeric). Replace `{URL_SCHEME}` in the following snippets with your scheme.

For Android support, modify your `android/manifestAdditions` to include the following:

```xml
<![CDATA[
<manifest android:installLocation="auto">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application>

        <activity 
            android:name="com.marpies.ane.twitter.LoginActivity"
            android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
        />

        <activity> 
            <intent-filter> 
                <action android:name="android.intent.action.MAIN"/> 
                <category android:name="android.intent.category.LAUNCHER"/> 
            </intent-filter> 
            <intent-filter> 
                <action android:name="android.intent.action.VIEW"/> 
                <category android:name="android.intent.category.BROWSABLE"/> 
                <category android:name="android.intent.category.DEFAULT"/> 
                <data 
                    android:host="twitter_access_tokens"
                    android:scheme="{URL_SCHEME}"/> 
            </intent-filter> 
        </activity> 

    </application>

</manifest>
]]>
```

For iOS support, modify your `iPhone/InfoAdditions` to include the following:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
            <array>
                <string>{URL_SCHEME}</string>
            </array>
    </dict>
</array>
```

Create a [Twitter app](https://apps.twitter.com) and copy your Consumer key and secret. Make sure to set **Callback URL** in the *Settings* tab to some valid URL, `https://twitter.com` will do.

Add AIRTwitter.ane from the *bin* directory to your project's build path. Initialize the ANE somewhere in your app with the `init` call (replace `{CONSUMER_KEY}`, `{CONSUMER_SECRET}` and `{URL_SCHEME}` with the corresponding values):

```
if( AIRTwitter.init( "{CONSUMER_KEY}", "{CONSUMER_SECRET}", "{URL_SCHEME}", onCredentialsChecked, true ) ) {
    trace( "ANE initialized" );
} else {
    trace( "ANE failed to init" );
}

...

private function onCredentialsChecked( credentialsValid:Boolean, credentialsMissing:Boolean ):void {
    if( credentialsValid ) {
        trace( "User credentials are valid - no need to login again" );
        /* You can use the rest of the AIRTwitter's API */
        return;
    } else if( credentialsMissing ) {
        trace( "User credentials are missing" );
    } else {
        trace( "User credentials are invalid" );
    }
}
```

### Code snippets

#### Login (via browser)
```
AIRTwitter.login( onTwitterLogin );

private function onTwitterLogin( errorMessage:String, wasCancelled:Boolean ):void {
    if( errorMessage ) {
        trace( "Login error: " + errorMessage );
    } else if( wasCancelled ) {
        trace( "Login cancelled" );
    } else {
        trace( "Successfully logged in" );
    }
}
```

#### Retrieving home timeline
```
...

private var mMaxID:Number = -1;
private var mSinceID:Number = -1;

...

/* Loads the 20 newest tweets on our timeline */
AIRTwitter.getHomeTimeline( 20, -1, -1, false, onTimelineRetrieved );

private function onTimelineRetrieved( statuses:Vector.<AIRTwitterStatus>, errorMessage:String ):void {
    if( errorMessage ) {
        trace( "Error retrieving home timeline " + errorMessage );
    } else {
        const length:uint = statuses.length;
        for( var i:uint = 0; i < length; i++ ) {
            const status:AIRTwitterStatus = statuses[i];
            /* Save the newest status ID so that we have starting point to load newer statuses */
            if( mSinceID < 0 && i == 0 ) {
                mSinceID = status.id;
            }
            /* Save the last status ID so that we have a starting point to load older statuses */
            if( i == (length - 1) ) {
                mMaxID = status.id;
            }
            /* Add status to Feathers UI List */
            mStatusList.dataProvider.addItem( status );
        }
    }
}

```

To load next (older) series of tweets call `getHomeTimeline` with the stored `mMaxID`
```
AIRTwitter.getHomeTimeline( 20, -1, mMaxID, false, onTimelineRetrieved ); // The same callback can be used
```

To load newer tweets call `getHomeTimeline` with the stored `mSinceID`
```
AIRTwitter.getHomeTimeline( 20, mSinceID, -1, false, onRefreshedTimelineRetrieved );

private function onRefreshedTimelineRetrieved( statuses:Vector.<AIRTwitterStatus>, errorMessage:String ):void {
    if( errorMessage ) {
        Logger.log( "Error retrieving home timeline " + errorMessage );
    } else {
        const length:uint = statuses.length;
        /* When adding statuses to, for example, Feathers List we add them from older to newer */
        for( var i:int = length - 1; i >= 0; i-- ) {
            const status:AIRTwitterStatus = statuses[i];
            /* When querying timeline with sinceID param then the tweet with ID == sinceID is included
             * in the returned result, but it is already added in our list so we skip it */
            if( status.id == mSinceID ) continue;
            /* Save the newest status ID so that we have a starting point to load newer statuses */
            if( i == 0 ) {
                mSinceID = status.id;
            }
            /* Add to the top of the Feathers UI List */
            mStatusList.dataProvider.addItemAt( status, 0 );
        }
    }
}
```

## Documentation
Generated ActionScript documentation is available in the *docs* directory, or can be generated by running `ant asdoc` from the *build* directory.

## Build ANE
ANT build scripts are available in the *build* directory. Edit *build.properties* to correspond with your local setup.

## Author
The ANE has been written by [Marcel Piestansky](https://twitter.com/marpies) and is distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## Change log

#### September 22, 2015 (v0.5.6-beta)

* ADDED `loginWithAccount` method for logging in using an account set in the iOS settings

#### September 21, 2015 (v0.5.4-beta)

* FIXED login callback not being dispatched after closing the login browser tab and returning to app

#### September 20, 2015 (v0.5.3-beta)

* ADDED `forceLogin` parameter to `login` method
* ADDED `user` and `retweetedStatus` properties to `AIRTwitterStatus`

#### August 31, 2015 (v0.5.0-beta)

* Public release