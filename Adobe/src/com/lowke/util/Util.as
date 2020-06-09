//
//  Please Note: This is a collection of small static helper functions and is not intended to be imported and used directly.
//  Subtle changes to a static helper function may unexpectedly cause older legacy code to break.
//  As such, it's recommended that you copy needed functions into your code and use them there rather than import them from here.
//


package com.lowke.util
{
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.media.Sound;
    import flash.media.SoundTransform;
    import flash.system.System;

    public class Util
    {
        /**
         * Generates a random integer between low and high.
         * 
         * @param low Lowest possible integer generated.
         * @param high Highest possible integer generated.
         * @return Returns a random integer between low and high.
         */
        public static function randomInt(low:int, high:int):int 
        {
            var range:int = (high + 1) - low;
            var r:int = Math.floor(Math.random() * range) + low;
            
            return r;
        }
        
        /**
         * A way to force garbage collection in the flash debugger player is to call System.gc() twice.
         * The first call marks items for collection, the second sweeps marked items.
         */
        public static function garbageCollect():void 
        {
            System.gc();
            System.gc();
        }

		
		/**
		 * Bring a sprite to the top of its display list.
		 * 
		 * @param sprite Sprite to be put on the top of its display list.
		 */
		public static function bringToTop(sprite:Sprite):void 
		{
			sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
		}
        
		
		/**
		 * Return true if mouse over sprite.
		 * 
		 * @param sprite Sprite mouse over is being checked for.
		 * @param shapeFlag If true sprite region is checked for (slower) rather than just the bounding rectangle.
		 * 
		 * @return Returns true if the mouse over the sprite.
		 */
		public static function mouseOverSprite(sprite:Sprite, 
											   shapeFlag:Boolean = true):Boolean 
		{
			return (sprite && sprite.stage && sprite.hitTestPoint(sprite.stage.mouseX, sprite.stage.mouseY, shapeFlag));
		}

        
        /**
         * Check if this is a local flash run.
         *  another one worth checking is Capabilities.playerType == "StandAlone";
         *
         * @return Returns a boolean whether the application is running locally or online.
         */
        public static function isLocal(stage:Stage):Boolean
        {
            return stage.loaderInfo.url.indexOf("file:") != -1 ? true : false;
        }
        

        
        /**
         * Converts https status id collected from HTTPStatusEvent to a descriptive string.
         * httpStatus can give us additional information on what happened during a load.
         * see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
         * 
         * param@ status    The status identifier from a HTTPStatusEvent
         * 
         * return@ Returns the http status as a descriptive string.
         */
        public static function descriptiveHttpStatus(status:int):String
        {
            switch (status) {
                case 100:           return "(100) Continue";
                case 101:           return "(101) Switching Protocols";
                case 200:           return "(200) OK";
                case 201:           return "(201) Created";
                case 202:           return "(202) Accepted";
                case 203:           return "(203) Non-Authoritative Information";
                case 204:           return "(204) No Content";
                case 205:           return "(205) Reset Content";
                case 206:           return "(206) Partial Content";
                case 300:           return "(300) Multiple Choices";
                case 301:           return "(301) Moved Permanently";
                case 302:           return "(302) Found";
                case 303:           return "(303) See Other";
                case 304:           return "(304) Not Modified";
                case 305:           return "(305) Use Proxy";
                case 306:           return "(306) (Unused)";
                case 307:           return "(307) Temporary Redirect";
                case 400:           return "(400) Bad Request";
                case 401:           return "(401) Unauthorized";
                case 402:           return "(402) Payment Required";
                case 403:           return "(403) Forbidden";
                case 404:           return "(404) Not Found";
                case 405:           return "(405) Method Not Allowed";
                case 406:           return "(406) Not Acceptable";
                case 407:           return "(407) Proxy Authentication Required";
                case 408:           return "(408) Request Timeout";
                case 409:           return "(409) Conflict";
                case 410:           return "(410) Gone";
                case 411:           return "(411) Length Required";
                case 412:           return "(412) Precondition Failed";
                case 413:           return "(413) Request Entity Too Large";
                case 414:           return "(414) Request-URI Too Long";
                case 415:           return "(415) Unsupported Media Type";
                case 416:           return "(416) Requested Range Not Satisfiable";
                case 417:           return "(417) Expectation Failed";
                case 500:           return "(500) Internal Server Error";
                case 501:           return "(501) Not Implemented";
                case 502:           return "(502) Bad Gateway";
                case 503:           return "(503) Service Unavailable";
                case 504:           return "(504) Gateway Timeout";
                default:            return "Could not recognize http status of " + status;
            }
        }
        
        
        /**
         * Prepare a sound by playing it a zero volume.
         * This ensures the sound is played quickly when played, without
         * the annoying pause before a sound is played for the very first
         * time, typical of the Adobe Sound class.
         *
         * @param sound Sound being prepared.
         */
        public static function prepareSound(sound:Sound):void
        {
            sound.play(0, 0, new SoundTransform(0));
        }

    }
}