//
//  AssetWrapper v 1.1 - assetManager package
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
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.media.Sound;
    import flash.net.URLVariables;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    
    
    /**
     * @author Russell Lowke
     */
    public class AssetWrapper 
    {   
        protected var _cache:Cache;         // Cache instance storing this asset
        protected var _id:String;           // id of this asset
        private var _asset:*;               // the cached asset
        private var _giveUnique:Boolean;    // if true then gives unique instance
        private var _timeAccessed:uint;     // time asset was last accessed
        private var _url:String;            // (optional) url to this asset
        private var _className:String;      // (optional) class name of this asset, if any
        private var _misc:Object;           // useful miscellaneous holder that can be set and got
        
        
        public function AssetWrapper(cache:Cache, id:String) 
        {
            _cache = cache;
            _id = id;
        }
        
        public function initialize(asset:*, 
                                   giveUnique:Boolean = true, 
                                   url:String = "", 
                                   className:String = ""):void 
        {   
            _asset = asset;
            _giveUnique = giveUnique;
            _url = url;
            _className = className;
            _timeAccessed = getTimer();
        }
        
        public function toString():String 
        {
            return _asset;
        }
        
        public function get asset():* 
        {   
            _timeAccessed = getTimer();
            
            if (! _giveUnique || ! _asset) 
            {
                return _asset;
            } 
            else if (_asset is Class) 
            {
                // return instance of Class
                return new _asset(); 
            } 
            else if (_asset is Bitmap) 
            { 
                //  Note: this is a shallow copy using the same bitmap data
                return new Bitmap((_asset as Bitmap).bitmapData);
            } 
            else if (_asset is BitmapData) 
            {
                return (_asset as BitmapData).clone();
            } 
            else if (_asset is Sound)
            {
                // Sounds generally do not need to be cloned and probably can't be cloned.
                return _asset;
            }
            else if (_asset is String) 
            {
                var str:String = _asset as String;
                return str;
            } 
            else if (_asset is XML) 
            {
                return (_asset as XML).copy();
            } 
            else if (_asset is ByteArray) 
            {
                // clone will work on ByteArray
                return clone(_asset);
            } 
            else if (_asset is URLVariables) 
            {
                // copy URLVariables
                return new URLVariables((_asset as URLVariables).toString());
            } 
            else 
            {
                Logger.warning("Cache cannot return unique instance of " + _asset, Cache.WARNING_CANT_RETURN_UNIQUE_INSTANCE);
                return _asset;
            }
        }
        
        // make a shallow copy of the wrapper but with a new id
        public function shallowCopy(newID:String):AssetWrapper
        {
            var wrapper:AssetWrapper = new AssetWrapper(_cache, newID);
            wrapper.initialize(_asset, _giveUnique, _url, _className);
            return wrapper;
        }
        
        public function get cache():Cache                   { return _cache; }
        public function get id():String                     { return _id; }
        public function get giveUnique():Boolean            { return _giveUnique; }
        public function get timeAccessed():uint             { return _timeAccessed; }
        public function get url():String                    { return _url; }
        public function get className():String              { return _className; }
        public function get misc():Object                   { return _misc; }
        
        public function set url(val:String):void            { _url = Cache.stripCGI(val); }
        public function set giveUnique(val:Boolean):void    { _giveUnique = val; }
        public function set className(val:String):void      { _className = val; }
        public function set misc(val:Object):void           { _misc = val; }
        
        /**
         * Make a deep copy of an object.
         * Works particularly well with indexed and associative arrays,
         *  but doesn't work with DisplayObjects. With DisplayObjects 
         *  try var objectClass:Class = Object(source).constructor;
         *      var object:* = new objectClass();
         * 
         * @param object Object being copied
         */
        public static function clone(object:Object):* 
        {
            var data:ByteArray = new ByteArray();
            data.writeObject(object);
            data.position = 0;
            return data.readObject();
        }
    }
}



/*

Ways of copying objects, none of which seem to work for DisplayObjects

private static function cloneObject(obj:Object):Object {
var ba:ByteArray = new ByteArray();
ba.writeObject(obj);
ba.position = 0;
return ba.readObject();
}

// returns you the full class name for any object.
var className:String = getQualifiedClassName(asset);        returns  "MainTimeline"

// returns the class object, from which you can cast or make more
var classObj:Class = getDefinitionByName(className) as Class;
getQualifiedSuperclassName

// from the Flex SDK. Trouble is we generally don't use the Flex SDK,
// and even this doesn't work with DisplayObjects
import mx.utils.ObjectUtil;
var test:Object = ObjectUtil.copy(asset);


// copies an array of references
//  just uses map(), but implementation is not obvious
public static function copy(arr:Array):Array {
return arr.map(function (element:*):* { return element; });
}

// make a unique copy of BMP
public static function copyBMP(bmp:Bitmap):Bitmap {
return new Bitmap(bmp.bitmapData);
}

*/