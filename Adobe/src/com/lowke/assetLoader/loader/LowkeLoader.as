//
//  LowkeLoader v 1.3.2 - assetLoader package
//  Russell Lowke, December 18th 2011
//
//  Copyright (c) 2008-2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-assetloader/ for code repository
// 
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER  
//  DEALINGS IN THE SOFTWARE. 
//
//

package com.lowke.assetLoader.loader
{   
    import com.lowke.Delayer;
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.assetLoader.event.LoaderDisposedEvent;
    import com.lowke.logger.Logger;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;

    /**
     * @author Russell Lowke
     */
    public class LowkeLoader extends EventDispatcher implements ILoad 
    {
        private static var idCount:uint = 0;        // used to create unique ids for AssetLoaders
        
        //
        // member variables
        protected var _assetLoader:AssetLoader;     // refrenece to asset loader
        protected var _request:URLRequest;          // URLRequest to the asset being loaded
        protected var _loader:EventDispatcher;      // Flash loader either, Loader(), URLLoader(), or Sound()
        protected var _id:uint;                     // each loader is given a unique numeric id.
        protected var _timeOutDelay:Delayer;          // timer used to ensure loader has not timed out
        protected var _httpStatus:int;              // http status
        protected var _showProgress:Boolean;        // if false progress events will be suppressed
        private var _timeoutRetry:uint;             // after 10 seconds loader will timeout and try again.
        private var _nAttempts:uint;                // number of attempts made to load the item
        
        //
        // constructor
        public function LowkeLoader(request:URLRequest) 
        {
            _assetLoader = AssetLoader.instance;
            _timeoutRetry = AssetLoader.timeoutRetry;
            _request = request;
            _nAttempts = 1;
            _id = idCount++;
            _showProgress = true;
            _timeOutDelay = Delayer.delay(_timeoutRetry, timeoutError);
            Logger.debug("File requested (" + _id + ") url:\"" + _request.url + "\"", AssetLoader.DEBUG_FILE_REQUESTED);
        }
        
        //
        // close the loader before it gets a chance to finish loading
        public function close():void 
        {
            Logger.info("AssetLoader closing loading file (" + _id + "):" + this.url, AssetLoader.INFO_FILE_CLOSED);
            
            // Note: removeAssetLoader() will call dispose() on this instance
            _assetLoader.removeAssetLoader(this);
        }
        
        public function dispose(retry:Boolean = false):void 
        {
            // dispose of this loader, called by removeAssetLoader() in AssetLoader
            if (_timeOutDelay) 
            {
                _timeOutDelay.close();
            }
            
            cleanup();
            
            if (! retry) 
            {
                dispatchEvent(new LoaderDisposedEvent(LoaderDisposedEvent.LOADER_DISPOSED));
            }
        }
        
        private function reload():void 
        {
            ++_nAttempts;
            dispose(true);
            _timeoutRetry *= 2; // give it twice as much time on the next attempt
            _timeOutDelay = Delayer.delay(_timeoutRetry, timeoutError);
            createLoader();
        }
        
        //
        // all failed loads are classed as WARNINGS
        protected function loadFailed(errStr:String, errID:String):void 
        {
            // add http status
            if (_httpStatus) 
            {
                errStr += ".\nHTTP STATUS: " + descriptiveHttpStatus(_httpStatus);
            }
            
            // give warning that load failed
            Logger.warning(errStr, errID);
            
            // dispatch asset as null
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, null, _request.url));
            
            // remove loader
            _assetLoader.removeAssetLoader(this);
        }
        
        // httpStatus can give us additional information on what happened
        //  see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
        protected function httpStatusHandler(event:HTTPStatusEvent):void 
        {
            _httpStatus = event.status;
        }
        
        protected function ioErrorHandler(event:IOErrorEvent):void 
        {    
            var errStr:String = event.text;
            
            // can't access event.errorID when in old 3.x SDKs
            //  using split() on error text instead.
            var errID:String = errStr.split(':', 2)[0];
            
            switch (errID) 
            {
                case "Error #2036":                 // Error #2036: Load Never Completed.
                case "Error #2032":                 // Error #2032: Stream Error. Flash web services gives Stream Error instead of URL Not Found.
                case "Error #2035":                 // Error #2035: URL Not Found.  
                    loadFailed("AssetLoader IOError (attempt " + _nAttempts + "), usually caused by file not found.\n" +
                        "ERROR: " + errStr, AssetLoader.WARNING_FILE_NOT_FOUND);
                    return;
                    
                default:
                    // otherwise show issue, but continue operation
                    Logger.warning("AssetLoader IOError (attempt " + _nAttempts + ")\n" +
                        "ERROR: " + errStr, AssetLoader.WARNING_LOADER_ISSUE);
                    break;
            }
            
            if (_nAttempts == AssetLoader.retryAttemps) 
            {
                loadFailed("AssetLoader IOError (attempt " + _nAttempts + ")\n" +
                    "ERROR:" + errStr, AssetLoader.WARNING_FILE_CANT_LOAD);
                return;
            }
            
            // try to reload item
            reload();
        }
        
        protected function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            // security issue
            loadFailed("AssetLoader Security Error:" + event.text, AssetLoader.WARNING_SECURITY_BREACH);
        }
        
        
        private function timeoutError(prevPercentDone:Number = 0):void 
        {   
            // loader taking too long to load, might not be responding.
            
            var percentDone:Number = this.percentDone;
            if (percentDone > prevPercentDone) 
            {
                // file is still loading, check again later
                _timeOutDelay = Delayer.delay(_timeoutRetry, function():void
                    {
                        timeoutError(percentDone);
                    });
            } 
            else 
            {
                if (_nAttempts < AssetLoader.retryAttemps) 
                {
                    // loader not responding, retry
                    Logger.print("AssetLoader Timeout Error (attempt " + _nAttempts + "). No response after " + _timeoutRetry +
                        " milliseconds when loading " + _request.url, AssetLoader.WARNING_LOAD_TIMEOUT);
                    
                    // try to reload item
                    reload();
                } 
                else 
                {
                    // after so many attempts then fail
                    loadFailed("AssetLoader Timeout Error (attempt " + _nAttempts + "). No response after " + _timeoutRetry + 
                        " milliseconds when loading " + _request.url + ".\n\nThis load declared a failure.", AssetLoader.WARNING_LOAD_TIMEOUT);
                }
            }
        }
        
        // createLoader is overwritten by other AssetLoader types
        public function createLoader():void 
        {
            throw new Error("createLoader() must be overridden");
        }
        
        // createLoader is overwritten by other AssetLoader types
        public function fileLoaded(event:Event = null):void 
        {
            throw new Error("fileLoaded() must be overridden");
        }
        
        // prepare this object to be removed from memory
        public function cleanup():void 
        {
            throw new Error("cleanup() must be overridden");
        }
        
        //
        // return the percent done
        //  if nothing loaded percentDone may return NaN instead of 0, depending on specifics of the loader.
        public function get percentDone():Number 
        {
            throw new Error("percentDone() must be overridden");
        }
        
        
        //
        // accessors and mutators
        //
        
        public function get id():uint                           { return _id; }
        public function get url():String                        { return _request.url; }
        public function get timeoutRetry():uint                 { return _timeoutRetry; }
        public function get showProgress():Boolean              { return _showProgress; }
        public function set timeoutRetry(value:uint):void       { _timeoutRetry = value; }
        public function set url(value:String):void              { _request.url = value; }
        public function set showProgress(value:Boolean):void    { _showProgress = value; }
        
        //
        // static helper methods
        //
        
        /**
         * Converts https status id collected from HTTPStatusEvent to a descriptive string.
         * httpStatus can give us additional information on what happened during a load.
         * see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
         * 
         * param@ status    The status identifier from a HTTPStatusEvent
         * 
         * return@ Returns the http status as a descriptive string
         */
        public static function descriptiveHttpStatus(status:int):String
        {
            switch (status) 
            {
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
    }
}   