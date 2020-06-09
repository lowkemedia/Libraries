//
//  LoadXML v 1.2.1 - assetLoader package
//  Russell Lowke, December 18th 2011
// 
//  Copyright (c) 2008-2011 Lowke Media
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

package com.lowke.assetLoader.loader
{   
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.logger.Logger;
    
    import flash.events.Event;
    import flash.net.URLLoader;
    
    /**
     * @author Russell Lowke
     */
    public class LoadXML extends LoadData implements ILoad 
    {   
        //
        // constructor
        public function LoadXML(url:String) 
        {   
            super(url);
        }
        
        override public function fileLoaded(event:Event = null):void 
        {
            var xml:XML;
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            try 
            {
                xml = new XML((_loader as URLLoader).data);
            } 
            catch (err:Error) 
            {
                Logger.warning(err.message + "\nError in XML file: " + this.url, AssetLoader.WARNING_PARSE_ERROR);
            }
            
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, xml, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
    }
}   