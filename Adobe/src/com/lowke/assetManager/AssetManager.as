//
//  AssetManager v 3.2 - assetManager package
//  Russell Lowke, June 30th 2013
//
//  Copyright (c) 2008-2013 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-assetloader/ for code repository
//  see http://code.google.com/p/lowke/ for entire lowke code repository
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

package com.lowke.assetManager
{   
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.assetLoader.event.LoaderDisposedEvent;
    import com.lowke.assetLoader.loader.ILoad;
    import com.lowke.assetManager.cache.Cache;
    import com.lowke.logger.Logger;
    
    import flash.events.EventDispatcher;
    import flash.net.URLVariables;
    
    /**
     * <p>AssetManager is designed to let you easily manage externally loaded assets
     * and maintain low memory by calling forget() on loaded assets.
     * Forgotten assets are cleanly flushed from memory.</p>
     * 
     * <p>External assets may include .swf files or even linked Classes or Class 
     * definitions within .swf files.</p>
     * 
     * <p>The AssetManager essentially delegates between the AssetLoader and Cache 
     * packages, where the Cache package is a standalone package internal to the 
     * AssetManager.</p>
     *
     * @author Russell Lowke
     * @langversion ActionScript 3.0
     * @playerversion Flash 10
     * @see http://www.lowkemedia.com
     */
    public class AssetManager extends EventDispatcher
    {   
        //
        // loader types used by load()
        public static const LOADER_TYPE_SWF:String       = AssetLoader.LOADER_TYPE_SWF;         // .swf             Small Web Format/Flash
        public static const LOADER_TYPE_IMAGE:String     = AssetLoader.LOADER_TYPE_IMAGE;       // .bmp             Bitmap image file format
        //                                                                                      // .png             Portable Network Graphics
        //                                                                                      // .jpg, .jpeg      Joint Photographic Experts Group
        //                                                                                      // .gif             Graphics Interchange Format
        public static const LOADER_TYPE_SOUND:String     = AssetLoader.LOADER_TYPE_SOUND;       // .aif, .aiff      Audio Interchange File Format 
        //                                                                                      // .mp3             MPEG-1 Audio Layer 3
        //                                                                                      // .wav             Waveform audio format 
        public static const LOADER_TYPE_DATA:String      = AssetLoader.LOADER_TYPE_DATA;        // .html            Hypertext Markup Language
        //                                                                                      // .txt, .text      Text (ASCI) data
        public static const LOADER_TYPE_XML:String       = AssetLoader.LOADER_TYPE_XML;         // .xml             Extensible Markup Language
        public static const LOADER_TYPE_BINARY:String    = AssetLoader.LOADER_TYPE_BINARY;      // .bin             Binary
        public static const LOADER_TYPE_VARIABLES:String = AssetLoader.LOADER_TYPE_VARIABLES;   // .var, .vars      Url variables
        
        
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String                       = "MGR";
        public static const WARNING_CANT_LINK_CACHE:String          = "MGR00";
        public static const WARNING_CACHE_ALREADY_LINKED:String     = "MGR01";
        public static const WARNING_CACHE_NOT_LINKED:String         = "MGR02";
        
        protected var _cache:Cache;                     // asset cache
        protected var _linkedCaches:Vector.<Cache>;     // list of linked caches
        private var _isCaching:Array;                   // caching assets with loading still in progress
        private var _assetLoader:AssetLoader;           // reference to AssetLoader
        
        //
        // constructor
        
        /**
         * <p>AssetManager may accept a Cache instance to use when storing assets.
         * If no Cache instance is supplied then a new Cache is generated.</p>
         * 
         * <p>Multiple AssetManager instances may be maintained in order to
         * group assets, and all assets within an AssetManager may be 
         * flushed together by calling clear().</p>
         * 
         * <p>AssetManager Caches' may be linked using linkCache()</p>
         * 
         * @param cache Cache to use with this AssetManager. If no Cache 
         * instance is supplied then a new Cache is generated.
         */
        public function AssetManager(cache:Cache = null)
        {   
            _assetLoader = AssetLoader.instance;
            _cache = cache;
            _isCaching = new Array();
            
            if (! _cache) 
            {
                _cache = new Cache();
            }
            _linkedCaches = new Vector.<Cache>;
        }
        
        
        /**
         * <p>Load an asset and cache it using its url as the id.</p>
         * 
         * <p>If the file is already cached then the callBackFunct
         * is automatically called and the asset delivered without reloading the file.</p>
         * 
         * <p>If the .swf file is currently loading then it's only loaded
         * once rather than attempting multiple loads for the same request
         * in the same batch.</p>
         * 
         * @param url URL to make request to.
         * @param giveUnique If true a unique instance (a clone) of the asset 
         * is delivered. Note though that .swf files cannot be cloned.
         * When loading a .swf the giveUnique flag must be set as false or
         * a warning will be given.
         * @param id The id by which to recognize this asset.  If no id is given
         * then the url is used as the id.
         * @param showProgress If false then load progress for this asset will
         * not be included in the percentDone value dispatched by the AssetLoader.
         */
        public function cacheFile(url:String,
                                  giveUnique:Boolean = true,
                                  id:String = null,
                                  showProgress:Boolean = true,
                                  callBackFunct:Function = null):void
        {
            if (! id) 
            {
                id = url;
            }
            
            if (retrieveAndDeliver(id, callBackFunct))
            {
                return;
            }
                
            // load and cache the asset
            var loader:ILoad = _assetLoader.loadFile(url, function(asset:*):void
                {
                    cacheFromLoader(asset, id, url, null, giveUnique, callBackFunct);
                });
            
            // A null loader will have given warnings why it can't load.
            if (loader) 
            {
                loader.showProgress = showProgress;
                addCaching(id, loader);
            }
        }
        
        /**
         * <p>Load an asset and cache it using a customized loader.</p>
         * 
         * <p>Assets cached using a custom loader will always deliver as
         * non-unique assets (giveUnique = false) as the Cache has no way of
         * knowing how to clone them.</p>
         * 
         * @param loader ILoad instance to use when loading the asset.
         * @param id The id by which to recognize this asset.  If no id is given
         * then the loader's url is used as the id.
         * @param showProgress If false then load progress for this asset will
         * not be included in the percentDone value dispatched by the AssetLoader.
         */
        public function cacheFileUsing(loader:ILoad,
                                       id:String = null,
                                       showProgress:Boolean = true,
                                       callBackFunct:Function = null):void
        {
            // We don't know how to clone custom asset from a 
            //  custon loader, so giveUnique flag must be false.
            // TODO: PERHAPS SEARCH/TRY FOR A clone() METHOD ON THE ASSET?
            var giveUnique:Boolean = false;
            
            // pluck the url from the loader
            var url:String = loader.url;
            
            if (! id) 
            {
                id = url;
            }
            
            if (retrieveAndDeliver(id, callBackFunct))
            {
                return;
            }
            
            // load and cache the asset
            _assetLoader.loadUsing(loader, function(asset:*):void
                {
                    cacheFromLoader(asset, id, url, null, giveUnique, callBackFunct);
                });
            loader.showProgress = showProgress;
            addCaching(id, loader);
        }
        
        
        /**
         * <p>Load a linked Class from inside a .swf and cache it using its 
         * className as the id.</p>
         * 
         * <p>If the Class is already cached then the callBackFunct
         * is automatically called and the instance delivered without reloading 
         * the .swf file.</p>
         * 
         * <p>If the .swf file is currently loading then it's only loaded
         * once rather than attempting multiple loads for the same request
         * in the same batch.</p>
         * 
         * @param url URL of the .swf file to make request to.
         * @param className Name of linked class to cache from the .swf.
         * @param giveUnique If true a unique instance (new) of the linked Class 
         * is delivered. If false then always the same instance is delivered.
         * @param id The id by which to recognize this asset.  If no id is given
         * then the className is used as the id.
         * @param showProgress If false then load progress for this asset will
         * not be included in the percentDone value dispatched by the AssetLoader.
         */
        public function cacheClass(url:String,
                                   className:String,
                                   giveUnique:Boolean = true,
                                   id:String = null,
                                   showProgress:Boolean = true,
                                   callBackFunct:Function = null):void
        {   
            if (! id) 
            {
                id = className;
            }
            
            if (retrieveAndDeliver(id, callBackFunct))
            {
                return;
            }
                
            // tell loader to load class
            var loader:ILoad;
            if (giveUnique) 
            {
                loader = _assetLoader.loadClassDefinition(url, className, function(asset:*):void
                    {
                        cacheFromLoader(asset, id, url, className, true, callBackFunct);
                    });
            } 
            else 
            {
                loader = _assetLoader.loadClass(url, className, function(asset:*):void
                    {
                        cacheFromLoader(asset, id, url, className, false, callBackFunct);
                    });
            }
            
            // A null loader will have given warnings why it can't load.
            if (loader) 
            {
                loader.showProgress = showProgress;
                addCaching(id, loader);
            }
        }
        
        /**
         * <p>Load a linked ClassDefinition from inside a .swf and cache it using  
         * its className as the id.</p>
         * 
         * <p>If the ClassDefinition is already cached then the callBackFunct
         * is automatically called and the definition delivered without reloading 
         * the file.</p>
         * 
         * <p>If the .swf file is currently loading then it's only loaded
         * once rather than attempting multiple loads for the same request
         * in the same batch.</p>
         * 
         * @param url URL of the .swf file to make request to.
         * @param className Name of linked class to cache from the .swf.
         * @param id The id by which to recognize this asset.  If no id is given
         * then the className is used as the id.
         * @param showProgress If false then load progress for this asset will
         * not be included in the percentDone value dispatched by the AssetLoader.
         */
        public function cacheClassDefinition(url:String,
                                             className:String,
                                             id:String = null,
                                             showProgress:Boolean = true,
                                             callBackFunct:Function = null):void
        {
            if (! id) 
            {
                id = className;
            }
            
            if (retrieveAndDeliver(id, callBackFunct))
            {
                return;
            }
            
            // load and cache the asset
            var loader:ILoad = _assetLoader.loadClassDefinition(url, className, function(asset:*):void
                {
                    cacheFromLoader(asset, id, url, className, false, callBackFunct);
                });
            
            // A null loader will have given warnings why it can't load.
            if (loader)
            {
                loader.showProgress = showProgress;
                addCaching(id, loader);
            }
        }
        
        // Try to retrieve and deliver an asset using its id.
        //  return true if asset is able to be delivered.
        private function retrieveAndDeliver(id:String, 
                                            callBackFunct:Function):Boolean
        {
            var asset:* = _cache.retrieve(id, false);
            if (asset) 
            {
                deliverAsset(asset, callBackFunct);
                return true;
            } 
            
            // check if asset currently being loaded
            var loader:ILoad = cachingLoader(id);
            
            if (loader) 
            {
                retryAfterLoad(loader, id, callBackFunct);
                return true;
            }
            
            return false;
        }
        
        private function retryAfterLoad(loader:ILoad,
                                        id:String,
                                        callBackFunct:Function):void
        {
            // retry once asset loaded (and cached)
            var listener:Function = function(event:AssetLoadedEvent):void
            {
                loader.removeEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
                deliverAsset(_cache.retrieve(id, false), callBackFunct);
            };
            loader.addEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
        }
        
        //
        // asset returned from AssetLoader to be cached
        private function cacheFromLoader(asset:*,
                                         id:String,
                                         url:String,
                                         className:String,
                                         giveUnique:Boolean,
                                         callBackFunct:Function):void
        {
            if (asset) 
            {
                // cache the asset
                _cache.cacheAsset(asset, id, giveUnique, url, className);
                
                // and deliver
                deliverAsset(_cache.retrieve(id), callBackFunct);
            } 
            else 
            {
                // clear caching flag on failed loader
                removeCaching(id);
                
                // asset failed to load
                deliverAsset(null, callBackFunct);
            }
        }
        
        private static function deliverAsset(asset:*, 
                                             callBackFunct:Function):void
        {
            if (callBackFunct != null) 
            {
                callBackFunct(asset);
            }
        }
        
        /**
         * Fetches the loader associated with a currently loading asset 
         * that's to be cached with the id. This can be useful if you need 
         * to close the loader prematurely.
         * 
         * @param id Id of the asset for which the ILoad instance is needed.
         * @return ILoad instance being used for the load.
         */
        public function cachingLoader(id:String):ILoad 
        {
            return _isCaching[id];
        }
        
        // add a loader to the isCaching list
        private function addCaching(id:String, 
                                    loader:ILoad):void 
        {
            _isCaching[id] = loader;
            
            // when loader is disposed it must be removed from _isCaching list
            var listener:Function = function (event:LoaderDisposedEvent):void 
            {
                loader.removeEventListener(LoaderDisposedEvent.LOADER_DISPOSED, listener);
                removeCaching(id);
            };
            loader.addEventListener(LoaderDisposedEvent.LOADER_DISPOSED, listener);
        }
        
        private function removeCaching(id:String):void 
        {
            _isCaching[id] = null;
            delete _isCaching[id];
        }
        
        
        /**
         * Links a Cache to this AssetManager.
         * Multiple Caches may be linked at once.
         * 
         * param@ cache Cache being linked to this AssetMananger.
         * param@ giveWarning If true a warning is given if the cache 
         * is already linked to this AssetManager.
         */
        public function linkCache(cache:Cache, 
                                  giveWarning:Boolean = true):void
        {
            if (cache == _cache) 
            {
                if (giveWarning) 
                {
                    Logger.warning("Can't link Cache \"" + cache.name + "\" to AssetManager " + this + " is it's already the primary Cache for the AssetManager.", WARNING_CANT_LINK_CACHE);
                }
                return;
            }
            
            if (_linkedCaches.indexOf(cache) != -1) 
            {
                if (giveWarning) 
                {
                    Logger.warning("Cache \"" + cache.name + "\" is already linked to AssetManager " + this + ".", WARNING_CACHE_ALREADY_LINKED);
                }
                return;
            }
            
            _linkedCaches.push(cache);
        }
        
        
        /**
         * Retrieve a specific asset using its id.
         * 
         * @param id Id of asset being retrieved.
         * @param giveWarning If false then suppress warnings associated 
         * with this call such as if the asset is not found.
         * @return The asset associated with the id is returned.
         * null is returned if no asset is found.
         */
        public function retrieve(id:String, 
                                 giveWarning:Boolean = true):* 
        {
            // 1st, check primary cache for asset
            var asset:* = _cache.retrieve(id, false);
            
            if (! asset) 
            {
                // 2nd, check all linked caches
                for each (var cache:Cache in _linkedCaches) 
                {
                    asset = cache.retrieve(id, false);
                    if (asset) 
                    {
                        return asset;
                    }
                }
                
                // 3rd, if not found in linked caches and required 
                //  to give warning then give it
                if (giveWarning) 
                {
                    _cache.retrieve(id, true);
                }
            }
            
            return asset;
        }
        
        /**
         * Removes a linked cache from this AssetManager.
         * 
         * param@ cache Cache being unlinked from this AssetMananger.
         * param@ giveWarning If true a warning is given if cache not 
         * linked to this AssetManager.
         */
        public function unlinkCache(cache:Cache, 
                                    giveWarning:Boolean = true):void
        {
            var index:int = _linkedCaches.indexOf(cache);
            if (index == -1) 
            {
                if (giveWarning) 
                {
                    Logger.warning("Can't remove cache \"" + cache.name + "\" as it's not linked to AssetManager " + this + ".", WARNING_CACHE_NOT_LINKED);
                }
                return;
            }
            
            _linkedCaches.splice(index, 1);
        }
        
        /**
         * Unlinks all linked caches from this AssetManager.
         */
        public function unlinkCaches():void
        {
            while (_linkedCaches.length) 
            {
                unlinkCache(_linkedCaches[0]);
            }
        }
        
        
        //
        // passthrough methods to AssetLoader
        //
        
		/** Passthrough method. See AssetLoader loadFile() */
		public function loadFile(url:String, callBackFunct:Function = null):ILoad
		{
			return _assetLoader.loadFile(url, callBackFunct);
		}
		
		/** Passthrough method. See AssetLoader loadClass() */
		public function loadClass(url:String, className:String, callBackFunct:Function = null):ILoad
		{
			return _assetLoader.loadClass(url, className, callBackFunct);
		}
		
		/** Passthrough method. See AssetLoader urlRequest() */
        public function urlRequest(url:String, variables:URLVariables = null, requestMethod:String = null, callBackFunct:Function = null):ILoad
        {
            return _assetLoader.urlRequest(url, variables, requestMethod, callBackFunct);
        }
        
		/** Passthrough method. See AssetLoader urlJsonRequest() */
        public function urlJsonRequest(url:String, variables:URLVariables = null, requestMethod:String = null, callBackFunct:Function = null):ILoad
        {
            return _assetLoader.urlJsonRequest(url, variables, requestMethod, callBackFunct);
        }
        
		/** Passthrough method. See AssetLoader load() */
        public function load(url:String, loaderType:String, callBackFunct:Function = null):ILoad
        {
            return _assetLoader.load(url, loaderType, callBackFunct);
        }
        
		/** Passthrough method. See AssetLoader loadUsing() */
        public function loadUsing(loader:ILoad, callBackFunct:Function = null):ILoad
        {
            return _assetLoader.loadUsing(loader, callBackFunct);
        }
        
		/** Passthrough method. See AssetLoader loadClassDefinition() */
        public function loadClassDefinition(url:String, className:String, callBackFunct:Function):ILoad
        {
            return _assetLoader.loadClassDefinition(url, className, callBackFunct);
        }
        
		/** Passthrough method. See AssetLoader whenDone() */
        public function whenDone(callBackFunct:Function):void
        {
            _assetLoader.whenDone(callBackFunct);
        }
        
        //
        // passthrough methods to Cache
        //
        
		/** Passthrough method. See Cache cacheAsset() */
        public function cacheAsset(asset:*, id:String, giveUnique:Boolean = true, replace:Boolean = false, giveWarning:Boolean = true):void 
        {
            _cache.cacheAsset(asset, id, giveUnique, null, null, replace, giveWarning);
        }
        
		/** Passthrough method. See Cache forget() */
        public function forget(id:String, giveWarning:Boolean = true, unloadAndStop:Boolean = true):void 
        {  
            _cache.forget(id, giveWarning, unloadAndStop);
        }
        
		/** Passthrough method. See Cache forgetUrl() */
        public function forgetUrl(url:String):void 
        {
            _cache.forgetUrl(url);
        }
        
		/** Passthrough method. See Cache copy() */
        public function copy(id:String, newId:String):void 
        {
            _cache.copy(id, newId);
        }
        
		/** Passthrough method. See Cache clear() */
        public function clear():void 
        {
            _cache.clear();
        }
        
		
        //
        // accessors and mutators
        //
        
		/** Returns Cache instance used by this AssetManager */
        public function get cache():Cache
        { 
            return _cache; 
        }
        
		/** Returns list of Cache instances linked to this AssetManager */
        public function get linkedCaches():Vector.<Cache>
        { 
            return _linkedCaches; 
        }
        
        /** Returns true if nothing is loading for this AssetManager. */
        public function get idle():Boolean
        { 
            return (_isCaching.length == 0); 
        }
    }
}
