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

    public class AIRTwitterDirectMessage {

        private var mID:Number;
        private var mIDString:String;
        private var mText:String;
        private var mCreatedAt:String;
        private var mRecipient:AIRTwitterUser;
        private var mSender:AIRTwitterUser;

        public function AIRTwitterDirectMessage() {
            mID = -1;
        }

        public function toString():String {
            return "[AIRTwitterDirectMessage] ID: " + mIDString + " Text: " + mText;
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

        public function get idString():String {
            return mIDString;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set idString( value:String ):void {
            mIDString = value;
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

        public function get createdAt():String {
            return mCreatedAt;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set createdAt( value:String ):void {
            mCreatedAt = value;
        }

        public function get recipient():AIRTwitterUser {
            return mRecipient;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set recipient( value:AIRTwitterUser ):void {
            mRecipient = value;
        }

        public function get sender():AIRTwitterUser {
            return mSender;
        }

        /**
         * @private
         */
        ns_airtwitter_internal function set sender( value:AIRTwitterUser ):void {
            mSender = value;
        }
    }

}
