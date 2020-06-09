//
//  LoadJSON v 1.0
//  Russell Lowke, April 13th 2013
// 
//  Copyright (c) 2013 Lowke Media
//  see http://www.lowkemedia.com for more information
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
    import flash.net.URLLoader;
    import flash.net.URLVariables;
    
	/**
	 * @author Russell Lowke
	 */
    public class LoadJson extends LoadData implements ILoad
    {   
		private var _urlVariables:URLVariables;
		
        //
        // constructor
        public function LoadJson(url:String):void
        {   
            super(url);
        }
		
        override public function fileLoaded(evt:Event = null):void 
        {
			var loaderData:String = (_loader as URLLoader).data;

            var data:Object;
			try
            {
                data = JSON.parse(loaderData);
            }
            catch (error:Error)
            {
                data = null;
                Logger.warning("JSON improperly formatted in file:\r" + _request.url, AssetLoader.WARNING_JSON_IMPROPERLY_FORMATTED);
            }

            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, data, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
    }
}   