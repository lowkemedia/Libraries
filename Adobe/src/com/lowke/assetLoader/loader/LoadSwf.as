//
//  LoadSwf v 1.9.2 - assetLoader package
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
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.logger.Logger;
    
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.SecurityDomain;
    
    /**
     * @author Russell Lowke
     */
    public class LoadSwf extends LowkeLoader implements ILoad 
    {   
        protected static var _alwaysUseCurrentApplicationDomain:Boolean = false;
        protected static var _alwaysUseCurrentSecurityDomain:Boolean = false;
        
        private var _applicationDomain:ApplicationDomain;
        private var _securityDomain:SecurityDomain;
        
        
        //
        // constructor
        //
        // to load into the application domain (not advised) set domain to ApplicationDomain.currentDomain
        public function LoadSwf(url:String, 
                                applicationDomain:ApplicationDomain = null,
                                securityDomain:SecurityDomain = null) 
        {
            _applicationDomain = applicationDomain;
            _securityDomain = securityDomain;
            
            if (_alwaysUseCurrentApplicationDomain) 
            {
                _applicationDomain = ApplicationDomain.currentDomain;
            }
            
            if (_alwaysUseCurrentSecurityDomain) 
            {
                _securityDomain = SecurityDomain.currentDomain;
            }
            
            var request:URLRequest = new URLRequest(url);
            super(request);
        }
        
        // createLoader is overwritten by other AssetLoader types
        override public function createLoader():void 
        {   
            _loader = new Loader();
            (_loader as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoaded);
            (_loader as Loader).contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            (_loader as Loader).contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            (_loader as Loader).contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            (_loader as Loader).contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            var loaderContext:LoaderContext = new LoaderContext(false, _applicationDomain, _securityDomain);
            
            try 
            {
                // allowCodeImport is a new parameter added as of Flex SDK 4.5.
                //  As not everybody is using Flex SDK 4.5 yet I've wrapped it
                //  in a try catch block
                loaderContext["allowCodeImport"] = true;
            } 
            catch (error:Error) {}
            
            (_loader as Loader).load(_request, loaderContext);
        }
        
        override public function fileLoaded(event:Event = null):void
        {
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, (_loader as Loader).content, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
        
        //
        // prepare this object to be removed from memory
        override public function cleanup():void 
        {
            (_loader as Loader).contentLoaderInfo.removeEventListener(Event.COMPLETE, fileLoaded);
            (_loader as Loader).contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            (_loader as Loader).contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            (_loader as Loader).contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            (_loader as Loader).contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        }
        
        override public function get percentDone():Number 
        {
            return (_loader as Loader).contentLoaderInfo.bytesLoaded/(_loader as Loader).contentLoaderInfo.bytesTotal;
        }
        
        public static function get alwaysUseCurrentApplicationDomain():Boolean
        {
            return _alwaysUseCurrentApplicationDomain;
        }
        
        public static function get alwaysUseCurrentSecurityDomain():Boolean
        {
            return _alwaysUseCurrentSecurityDomain;
        }
        
        public static function set alwaysUseCurrentApplicationDomain(value:Boolean):void
        {
            _alwaysUseCurrentApplicationDomain = value;
        }
        
        public static function set alwaysUseCurrentSecurityDomain(value:Boolean):void
        {
            _alwaysUseCurrentSecurityDomain = value;
        }
    }
}
