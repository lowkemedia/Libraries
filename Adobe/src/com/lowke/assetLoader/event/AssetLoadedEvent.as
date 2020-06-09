//
//  AssetLoadedEvent v 1.1 - assetLoader package
//  Russell Lowke, September 20th 2009
// 
//  Copyright (c) 2009 Lowke Media
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

package com.lowke.assetLoader.event
{   
    import flash.events.Event;
    
    /**
     * @author Russell Lowke
     */
    public class AssetLoadedEvent extends Event 
    {   
        // event name
        public static const ASSET_LOADED:String = "assetLoaderAssetLoaded";
        
        private var _asset:*;           // asset that has been loaded
        private var _url:String;        // url to asset
        
        public function AssetLoadedEvent(type:String, 
                                         asset:*, 
                                         url:String) 
        {
            super(type);
            _asset = asset;
            _url = url;
        }
        
        public override function clone():Event 
        {
            return new AssetLoadedEvent(type, _asset, _url);
        }
        
        public override function toString():String 
        {
            return formatToString("AssetLoadedEvent", "type", "asset");
        }
        
        // accessors and mutators
        public function get asset():*                       { return _asset; }
        public function get url():String                    { return _url; }
    }
}