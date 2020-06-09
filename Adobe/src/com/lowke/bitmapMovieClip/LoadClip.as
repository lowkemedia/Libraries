//
//  LoadClip v 1.0.1 - bitmapMovieClip package
//  Russell Lowke, June 1st 2011
//
//  Copyright (c) 2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-animator/ for code repository
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

package com.lowke.bitmapMovieClip
{
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    
    import flash.display.Bitmap;
    import flash.events.EventDispatcher;
    
    //
    // loads and constructs a BitmapMovieClip from a series of image files
    public class LoadClip extends EventDispatcher
    {
        private static var _overrideZeros:Number = NaN;
        
        private var _assetLoader:AssetLoader = AssetLoader.instance;
        
        private var _images:Vector.<Bitmap>;
        private var _path:String;
        
        public function LoadClip(path:String,
                                 baseName:String,
                                 nFiles:uint,
                                 suffix:String,
                                 type:String,
                                 funct:Function = null)
        { 
            var listener:Function = function (event:AssetLoadedEvent):void 
            {
                removeEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
                deliverAsset(event, funct);
            };
            addEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
            
            _images = new Vector.<Bitmap>(nFiles);
            _path = path;
            
            for (var i:uint = 0; i < nFiles; ++i) 
            {
                var iStr:String = addZeros(i, (isNaN(_overrideZeros)) ? nFiles : _overrideZeros);
                var fileName:String = baseName + iStr + suffix + type;
                var url:String = _path + "/" + fileName;
                _assetLoader.loadFile(url, function(asset:*):void
                {
                    assign(asset, i);
                });
            }
            _assetLoader.whenDone(ready);
        }
        
        // generic assign()
        private function assign(asset:Bitmap, index:uint):void 
        {
            if (! asset) 
            {
                // asset failed to load!
                asset = new Bitmap();
            }
            
            _images[index] = asset;
        }
        
        private function ready():void 
        {
            var bitmapMC:BitmapMovieClip = new BitmapMovieClip(_images);
            this.dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, bitmapMC, _path));
        }
        
        //
        // private methods used to deliver an asset to the function callback
        private function deliverAsset(evt:AssetLoadedEvent,
                                      funct:Function):void
        {
            // trigger function, adding asset to beginning of argument list
            funct(evt.asset);
        }
        
        // converts a number to a string and adds zeros infront
        //  according to max value.
        private function addZeros(val:Number, maxVal:Number):String 
        {
            var maxAsStr:String = ("" + maxVal);
            var valAsStr:String = ("" + val);
            
            // add '0''s if any
            for (var i:uint = valAsStr.length; i < maxAsStr.length; ++i) 
            {
                valAsStr = "0" + valAsStr;
            }
            
            return valAsStr;
        }
        
        public static function get overrideZeros():Number               { return _overrideZeros; }
        public static function set overrideZeros(val:Number):void       { _overrideZeros = val; }
        
    }
}