//
//  LoadSound v 1.2.1 - assetLoader package
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
    
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.Sound;
    import flash.net.URLRequest;
    
    /**
     * @author Russell Lowke
     */
    public class LoadSound extends LowkeLoader implements ILoad 
    {   
        //
        // constructor
        public function LoadSound(url:String) 
        {
            var request:URLRequest = new URLRequest(url);
            super(request);
        }
        
        override public function createLoader():void 
        {
            _loader = new Sound();
            _loader.addEventListener(Event.COMPLETE, fileLoaded);
            _loader.addEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            (_loader as Sound).load(_request);
        }
        
        override public function fileLoaded(event:Event = null):void 
        {
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, _loader as Sound, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
        
        
        //
        //  remove event listeners
        override public function cleanup():void 
        {
            _loader.removeEventListener(Event.COMPLETE, fileLoaded);
            _loader.removeEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        }
        
        override public function get percentDone():Number 
        {
            return (_loader as Sound).bytesLoaded/(_loader as Sound).bytesTotal;
        }
    }
}