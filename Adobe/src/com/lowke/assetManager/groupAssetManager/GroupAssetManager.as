//
//  GroupAssetManager v 1.0 - assetManager package
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

package com.lowke.assetManager.groupAssetManager
{   
    import com.lowke.assetManager.AssetManager;
    import com.lowke.assetManager.cache.Cache;
    
    public class GroupAssetManager extends AssetManager 
    {   
        // static reference to AssetLoader loose singleton
        private static const INSTANCE:GroupAssetManager = new GroupAssetManager();
        
        public function GroupAssetManager(cache:Cache = null) 
        {
            super(cache);
        }
        
        public function cacheGroupWrapper(id:String,
                                          assetIDs:Array,
                                          replace:Boolean = false,
                                          giveWarning:Boolean = true):AssetGroup 
        {   
            var assetGroup:AssetGroup = new AssetGroup(_cache, id);
            assetGroup.initializeAssetGroup(assetIDs);
            _cache.cacheWrapper(assetGroup, replace, giveWarning);
            return assetGroup;
        }
        public static function cacheGroupWrapper(id:String, 
                                                 assetIDs:Array, 
                                                 replace:Boolean = false):AssetGroup 
        {
            return INSTANCE.cacheGroupWrapper(id, assetIDs, replace);
        }
        
        //
        // accessors and mutators
        //
        
        public static function get instance():GroupAssetManager
        { 
            return INSTANCE;
        }
    }
}