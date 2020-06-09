//
//  LoadBitmapMovieClip v 1.0 - bitmapMovieClip package
//  Russell Lowke, April 7th 2011
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
    import com.lowke.assetLoader.loader.ILoad;
    import com.lowke.loadZip.LoadZip;
    import com.lowke.logger.Logger;
    
    import flash.display.Bitmap;
    import flash.events.Event;
    
    public class LoadBitmapMovieClip extends LoadZip implements ILoad 
    {   
        private var _maxFiles:uint;
        
        //
        // constructor
        //
        //  maxFiles is used to deduce how many "0"'s to put in front of the number in the file name
        public function LoadBitmapMovieClip(url:String, maxFiles:uint = 0) 
        {
            _maxFiles = maxFiles;
            super(url);
        }
        
        override public function fileLoaded(evt:Event = null):void 
        {
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            var clip:BitmapMovieClip = makeClip(_library, _maxFiles);
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, clip, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
        
        // make a BitmapMovieClip from a library returned from a zip
        public static function makeClip(lib:Object, maxFiles:uint = 0):BitmapMovieClip 
        {
            // count the number of files
            var nFiles:uint = 0;
            var key:String;
            for (key in lib) 
            {
                ++nFiles;
            }
            
            if (! maxFiles) 
            {
                maxFiles = nFiles;
            }
            
            // deduce filename
            var index:uint = key.lastIndexOf(".");
            var suffix:String = key.slice(index);
            var maxAsStr:String = ("" + maxFiles);
            var baseName:String = key.substring(0, index - maxAsStr.length);
            
            // build BitmapMovieClip
            var images:Vector.<Bitmap> = new Vector.<Bitmap>;
            for (var i:uint = 0; i < nFiles; ++i) 
            {
                key = baseName + addZeros(i, maxFiles) + suffix;
                if (lib[key] is Bitmap) 
                {
                    images.push(lib[key] as Bitmap);
                }
            }
            
            return new BitmapMovieClip(images);
        }
        
        // converts a number to a string and adds zeros infront
        //  according to max value.
        private static function addZeros(val:Number, 
                                         maxVal:Number):String 
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
    }
}