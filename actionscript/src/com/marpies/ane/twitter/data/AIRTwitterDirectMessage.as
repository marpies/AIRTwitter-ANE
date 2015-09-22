package com.marpies.ane.twitter.data {

    public class AIRTwitterDirectMessage {

        private var mID:Number;
        private var mText:String;
        private var mCreatedAt:String;
        private var mRecipient:AIRTwitterUser;
        private var mSender:AIRTwitterUser;

        public function AIRTwitterDirectMessage() {
            mID = -1;
        }

        public function toString():String {
            return "[AIRTwitterDirectMessage] ID: " + mID + " Text: " + mText;
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

        ns_airtwitter_internal function set id( value:Number ):void {
            mID = value;
        }

        public function get text():String {
            return mText;
        }

        ns_airtwitter_internal function set text( value:String ):void {
            mText = value;
        }

        public function get createdAt():String {
            return mCreatedAt;
        }

        ns_airtwitter_internal function set createdAt( value:String ):void {
            mCreatedAt = value;
        }

        public function get recipient():AIRTwitterUser {
            return mRecipient;
        }

        ns_airtwitter_internal function set recipient( value:AIRTwitterUser ):void {
            mRecipient = value;
        }

        public function get sender():AIRTwitterUser {
            return mSender;
        }

        ns_airtwitter_internal function set sender( value:AIRTwitterUser ):void {
            mSender = value;
        }
    }

}
