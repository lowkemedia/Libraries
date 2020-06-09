//
//  LoadZip v 1.0.1 - assetLoader package
//  Russell Lowke, December 18th 2011
// 
//  Copyright (c) 2011 Lowke Media
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


//  Note: ".zip" files to be read might first need be prepared using assetLoader/deng/tools/python/fzip-prepare.py
//  .zip files will return a library Object with the contents of the zip keyed to file names in the zip.
//  Zipped files may contain ".bmp", ".png", ".jpg", ".jpeg", ".gif", ".swf" and ".xml" content.
            
package com.lowke.loadZip
{   
    import com.lowke.Delayer;
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.assetLoader.loader.ILoad;
    import com.lowke.assetLoader.loader.LowkeLoader;
    import com.lowke.loadZip.deng.fzip.FZip;
    import com.lowke.loadZip.deng.fzip.FZipErrorEvent;
    import com.lowke.loadZip.deng.fzip.FZipFile;
    import com.lowke.logger.Logger;
    
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    public class LoadZip extends LowkeLoader implements ILoad 
    {   
        private var _zipFileLoaded:Boolean;         // flag indicating if the zip file has loaded
        protected var _library:Object;                // library of assets contained in zip, referenced by file name
        private var _loaderTranslators:uint;        // number of active Loaders used to translate data
        
        private var _fileCount:uint;                // total files to process
        private var _fileIndex:uint;                // file currently being processed
        private var _loaders:Dictionary;            // loader->fileName map of active loaders
        private static const BATCH_SIZE:int = 100;
        
        //
        // constructor
        public function LoadZip(url:String) 
        {
            var request:URLRequest = new URLRequest(url);
            super(request);
            
            _zipFileLoaded = false;
            _loaderTranslators = 0;
            _library = new Object();
        }
        
        // createLoader is overwritten by other AssetLoader types
        override public function createLoader():void 
        {
            _loader = new FZip();
            _loader.addEventListener(Event.COMPLETE, zipFileLoaded);
            // _loader.addEventListener(FZipEvent.FILE_LOADED, zipFileLoaded);
            _loader.addEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.addEventListener(FZipErrorEvent.PARSE_ERROR, parseErrorHandler);
            _loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            (_loader as FZip).load(_request);
        }
        
        private function zipFileLoaded(event:Event):void
        {
            // flag the file as loaded 
            _zipFileLoaded = true;
            
            // and clear the _timeOutDelay so we don't get retries while unpacking
            _timeOutDelay.close();
            
            _fileCount = (_loader as FZip).getFileCount();            
            _fileIndex = 0;
            loadZipBatch();
        }
        
        private function loadZipBatch():void
        {
            _loaderTranslators = 0;
            _loaders = new Dictionary();
            
            while (_fileIndex < _fileCount && _loaderTranslators < BATCH_SIZE)
            {
                var zipFile:FZipFile = (_loader as FZip).getFileAt(_fileIndex);
                ++_fileIndex;
                var fileName:String = zipFile.filename;
                fileName = AssetLoader.stripCGI(fileName);      // not that there should be any CGI, but just in case.
                var suffix:String = fileName.slice(fileName.lastIndexOf("."));
                suffix = suffix.toLowerCase();                  // ensure lowercase
                
                var content:ByteArray = zipFile.content;
                content.position = 0;
                
                switch (suffix) {
                    case ".bmp":
                    case ".png":
                    case ".jpg": case ".jpeg":
                    case ".gif":
                    case ".swf":
                        
                        // use Adobe Loader to translate the ByteArray to either a BMP or DisplayObject/MovieClip
                        var loader:Loader = new Loader();
                        _loaders[loader] = fileName;            
                        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
                        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadComplete);
                        ++_loaderTranslators;
                        loader.loadBytes(content);
                        break;
                    
                    case ".xml":
                    case ".plist":
                        // convert to XML
                        var xml:XML = new XML(content.toString());
                        
                        // assign xml asset to the library using fileName as key
                        _library[fileName] = xml;
                        break;
                    
                    case "/":
                    case "\\":
                        // skip, file was just a folder
                        break;
                    
                    default:
                        // don't understand file
                        Logger.warning("Could not translate " + fileName + " in zip " + this.url, AssetLoader.WARNING_PARSE_ERROR);
                        break;
                }
            }
            
            checkBatchFinished();
        }
        
        private function onLoadComplete(event:Event):void {
            var loader:Loader = (event.target as LoaderInfo).loader;
            var fileName:String = _loaders[loader];
            var asset:DisplayObject;
            if (loader && loader.content) {
                asset = loader.content as DisplayObject;
            }
            if (asset) {
                // assign the asset to the library using fileName as key
                _library[fileName] = asset;
                
            } else {
                Logger.warning("Could not translate " + fileName + " in zip " + this.url + " as DisplayObject", AssetLoader.WARNING_PARSE_ERROR);
            }
            
            loader.unload();
            --_loaderTranslators;
            checkBatchFinished();
        }
        
        private function checkBatchFinished():void {
            
            if (_loaderTranslators == 0) {  
                if (_fileIndex >= _fileCount) {
                    fileLoaded();
                } else {
					Delayer.nextFrame(loadZipBatch);
                }
            }
        }
        
        override public function fileLoaded(event:Event = null):void 
        {
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, _library, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
        
        private function parseErrorHandler(event:SecurityErrorEvent):void 
        {
            loadFailed("AssetLoader Zip Parse Error:" + event.text, AssetLoader.WARNING_PARSE_ERROR);
        }
        
        //
        // prepare this object to be removed from memory
        override public function cleanup():void 
        {
            _loaders = null;
            _loader.removeEventListener(Event.COMPLETE, zipFileLoaded);
            // _loader.removeEventListener(FZipEvent.FILE_LOADED, zipFileLoaded);
            _loader.removeEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.removeEventListener(FZipErrorEvent.PARSE_ERROR, parseErrorHandler);
            _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        }
        
        override public function get percentDone():Number 
        {
            var percentDone:Number = 0;
            
            // assuming that loading the zip is 1/2 the work;
            if (_zipFileLoaded) {
                percentDone += 0.5;
            }
            
            // and translating contents the other 1/2.
            if (_fileIndex > 0) {
                percentDone += 0.5*(_fileIndex/_fileCount);
            } else {
                percentDone += 0.5;
            }
            
            return percentDone;
        }
    }
}
