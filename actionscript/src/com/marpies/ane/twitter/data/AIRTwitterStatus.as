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

package com.marpies.ane.twitter.data {

    public class AIRTwitterStatus {

        private var mID:Number;
        private var mText:String;
        private var mReplyToUserID:Number;
        private var mReplyToStatusID:Number;
        private var mFavoriteCount:uint;
        private var mRetweetCount:uint;
        private var mCreatedAt:String;
        private var mIsRetweet:Boolean;
        private var mIsSensitive:Boolean;

        public function AIRTwitterStatus() {
            mID = -1;
            mReplyToUserID = -1;
            mReplyToStatusID = -1;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        public function get id():Number {
            return mID;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set id( value:Number ):void {
            mID = value;
        }

        public function get text():String {
            return mText;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set text( value:String ):void {
            mText = value;
        }

        public function get replyToUserID():Number {
            return mReplyToUserID;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set replyToUserID( value:Number ):void {
            mReplyToUserID = value;
        }

        public function get replyToStatusID():Number {
            return mReplyToStatusID;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set replyToStatusID( value:Number ):void {
            mReplyToStatusID = value;
        }

        public function get favoriteCount():uint {
            return mFavoriteCount;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set favoriteCount( value:uint ):void {
            mFavoriteCount = value;
        }

        public function get retweetCount():uint {
            return mRetweetCount;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set retweetCount( value:uint ):void {
            mRetweetCount = value;
        }

        public function get createdAt():String {
            return mCreatedAt;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set createdAt( value:String ):void {
            mCreatedAt = value;
        }

        public function get isRetweet():Boolean {
            return mIsRetweet;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set isRetweet( value:Boolean ):void {
            mIsRetweet = value;
        }

        public function get isSensitive():Boolean {
            return mIsSensitive;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set isSensitive( value:Boolean ):void {
            mIsSensitive = value;
        }
    }

}
