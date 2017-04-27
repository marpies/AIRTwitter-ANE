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

package com.marpies.ane.twitter.data {

    public class AIRTwitterUser {

        private var mID:String;
        private var mName:String;
        private var mScreenName:String;
        private var mCreatedAt:String;
        private var mDescription:String;
        private var mTweetsCount:int;
        private var mLikesCount:int;
        private var mFollowersCount:int;
        private var mFriendsCount:int;
        private var mProfileImageURL:String;
        private var mIsProtected:Boolean;
        private var mIsVerified:Boolean;
        private var mLocation:String;

        public function AIRTwitterUser() {
            mID = null;
        }

        public function toString():String {
            return "[AIRTwitterUser] ID: " + mID + " Name:" + mName + " (@" + mScreenName + ")" + " Followers: " + mFollowersCount + " Friends: " + mFriendsCount;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        public function get id():String {
            return mID;
        }

        ns_airtwitter_internal function set id( value:String ):void {
            mID = value;
        }

        public function get name():String {
            return mName;
        }

        ns_airtwitter_internal function set name( value:String ):void {
            mName = value;
        }

        public function get screenName():String {
            return mScreenName;
        }

        ns_airtwitter_internal function set screenName( value:String ):void {
            mScreenName = value;
        }

        public function get createdAt():String {
            return mCreatedAt;
        }

        ns_airtwitter_internal function set createdAt( value:String ):void {
            mCreatedAt = value;
        }

        public function get description():String {
            return mDescription;
        }

        ns_airtwitter_internal function set description( value:String ):void {
            mDescription = value;
        }

        public function get tweetsCount():int {
            return mTweetsCount;
        }

        ns_airtwitter_internal function set tweetsCount( value:int ):void {
            mTweetsCount = value;
        }

        public function get likesCount():int {
            return mLikesCount;
        }

        ns_airtwitter_internal function set likesCount( value:int ):void {
            mLikesCount = value;
        }

        public function get followersCount():int {
            return mFollowersCount;
        }

        ns_airtwitter_internal function set followersCount( value:int ):void {
            mFollowersCount = value;
        }

        public function get friendsCount():int {
            return mFriendsCount;
        }

        ns_airtwitter_internal function set friendsCount( value:int ):void {
            mFriendsCount = value;
        }

        /**
         * Profile image URL with dimensions 48x48px.
         */
        public function get profileImageURL():String {
            return mProfileImageURL;
        }

        ns_airtwitter_internal function set profileImageURL( value:String ):void {
            mProfileImageURL = value;
        }

        /**
         * Profile image URL in original size. Beware this image can be very large.
         */
        public function get profileImageURLOriginal():String {
            if( mProfileImageURL ) {
                return mProfileImageURL.replace( "_normal", "" );
            }
            return null;
        }

        public function get isProtected():Boolean {
            return mIsProtected;
        }

        ns_airtwitter_internal function set isProtected( value:Boolean ):void {
            mIsProtected = value;
        }

        public function get isVerified():Boolean {
            return mIsVerified;
        }

        ns_airtwitter_internal function set isVerified( value:Boolean ):void {
            mIsVerified = value;
        }

        public function get location():String {
            return mLocation;
        }

        ns_airtwitter_internal function set location( value:String ):void {
            mLocation = value;
        }
    }

}
