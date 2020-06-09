//
//  AssetGroup v 1.0 - assetManager package
//  Russell Lowke, December 13th 2009
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

//  allows for a "group" asset that selects from a randomized pool of assets when 
//  its id is requested.

package com.lowke.assetManager.groupAssetManager
{   
    import com.lowke.assetManager.cache.AssetWrapper;
    import com.lowke.assetManager.cache.Cache;
    
    public class AssetGroup extends AssetWrapper 
    {   
        private var _assetIDs:Array;        // array of asset IDs to be randomized between
        private var _pool:Array;            // pool of _assetIDs taken from when an asset requested
        private var _lastID:String;         // last id returned by asset();
        private var _last:*;                // last asset returned by asset();
        
        public function AssetGroup(cache:Cache, 
                                   id:String) 
        {
            super(cache, id);
        }
        
        public function initializeAssetGroup(assetIDs:Array):void 
        {
            _assetIDs = assetIDs;
            resetPool();
        }
        
        public function resetPool():void 
        {
            _pool = copy(_assetIDs);
        }
        
        private function takeID():String 
        {   
            // randomly remove an item from _pool
            var id:String = _pool.splice(randomInt(0, _pool.length - 1), 1)[0];
            
            // reset _pool if depleted
            if (! _pool.length) 
            {
                resetPool();
            }
            
            return id;
        }
        
        public override function get asset():* 
        {
            _lastID = takeID();
            _last = _cache.retrieve(_lastID);
            return _last;
        }
        
        public function get lastID():String 
        {
            return _lastID;
        }
        
        public function get last():* 
        {
            return _last;
        }
        
        // copies an array of references
        //  just uses map(), but implementation is not obvious
        public static function copy(arr:Array):Array 
        {
            return arr.map(function (element:*):* { 
                return element; 
            });
        }
        
        //
        // generate a random integer from low value to high value
        public static function randomInt(low:int, 
                                         high:int):int 
        {
            var range:int = (high + 1) - low;
            var r:int = Math.floor(Math.random() * range) + low;
            
            return r;
        }
    }
}