//
//  Cache v 1.5 - assetManager package
//  Russell Lowke, June 30th 2013
// 
//  Copyright (c) 2009-2013 Lowke Media
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

package com.lowke.assetManager.cache
{
    import com.lowke.logger.Logger;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
    
    /**
     * Cache class used by AssetManager to store cached assets.
     * This class is a stand-alone class that can be used independently of the AssetManager.
     * 
     * @author Russell Lowke
     */
    public class Cache extends EventDispatcher 
    {
        //
        // error, warning and info IDs
        public static const LOG_PREFIX:String                                   = "CCH";
        public static const WARNING_CANT_CACHE_AS_UNIQUE:String                 = "CCH00";
        public static const WARNING_ASSET_NOT_IN_CACHE:String                   = "CCH01";
        public static const WARNING_ASSET_ALREADY_CACHED_AS_UNIQUE:String       = "CCH02";
        public static const WARNING_ASSET_ALREADY_CACHED_AS_NONUNIQUE:String    = "CCH03";
        public static const WARNING_ASSET_ALREADY_CACHED:String                 = "CCH04";
        public static const WARNING_CANT_FORGET_WHATS_NOT_CACHED:String         = "CCH05";
        public static const WARNING_CANT_RETRIEVE_EMPTY_ID:String               = "CCH06";
        public static const WARNING_CANT_RETURN_UNIQUE_INSTANCE:String          = "CCH07";
        public static const DEBUG_CACHING_ASSET:String                          = "CCH08";
        public static const DEBUG_FORGETTING_ASSET:String                       = "CCH09";
        
        private var _name:String;                       // name of Cache
        private var _assets:Array   = new Array();      // list of cached assets
        
        //
        // constructor
        public function Cache(name:String = "Cache") 
        {
            super();
            _name = name;
        }
        
        /**
         * Store an asset in this Cache to be retrieved later.
         * Note: all assets to be cached are wrapped by this method in
         * an AssetWrapper at stores metadata about the asset and is also 
         * useful for cloning the asset.
         * 
         * param@ asset Asset to be cached.
         * param@ id Id under which asset is to be cached.
         * param@ giveUnique If true attempt to return a unique (new) instance
         * of the asset if possible when it is retrieved.
         * param@ url Optional metadata of any url associated with this asset.
         * param@ className Optional metadata of any Class associated with this asset.
         * param@ replace If true then replace any existing id with this asset
         * without giving a warning.
         * param@ giveWarning If false then suppress any warnings associated with
         * this call such as WARNING_CANT_CACHE_AS_UNIQUE.
         * return@ The generated AssetWrapper is returned.
         */
        public function cacheAsset(asset:*,
                                   id:String,
                                   giveUnique:Boolean = true,
                                   url:String = null,
                                   className:String = null,
                                   replace:Boolean = false,
                                   giveWarning:Boolean = true):AssetWrapper
        {   
            if (giveUnique && (asset is MovieClip || asset is Sprite)) 
            {   
                Logger.warning("Cache " + _name + "\" cannot cache id:\"" + id + "\" to give unique.\n\n" +
                    "MovieClip, and Sprite assets from a file cannot be cloned and so cannot be cached with the giveUnique flag set to true.\n\n" +
                    "You should set the giveUnique flag to false when caching this asset.", WARNING_CANT_CACHE_AS_UNIQUE);
                giveUnique = false;
            }
            
            var wrapper:AssetWrapper = new AssetWrapper(this, id);
            wrapper.initialize(asset, giveUnique, url, className);
            cacheWrapper(wrapper, replace, giveWarning);
            
            return wrapper;
        }
        
        
        /**
         * @private this method intended for internal use only.
         *
         * Caches an AssetWrapper.
         */
        public function cacheWrapper(wrapper:AssetWrapper,
                                     replace:Boolean = false,
                                     giveWarning:Boolean = true):void
        {   
            var id:String = wrapper.id;
            
            var index:int = id.indexOf('?');
            if (index > -1) 
            {
                // IDs cannot contain "?"
                throw new Error("Asset IDs cannot contain \'?\' characters.\n" +
                    "\"" + _name + "\" cannot cache asset with id: \"" + id + "\" as ID contains a \'?\' character.");
            }
            
            var existingWrapper:AssetWrapper = _assets[id];
            if (! existingWrapper || replace) 
            {   
                if (wrapper.cache != this) 
                {
                    throw new Error(" cannot cache asset wrapper " + wrapper + " as its cache (\"" + wrapper.cache.name + "\") does not match this cache (\"" + _name + "\").");
                }
                _assets[id] = wrapper;
                Logger.debug("\"" + _name + "\" cached asset id:\"" + id + "\"", DEBUG_CACHING_ASSET);
            } 
            else 
            {
                if (existingWrapper.giveUnique && ! wrapper.giveUnique) 
                {
                    Logger.warning("\"" + _name + "\" has cached asset id:\"" + id + "\" as a unique asset. You will have to forget() this asset before caching it as non-unique.",
                        WARNING_ASSET_ALREADY_CACHED_AS_UNIQUE); 
                } 
                else if (! existingWrapper.giveUnique && wrapper.giveUnique) 
                {
                    Logger.warning("\"" + _name + "\" has cached asset id:\"" + id + "\" as a non-unique asset. You will have to forget() this asset before caching it as unique.",
                        WARNING_ASSET_ALREADY_CACHED_AS_NONUNIQUE);
                } 
                else if (giveWarning) 
                {
                    Logger.warning("\"" + _name + "\" already has a cached asset with id:\"" + id + "\".", WARNING_ASSET_ALREADY_CACHED);
                }
            }
        }
        
        
        /**
         * Retrieve a cached asset
         * 
         * param@ id Id of asset to be retrieved.
         * param@ giveWarning If false then suppress any warnings associated with
         * this call such as no asset being found with the id.
         * return@ Asset cached with the id is returned.
         */
        public function retrieve(id:String, 
                                 giveWarning:Boolean = true):*
        {   
            var wrapper:AssetWrapper = retrieveWrapper(id, giveWarning);
            if (wrapper) 
            {
                return wrapper.asset;
            } 
            else 
            {
                return null;
            }
        }
        
        
        /**
         * Makes a shallow copy of asset with id and stores it under newId.
         * This is really useful when stubbing for assets with an existing asset
         * 
         * param@ id Id of asset to be copied.
         * param@ newId Id under which to store copy.
         */
        public function copy(id:String, newId:String):void
        {
            var wrapper:AssetWrapper = retrieveWrapper(id);
            if (wrapper) 
            {
                // make copy and store in cache under the newId
                wrapper = wrapper.shallowCopy(newId);
                cacheWrapper(wrapper);
            }
        }
        
        
        /**
         * @private this method intended for internal use only.
         *
         * Retrieve an AssetWrapper.
         */
        public function retrieveWrapper(id:String, 
                                        giveWarning:Boolean = true):AssetWrapper
        {   
            id = stripCGI(id);
            if (! id) 
            {
                if (giveWarning) 
                {
                    Logger.warning("\"" + _name + "\" could not retrieve asset with empty id.", WARNING_CANT_RETRIEVE_EMPTY_ID);
                }
                return null;
            }
            
            var wrapper:AssetWrapper = _assets[id];
            if (wrapper) 
            {
                return wrapper;
            } 
            else if (giveWarning) 
            {
                Logger.warning("\"" + _name + "\" could not retrieve asset id:\"" + id + "\" as it is not in cache.", WARNING_ASSET_NOT_IN_CACHE);
            }
            return null;
        }
        
        
        /** 
         * Forget a cached asset
         * 
         * @param id Id of asset to be forgotten.
         * @param giveWarning if true a warning will be given if the asset 
         * to be forgotton isn't cached.
         * @param unloadAndStop if true will force asset to clear from memory, 
         * BUT will also flush any other assets (linked Classes) associated with its loader.
         */
        public function forget(id:String, 
                               giveWarning:Boolean = true, 
                               unloadAndStop:Boolean = false):void 
        {   
            id = stripCGI(id);
            var asset:* = _assets[id];
            if (asset) 
            {
                Logger.debug("\"" + _name + "\" forgetting asset id: \"" + id + "\"", DEBUG_FORGETTING_ASSET);
                _assets[id] = null;
                delete _assets[id];
                
                if (asset is DisplayObject) 
                {
                    var displayObject:DisplayObject = asset as DisplayObject;
                    
                    // do everything we can to ensure unload
                    
                    // ensure displayObject removed from parent
                    if (displayObject.parent) 
                    {
                        displayObject.parent.removeChild(displayObject);
                    }
                    
                    // ensure any internal MovieClips are stopped as
                    //  playing MovieClips will prevent asset from being flushed from memory.
                    if (asset is DisplayObjectContainer) 
                    {
                        recursiveStop(asset as DisplayObjectContainer);
                    }
                    
                    if (unloadAndStop && displayObject.loaderInfo) 
                    {
                        // force an unloadAndStop on the assets loader
                        displayObject.loaderInfo.loader.unloadAndStop();
                    }
                }
            } 
            else if (giveWarning) 
            {
                Logger.warning("\"" + _name + "\" could not forget asset id: \"" + id + "\" as it has not been cached.",
                    WARNING_CANT_FORGET_WHATS_NOT_CACHED);
            }
        }
        
        /**
         * Forget all assets associated with a url
         * 
         * @param url url to be forgottton
         */
        public function forgetUrl(url:String):void
        {
            for each (var wrapper:AssetWrapper in _assets) 
            {
                if (wrapper.url == url) 
                {
                    forget(wrapper.id);
                }
            }
        }
        

        /**
         * Clear this cache, forgetting ALL assets.
         * 
         * @param url url to be forgottton
         */
        public function clear():void 
        {
            for (var id:String in _assets) 
            {
                forget(id);
            }
        }
        
        
        /**
         * Return a String with a list of all assets cached.
         * This is useful for printing the contents of the Cache.
         * 
         * @return String of all assets cached.
         */
        public function dumpCache():String 
        {
            var str:String = "Cached assets:\n";
            
            var index:uint = 0;
            for (var id:String in _assets) 
            {
                str += ++index + ") id: \"" + id + "\" " + _assets[id] + "\n";
            }
            
            return str;
        }
        
        public function get name():String                   { return _name; }
        public function get assets():Array                  { return _assets; }
        
        
        //
        // static helper methods
        //
        
        /**
         * Strips any CGI "?" variables from a url String.
         *
         * @param url URL String being stripped
         * 
         * @return Returns the cleaned URL String
         */
        public static function stripCGI(url:String):String
        {
            if (! url) 
            {
                return null;
            }
            
            var index:int = url.indexOf('?');
            if (index > -1) 
            {
                // strip out any "?" CGI data
                url = url.slice(0, index);
            }
            
            return url;
        }
        
        
        /**
         * Recursively stop any MovieClip children attached to a DisplayObjectContainer
         * 
         * @param container DisplayObjectContainer being stopped
         */
        public static function recursiveStop(container:DisplayObjectContainer):void 
        {
            for (var i:uint = 0; i < container.numChildren; ++i) 
            {
                var child:DisplayObject = container.getChildAt(i);
                if (child is MovieClip)
                {
                    (child as MovieClip).stop();
                }
                
                if (child is DisplayObjectContainer) 
                {
                    recursiveStop(child as DisplayObjectContainer);
                }
            }
        }
    }
}
