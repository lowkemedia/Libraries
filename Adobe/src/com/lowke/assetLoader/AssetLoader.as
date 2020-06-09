//
//  AssetLoader v 3.2 - assetLoader package
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

package com.lowke.assetLoader
{
    import com.lowke.Delayer;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.assetLoader.event.BatchCompleteEvent;
    import com.lowke.assetLoader.event.LoaderProgressEvent;
    import com.lowke.assetLoader.loader.ILoad;
    import com.lowke.assetLoader.loader.LoadBinary;
    import com.lowke.assetLoader.loader.LoadClass;
    import com.lowke.assetLoader.loader.LoadData;
    import com.lowke.assetLoader.loader.LoadImage;
    import com.lowke.assetLoader.loader.LoadJson;
    import com.lowke.assetLoader.loader.LoadSound;
    import com.lowke.assetLoader.loader.LoadSwf;
    import com.lowke.assetLoader.loader.LoadUrlJsonRequest;
    import com.lowke.assetLoader.loader.LoadUrlRequest;
    import com.lowke.assetLoader.loader.LoadVariables;
    import com.lowke.assetLoader.loader.LoadXML;
    import com.lowke.logger.Logger;
    
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLVariables;
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    
    // dispatched when all assets have completed loading
    [Event(name = "assetLoaderBatchComplete", type = "com.lowke.assetLoader.event.BatchCompleteEvent")]
    
    // dispatched with a percentage progress report on all assets loading
    [Event(name = "assetLoaderProgress", type = "com.lowke.assetLoader.event.LoaderProgressEvent")]
    
    /**
     * <p>AssetLoader is designed to allow you to easily bulk load assets from
     * external files. In particular, it easily and conveniently supplies you with
     * a single reference to your external asset. Clearing that reference generally
     * will release the asset from memory (see note below). This tidies up the mess
     * of event listeners and object references often associated with the Flash
     * Loader that can make bulk loading of external assets and clearing of those
     * assets tedious.</p>
     *
     * <p>AssetLoader is a singleton, a reference to it is obtained through
     * AssetLoader.instance. See the AssetLoaderExample project for an example of
     * how to use AssetLoader.</p>
     *
     * <p>Note: Flash DisplayObject assets can be unusually stubborn to unload,
     * particularly if the asset is a MovieClip that has children that are playing
     * or if there are hard EventListeners attached to it. You should stop all
     * MovieClips and remove all EventListeners on an asset before clearing the
     * reference. As of Flash Player 10 you can dispose of stubborn DisplayObject
     * assets using the Flash Player 10 unloadAndStop() method on the asset's Flash
     * Loader, which can be accessed through loaderInfo.loader, like so,
     * <code>displayObjectAsset.loaderInfo.loader.unloadAndStop();</code></p>
     *
     * To get the progress of the AssetLoader while loading assets use,
     * <pre>
     *  import com.lowke.assetLoader.events.ProgressEvent;
     *  AssetLoader.addEventListener(AssetLoader.PROGRESS, printProgress);
     *
     *  public function printProgress(event:ProgressEvent):void {
     *      trace("Percent loaded:" + Math.round(event.percentDone*100) + "%");
     *  }
     * </pre>
     *
     * You can also get the progress by querying the AssetLoader directly,
     * <pre>
     *  var percentDone:Number = AssetLoader.percentDone;
     * </pre>
     *
     * <p>Note: You might need to set permissions for local file access from the
     * Flash Global Security Settings panel, see,
     * http://www.macromedia.com/support/documentation/en/flashplayer/help/
     * and select "Global Security Settings Panel"</p>
     * 
     * <p> Alternatively you can set the -use-network=false parameter in the compiler
     * to allow local file access</p>
     *
     * @author Russell Lowke
     * @langversion ActionScript 3.0
     * @playerversion Flash 10
     * @see http://www.lowkemedia.com
     */
    public class AssetLoader extends EventDispatcher
    {
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String = "LDR";
        public static const WARNING_CANT_RECOGNIZE_FILE_TYPE:String = "LDR00";
        public static const WARNING_CANT_RECOGNIZE_LOADER_TYPE:String = "LDR01";
        public static const WARNING_FILE_NOT_FOUND:String = "LDR02";
        public static const WARNING_FILE_CANT_LOAD:String = "LDR03";
        public static const WARNING_CLASS_NOT_FOUND:String = "LDR04";
        public static const WARNING_SECURITY_BREACH:String = "LDR05";
        public static const WARNING_PARSE_ERROR:String = "LDR06";
        public static const WARNING_LOAD_TIMEOUT:String = "LDR07";
        public static const WARNING_EMPTY_URL:String = "LDR08";
        public static const WARNING_LOADCLASS_MUST_LOAD_A_SWF:String = "LDR09";
        public static const WARNING_BAD_KEY:String = "LDR10";
        public static const WARNING_LOADER_ISSUE:String = "LDR11";
        public static const WARNING_JSON_IMPROPERLY_FORMATTED:String = "LDR12";
        public static const INFO_FILE_CLOSED:String = "LDR13";
        public static const DEBUG_FILE_REQUESTED:String = "LDR14";
        public static const DEBUG_FILE_LOADED:String = "LDR15";
        public static const DEBUG_BATCH_COMPLETE:String = "LDR16";
        
        //
        // loader types
        public static const LOADER_TYPE_SWF:String = "swf";                         // .swf             Small Web Format/Flash
        public static const LOADER_TYPE_IMAGE:String = "image";                     // .bmp             Bitmap image file format
                                                                                    // .png             Portable Network Graphics
                                                                                    // .jpg, .jpeg      Joint Photographic Experts Group
                                                                                    // .gif             Graphics Interchange Format
        public static const LOADER_TYPE_SOUND:String = "sound";                     // .aif, .aiff      Audio Interchange File Format
                                                                                    // .mp3             MPEG-1 Audio Layer 3
                                                                                    // .wav             Waveform audio format
        public static const LOADER_TYPE_DATA:String = "data";                       // .html            Hypertext Markup Language
                                                                                    // .txt, .text      Text (ASCI) data
        public static const LOADER_TYPE_JSON:String = "json";                       // .json            JavaScript Object Notation
        public static const LOADER_TYPE_XML:String = "xml";                         // .xml             Extensible Markup Language
        public static const LOADER_TYPE_BINARY:String = "binary";                   // .bin             Binary
        public static const LOADER_TYPE_VARIABLES:String = "variables";             // .var, .vars      Url variables
        
        // static reference to AssetLoader singleton
        private static var _instance:AssetLoader;
        private static var _timeoutRetry:uint = 10000;  // in milliseconds. After 10 seconds loader will timeout and try again.
        private static var _retryAttemps:uint = 3;      // the loader will make 3 attempts to load an asset on non-obvious fails
        
        // member variables
        private var _loaders:Dictionary = new Dictionary(true); // Keep a reference to loaders in use
        private var _nLoadersRemaining:uint = 0;    // # of loaders remaining to load
        private var _nLoadersTotal:uint = 0;        // # of loaders in this batch
        private var _percentDone:Number = NaN;      // percent loaded of _nLoadersTotal, NaN returned if idle
        
        /**
         * AssetLoader is a singleton and should never be constructed directly.
         * Use AssetLoader.instance to obtain a reference to the AssetLoader.
         */
        public function AssetLoader()
        {
            super();
            
            if (_instance != null) 
            {
                // show error to prevent new instances of AssetLoader being created.
                throw new Error("AssetLoader is a singleton, it should never be created twice.\n" +
                    "Use AssetLoader.instance to get a reference to AssetLoader.");
            }
            _instance = this;
        }
        

        /**
         * Make a url request passing specific variables where a String is delivered.
         * 
         * @param url URL to make request to.
         * @param variables URLVariables to be called on the Url.
         * @param method URLRequestMethod to be used for the request.  Defaults to URLRequestMethod.POST.
         * @param callBackFunct Function callback which is passed the String response.
         */
        public function urlRequest(url:String,
                                   variables:URLVariables = null,
                                   requestMethod:String = null,
                                   callBackFunct:Function = null):ILoad
        {
            if (! stringHasValue(url)) 
            {
                Logger.warning("urlRequest() received an empty url.", WARNING_EMPTY_URL);
                return null;
            }
            
            var loader:LoadUrlRequest = new LoadUrlRequest(url, variables, requestMethod);
            loadUsing(loader, callBackFunct);
            return loader;
        }
        
        /**
         * Make a url request
         * 
         * @param url URL to make request to.
         * @param variables URLVariables to be called on the Url.
         * @param method URLRequestMethod to be used for the request.  Defaults to URLRequestMethod.POST.
         * @param callBackFunct Function callback which is passed the String response.
         */
        public function urlJsonRequest(url:String,
                                       variables:URLVariables = null,
                                       requestMethod:String = null,
                                       callBackFunct:Function = null):ILoad
        {
            if (! stringHasValue(url)) 
            {
                Logger.warning("urlJsonRequest() received an empty url.", WARNING_EMPTY_URL);
                return null;
            }
            
            var loader:LoadUrlJsonRequest = new LoadUrlJsonRequest(url, variables, requestMethod);
            loadUsing(loader, callBackFunct);
            return loader;
        }
        
        /**
         * <p>Loads an external file whose file type is determined by its file extension.
         * Once the asset has finished loading it is passed as the 1st argument to a function callback.
         * The type of the 1st parameter of the function callback should reflect the type of the file being loaded.</p>
         *
         * <p>For example, loading an LOADER_TYPE_XML file would be done like so,</p>
         *
         * <pre>
         *  AssetLoader.instance.loadFile("config.xml", gotXML);
         * </pre>
         *
         * <p>With the callback function looking like so,</p>
         *
         * <pre>
         *  private function gotXML(cfg:LOADER_TYPE_XML):void {
         *      if (! cfg) {
         *          trace("LOADER_TYPE_XML failed to load");
         *      } else {
         *          trace("LOADER_TYPE_XML CONFIG:" + cfg);
         *      }
         *  }
         * </pre>
         *
         * If an asset fails to load the callback function will still be called, only the asset being passed to it will
         * be returned as null and a warning message will be logged looking something like so,
         * <pre>
         *  WARNING #1002: AssetLoader IOError, usually caused by file not found.
         *  Error #2035: URL Not Found. URL: file:///Users/russ/Workspace/AssetLoaderExample/bin-debug/config.xml
         * </pre>
         *
         * <p>You can bulk load a series of assets by sending a series of consecutive loadFile() (or loadClass or similar) calls
         * concluding with a whenDone() call to a callback function.</p>
         *
         * <pre>
         *  AssetLoader.instance.loadFile("config.xml", gotAsset);
         *  AssetLoader.instance.loadFile("myGraphic.jpg", gotAsset);
         *  AssetLoader.instance.loadFile("mySound.mp3", gotAsset);
         *  AssetLoader.instance.whenDone(ready);
         *
         *  private function gotAsset(asset:Object):void {
         *      trace("Asset arrived:" + asset);
         *  }
         *
         *  private function ready(event:Event = null):void {
         *      trace("Your assets have loaded.");
         *  }
         * </pre>
         *
         *
         * <p>Additional agruments can be sent to the loadFile callback to help identify the asset loaded.</p>
         *
         * <p>AssetLoader recognises the following file types:</p>
         *
         * <table>
         * <tr> <th>SUFFIX</th>             <th>CLASS</th>              <th>FILE TYPE</th>  </tr>
         * <tr> <td>".swf"</td>             <td>Sprite/MovieClip</td>   <td>Shockwave Flash</td>    </tr>
         * <tr> <td>".bmp"</td>             <td>Bitmap</td>             <td>Bitmap image file format</td>   </tr>
         * <tr> <td>".png"</td>             <td>Bitmap</td>             <td>Portable Network Graphics</td>  </tr>
         * <tr> <td>".jpg", or ".jpeg"</td> <td>Bitmap</td>             <td>Joint Photographic Experts Group</td>   </tr>
         * <tr> <td>".json"</td>            <td>Object</td>             <td>JavaScript Object Notation</td> </tr>
         * <tr> <td>".aif", or ".aiff"</td> <td>Sound</td>              <td>Audio Interchange File Format</td>  </tr>
         * <tr> <td>".mp3"</td>             <td>Sound</td>              <td>MPEG-1 Audio Layer 3</td>   </tr>
         * <tr> <td>".wav"</td>             <td>Sound</td>              <td>Waveform Audio Format</td>  </tr>
         * <tr> <td>".xml"</td>             <td>XML</td>                <td>Extensible Markup Language</td> </tr>
         * <tr> <td>".plist"</td>           <td>XML</td>                <td>Mac OS X Property list</td> </tr>
         * <tr> <td>".bin"</td>             <td>ByteArray</td>          <td>Binary data</td>    </tr>
         * <tr> <td>".atf"</td>             <td>ByteArray</td>          <td>Adobe Texture Format</td>   </tr>
         * <tr> <td>".txt"</td>             <td>String</td>             <td>Text</td>   </tr>
         * <tr> <td>".html"</td>            <td>String</td>             <td>Hypertext Markup Language</td>  </tr>
         * <tr> <td>".var" or ".vars"</td>  <td>URLVariables</td>       <td>Url variables</td>  </tr>
         * </table>
         *
         *
         * <p>Note: ".swf" files should be typecast as <code>Sprite</code>, if a single frame, or as
         * <code>MovieClip</code>, if multiple frames.</p>
         *
         *
         * <p>If you want to explicity declare the file type use the <code>load()</code> method instead.</p>
         *
         * @param url URL path to asset being loaded. File type is determined by the file extension suffix in the url.
         * Typical file types are .jpg, .mp3, .swf, and .xml.
         * @param callBackFunct Function callback which is passed the loaded asset once load has completed.
         * @return Returns an ILoad loader which can be used to stop the load early using close(), or listened to for
         * events such as ProgressEvent.PROGRESS or AssetLoadedEvent.ASSET_LOADED. Remember to clear
         * any reference you keep to this loader otherwise any assets loaded by it will not clear from memory.
         */
        public function loadFile(url:String,
                                 callBackFunct:Function = null):ILoad
        {
            if (! stringHasValue(url)) 
            {
                Logger.warning("loadFile() received an empty url to load.", WARNING_EMPTY_URL);
                return null;
            }
            
            // determine loader type using file suffix
            var suffix:String = stripCGI(url);
            
            suffix = suffix.slice(suffix.lastIndexOf("."));
            var mLoaderType:String = loaderType(suffix);
            
            if (! mLoaderType) 
            {
                Logger.warning("AssetLoader can't recognize loader type for use loading file with suffix of \"" + suffix + "\" and url \"" + url + "\".\n" +
                    "Deafult image loader being used to load the file.", WARNING_CANT_RECOGNIZE_FILE_TYPE);
                mLoaderType = LOADER_TYPE_IMAGE;
            }

            return load(url, mLoaderType, callBackFunct);
        }
        
        /**
         * <p>Loads external file as a particular file type using an explicit loader.</p>
         * 
         * Possible loader types are:
         * <table>
         * <tr> <th>LOADER TYPE</th>                        <th>SUFFIX</th>         <th>FILE TYPE</th>  </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_SWF</td>        <td>.swf</td>           <td>Shockwave Flash</td>    </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_IMAGE</td>      <td>.bmp</td>           <td>Bitmap image file format</td>   </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_IMAGE</td>      <td>.png</td>           <td>Portable Network Graphics</td>  </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_IMAGE</td>      <td>.jpg, .jpeg</td>    <td>Joint Photographic Experts Group</td>   </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_SOUND</td>      <td>.aif, .aiff</td>    <td>Audio Interchange File Format</td>  </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_SOUND</td>      <td>.mp3</td>           <td>MPEG-1 Audio Layer 3</td>   </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_SOUND</td>      <td>.wav</td>           <td>Waveform Audio Format</td>  </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_XML</td>        <td>.xml</td>           <td>Extensible Markup Language</td> </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_XML</td>        <td>.plist</td>         <td>Mac OS X Property list</td> </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_DATA</td>       <td>.html</td>          <td>Hypertext Markup Language</td>  </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_DATA</td>       <td>.txt, .text</td>    <td>Text (ASCI) data</td>   </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_JSON</td>       <td>.json</td>          <td>JavaScript Object Notation</td> </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_BINARY</td>     <td>.bin</td>           <td>Binary</td> </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_BINARY</td>     <td>.atf</td>           <td>Adobe Texture Format</td> </tr>
         * <tr> <td>AssetLoader.LOADER_TYPE_VARIABLES</td>  <td>.var, .vars</td>    <td>Url variables</td>  </tr>
         * </table>
         *
         * @param url URL path to file being loaded.
         * @param loaderType loader type to use when loading the asset.
         * @param callBackFunct Function callback which is passed the loaded asset once load has completed.
         * @return Returns an ILoad loader which can be used to stop the load early using close(), or listened to for
         * events such as ProgressEvent.PROGRESS or AssetLoadedEvent.ASSET_LOADED. Remember to clear
         * any reference you keep to this loader otherwise any assets loaded by it will not clear from memory.
         */
        public function load(url:String,
                             loaderType:String = LOADER_TYPE_DATA,
                             callBackFunct:Function = null):ILoad
        {
            // use appropriate loader
            var loader:ILoad;
            
            switch (loaderType)
            {
                case LOADER_TYPE_SWF:
                    loader = new LoadSwf(url);
                    break;
                case LOADER_TYPE_IMAGE:
                    loader = new LoadImage(url);
                    break;
                case LOADER_TYPE_SOUND:
                    loader = new LoadSound(url);
                    break;
                case LOADER_TYPE_DATA:
                    loader = new LoadData(url);
                    break;
                case LOADER_TYPE_JSON:
                    loader = new LoadJson(url);
                    break;
                case LOADER_TYPE_XML:
                    loader = new LoadXML(url);
                    break;
                case LOADER_TYPE_BINARY:
                    loader = new LoadBinary(url);
                    break;
                case LOADER_TYPE_VARIABLES:
                    loader = new LoadVariables(url);
                    break;
                
                default:
                    
                    Logger.warning("AssetLoader can't recognize loader type \"" + loaderType + "\" for url " + url + ".\n" +
                        "Deafult LOADER_TYPE_DATA being used to load the file.", WARNING_CANT_RECOGNIZE_LOADER_TYPE);
                    loader = new LoadData(url);
            }
            
            loadUsing(loader, callBackFunct);
            return loader;
        }
        
        /**
         * Uses a specific ILoad object to load a file.
         *
         * @param loader loader being used to load file
         * @param callBackFunct Function callback called when the asset has finished loading.
         */
        public function loadUsing(loader:ILoad,
                                  callBackFunct:Function = null):ILoad
        {
            addAssetLoader(loader);
            
            // listen for asset loaded
            var listener:Function = function(event:AssetLoadedEvent):void 
            {
                loader.removeEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
                deliverAssetEvent(event, callBackFunct);
            };
            loader.addEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
            
            loader.createLoader();
            
            return loader;
        }
        
        /**
         * You may load a Class object out of a specific .swf file
         * and send it to a function once it has loaded using loadClass().
         *
         *  This is achieved like so,
         * <pre>
         *      AssetLoader.instance.loadClass("assest.swf", "ClassName", gotAsset);
         *
         *      private function gotAsset(asset:Object):void {
         *          trace("Asset arrived:" + asset);
         *      }
         * </pre>
         *
         * <p>With loadClass() a new instance of the class object is given to the callback function,
         * if you want the class definition you should use loadClassDefinition().</p>
         *
         *  <p>Note: calls to multiple classes in the same .swf in the same batch will not cause the
         *  .swf to be loaded multiple times, only once.</p>
         *
         * @param url URL path to .swf file being loaded.
         * @param className Name of class being loaded from .swf file.
         * @param callBackFunct Function callback called when the asset has finished loading.
         * @return Returns an ILoad loader which can be used to stop the load early using close(), or listened to for
         * events such as ProgressEvent.PROGRESS or AssetLoadedEvent.ASSET_LOADED. Remember to clear
         * any reference you keep to this loader otherwise any assets loaded by it will not clear from memory.
         */
        public function loadClass(url:String,
                                  className:String,
                                  callBackFunct:Function = null):ILoad
        {
            return classLoad(url, className, false, callBackFunct);
        }
        
        /**
         * Works the same as loadClass() except returns the class definition from the .swf
         * rather than an instance of the class.
         *  Note: calls to multiple classes in the same .swf in the same batch will not cause the
         *  .swf to be loaded multiple times, only once.
         *
         * @param url URL path to .swf file being loaded.
         * @param className Name of class being loaded from .swf file.
         * @param callBackFunct Function callback called when the asset has finished loading.
         * @return Returns an ILoad loader which can be used to stop the load early using close(), or listened to for
         * events such as ProgressEvent.PROGRESS or AssetLoadedEvent.ASSET_LOADED. Remember to clear
         * any reference you keep to this loader otherwise any assets loaded by it will not clear from memory.
         */
        public function loadClassDefinition(url:String,
                                            className:String,
                                            callBackFunct:Function):ILoad
        {
            return classLoad(url, className, true, callBackFunct);
        }
        
        /**
         * A shortcut method that uses getDefinitionByName()
         * to retrieve a new instance of a Class from the application domain.
         *
         * @param className Class name in the application domain.
         * @return Instance of class specified by className.
         */
        public static function getClassInstance(className:String):*
        {
            var mClass:Class = getDefinitionByName(className) as Class;
            return new mClass();
        }
        
        /**
         * Close a file being loaded.
         *
         * To stop an asset from loading call close(), passing it the url path
         * to the asset being loaded.
         *
         * @param url URL path to file to close.
         */
        public function close(url:String):void
        {
            var loader:ILoad = getLoader(url);
            
            if (loader) 
            {
                loader.close();
            }
        }
        
        /**
         * Get a reference to an ILoader loader currently being used to load a file.
         *
         * @param url URL path to file being loaded
         * @param loaderClass can be used to specify a specific ILoad class type of the loader being requested.
         * @return Returns a reference to an in-progress ILoad loader for a file which can be used to stop
         * the load early using close(), or listened to for events such as ProgressEvent.PROGRESS or
         * AssetLoadedEvent.ASSET_LOADED. Remember to clear any reference you keep to this loader otherwise
         * any assets loaded by it will not clear from memory.
         */
        public function getLoader(url:String,
                                  loaderClass:Class = null):ILoad
        {
            // check if url file already in current loading cue...
            url = stripCGI(url);
            
            for each (var loader:ILoad in _loaders) 
            {
                if (url == stripCGI(loader.url)) 
                {
                    // check if it is the right type of loader
                    if (loaderClass) 
                    {
                        if (loader is loaderClass) 
                        {
                            return loader;
                        }
                    } 
                    else 
                    {
                        return loader;
                    }
                }
            }
            return null;
        }
        
        /**
         * <p>Convenience method that sets a function callback to be called
         * when all current loads have finished loading. Multiple consecutive whenDone()
         * callbacks may be set.</p>
         *
         * <p>If the AssetLoader is idle with no loads running when whenDone() is
         * called then the whenDone() function callback will be called on the next frame,
         * when Flash sends a general Event.ENTER_FRAME.</p>
         *
         * <p>whenDone() listens for the BatchCompleteEvent.BATCH_COMPLETE event to be sent
         * from AssetLoader.instance</p>
         *
         * @param callBackFunct Function callback called when batch finished loading.
         */
        public function whenDone(callBackFunct:Function):void
        {
            if (idle) 
            {
                // use Delayer to trigger callback on the next frame
                Delayer.nextFrame(callBackFunct);
            } 
            else 
            {
                // listen for batch complete
                var listener:Function = function(event:BatchCompleteEvent):void 
                {
                    removeEventListener(BatchCompleteEvent.BATCH_COMPLETE, listener);
                    callBackFunct();
                };
                addEventListener(BatchCompleteEvent.BATCH_COMPLETE, listener);
            }
        }
        
        //
        // Methods called by internal loaders, etc
        //
        
        //
        // add a loader to _loaders
        private function addAssetLoader(assetLoader:ILoad):void
        {
            ++_nLoadersTotal;
            
            // keep _loader reference safe from garbage collection
            _loaders[assetLoader] = assetLoader;
            ++_nLoadersRemaining;
        }
        
        /**
         * @private this method is for internal use only.
         * If you need to remove a loader use close().
         *
         * Removes exiting AssetLoader from _loaders queue.
         */
        public function removeAssetLoader(assetLoader:ILoad):void
        {
            assetLoader.dispose();
            
            // and remove loader from _loaders
            _loaders[assetLoader] = null;
            delete _loaders[assetLoader];
            --_nLoadersRemaining;
            
            // if all loaders finished
            if (_nLoadersRemaining == 0) 
            {
                // reset counters
                _nLoadersTotal = 0;
                _percentDone = NaN;
                
                Logger.debug("AssetLoader batch complete.", AssetLoader.DEBUG_BATCH_COMPLETE);
                dispatchEvent(new BatchCompleteEvent(BatchCompleteEvent.BATCH_COMPLETE));
            }
        }
        
        //
        // internal method to deal with
        //  loadClass() and loadClassDefinition()
        private function classLoad(url:String,
                                   className:String,
                                   giveClassDef:Boolean,
                                   callBackFunct:Function):ILoad
        {
            // check if swf file path already in current loading queue...
            var loader:ILoad = getLoader(url, LoadClass);
            var createLoader:Boolean = false;
            
            if (! loader) 
            {
                // verify loader type using file suffix
                var suffix:String = stripCGI(url);
                suffix = suffix.slice(suffix.lastIndexOf("."));
                var mLoaderType:String = loaderType(suffix);
                
                if (mLoaderType != LOADER_TYPE_SWF) 
                {
                    Logger.warning("AssetLoader can't perform loadClass() on url \"" + url + "\" as it isn't a .swf.", WARNING_LOADCLASS_MUST_LOAD_A_SWF);
                    return null;
                }
                
                // otherwise create a new class Loader
                loader = new LoadClass(url);
                addAssetLoader(loader);
                
                createLoader = true;
            }
            
            // listen for asset loaded
            var listener:Function = function(event:AssetLoadedEvent):void 
            {
                loader.removeEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
                deliverClassEvent(event, className, giveClassDef, callBackFunct);
            };
            loader.addEventListener(AssetLoadedEvent.ASSET_LOADED, listener);
            
            if (createLoader) 
            {
                // a fresh loader must call created after listener added
                loader.createLoader();
            }
            
            return loader;
        }
        
        //
        // internal method used to deliver a class by digging
        //  the Class definition out of the .swf
        private function deliverClassEvent(event:AssetLoadedEvent,
                                           className:String,
                                           giveClassDef:Boolean,
                                           callBackFunct:Function):void
        {
            // retrieve Loader from event
            var loader:Loader = event.asset;
            
            // dig the Class definition out of the .swf
            var classDef:Class;
            var asset:*;
            
            if (loader) 
            {
                try 
                {
                    var contentLoaderInfo:LoaderInfo = loader.contentLoaderInfo;
                    var applicationDomain:ApplicationDomain = contentLoaderInfo.applicationDomain;
                    classDef = applicationDomain.getDefinition(className) as Class;
                    
                    // assign asset from class definition
                    asset = giveClassDef ? classDef : new classDef();
                } 
                catch (err:Error) 
                {
                    Logger.warning("AssetLoader could not find Class \"" + className + "\" in file " + event.url + "\n" + err, AssetLoader.WARNING_CLASS_NOT_FOUND);
                }
            }
            
            deliverAsset(asset, event.url, callBackFunct);
        }
        
        //
        // internal methods used to deliver an asset to the function callback
        private function deliverAssetEvent(event:AssetLoadedEvent,
                                           callBackFunct:Function):void
        {
            deliverAsset(event.asset, event.url, callBackFunct);
        }
        
        private function deliverAsset(asset:*,
                                      url:String,
                                      callBackFunct:Function):void
        {
            // if function to deliver to
            if (callBackFunct != null) 
            {
                // trigger function, adding asset to beginning of argument list
                callBackFunct(asset);
            }
        }
        
        /**
         * @private this method is for internal use only.
         *
         * Dispatches update progress of AssetLoader
         */
        public function dispatchProgress(event:Event = null):void
        {
            // round progress to the nearest %,
            //  otherwise we're dispatching too many events
            var mProgress:Number = Number(progress().toPrecision(2));
            
            if (_percentDone != mProgress) 
            {
                _percentDone = mProgress;
                
                if (! isNaN(_percentDone)) 
                {
                    dispatchEvent(new LoaderProgressEvent(LoaderProgressEvent.PROGRESS, _percentDone));
                }
            }
        }
        
        //
        // iterates through active loaders calculating total progress
        private function progress():Number
        {
            // make a local copy of _nLoadersTotal
            var nLoadersTotal:int = _nLoadersTotal;
            
            // determine how much has loaded so far
            var sofar:Number = nLoadersTotal - _nLoadersRemaining;
            
            // iterate through each loader getting percent done
            for each (var loader:ILoad in _loaders) 
            {
                var loaderPercentDone:Number = loader.percentDone;
                
                if (isNaN(loaderPercentDone)) 
                {
                    loaderPercentDone = 0;
                }
                
                if (loader.showProgress) 
                {
                    sofar += loaderPercentDone;
                } 
                else 
                {
                    // ignore this loader's progress
                    --nLoadersTotal;
                }
            }
            
            // special case due to loaders with loader.showProgress = false
            if (nLoadersTotal == 0 ||
                (nLoadersTotal != _nLoadersTotal && sofar == nLoadersTotal)) 
            {
                return NaN;
            }
            
            var percentDone:Number = sofar / nLoadersTotal;
            
            if (percentDone > 1) 
            {
                percentDone = 1;
            }
            
            return percentDone;
        }
        
        //
        // static helper methods
        //
        
        //
        // pass event listeners through to singleton
        public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            instance.removeEventListener(type, listener, useCapture);
        }
        
        public static function dispatchEvent(event:Event):Boolean
        {
            return instance.dispatchEvent(event);
        }
        
        public static function hasEventListener(type:String):Boolean
        {
            return instance.hasEventListener(type);
        }
        
        public static function willTrigger(type:String):Boolean
        {
            return instance.willTrigger(type);
        }
        
        /**
         * Specifies whether the specified string is either non-null, or contains
         * characters (i.e. length is greater that 0)
         *
         * @param string The string which is being checked for a value
         * @return Returns true if the string has a value
         */
        public static function stringHasValue(string:String):Boolean
        {
            return (string != null && string.length > 0);
        }
        
        /**
         * Strips any CGI "?" variables from a url String.
         *
         * @param url URL String being stripped
         * @return Returns the cleaned URL String
         */
        public static function stripCGI(url:String):String
        {
            if (! stringHasValue(url)) 
            {
                Logger.warning("AssetLoader received an empty url.", WARNING_EMPTY_URL);
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
         * Returns the loader type constant when given the file type suffix.
         *
         * @param suffix File suffix such as <code>".jpg"</code> indicating file type.
         * @return Returns AssetLoader constant indicating file type. <code>null</code> returned if suffix not recognized.
         */
        public static function loaderType(suffix:String):String
        {
            suffix = suffix.toLowerCase();
            
            // find appropriate loader from suffix
            switch (suffix) 
            {
                case ".swf":    // Shockwave Flash/Small Web Format
                    return LOADER_TYPE_SWF;
                    
                case ".aif":
                case ".aiff":   // Audio Interchange File Format
                case ".mp3":    // MPEG-1 Audio Layer 3
                case ".wav":    // Waveform audio format
                    return LOADER_TYPE_SOUND;
                    
                case ".bmp":    // Bitmap image file format
                case ".png":    // Portable Network Graphics
                case ".jpg":    // Joint Photographic Experts Group
                case ".jpeg":   
                case ".gif":    // Graphics Interchange Format
                    return LOADER_TYPE_IMAGE;
                    
                case ".html":   // Hypertext Markup Language
                case ".txt":    // Text (ASCI) data
                case ".text":
                    return LOADER_TYPE_DATA;
                    
                case ".json":   // JavaScript Object Notation
                    return LOADER_TYPE_JSON;
                    
                case ".xml":    // Extensible Markup Language
                case ".plist":  // plist xml data
                    return LOADER_TYPE_XML;
                    
                case ".bin":    // Binary
                case ".atf":    // Adobe Texture Format
                    return LOADER_TYPE_BINARY;
                    
                case ".var":
                case ".vars":   // url variables
                    return LOADER_TYPE_VARIABLES;
                    
                default:
                    return null;
            }
        }
        
        //
        // accessors and mutators
        //
        
        /** Gives the percentage loaded of the current batch of loading files, where 1% is returned as 0.01 */
        public function get percentDone():Number
        {
            return _percentDone;
        }
        
        /** Indicates if the AssetLoader is idle with no loads being performed. */
        public function get idle():Boolean
        {
            return (_nLoadersTotal == 0);
        }
        
        /** Gives a reference to the AssetLoader singleton. */
        public static function get instance():AssetLoader
        {
            if (! _instance) 
            {
                _instance = new AssetLoader();
            }
            return _instance;
        }
        
        /**
         * Gets the time after which the AssetLoader retries loading an asset that it's waiting on
         * Note: Individual loaders can have specific timeoutRetry values set on a per loader basis.
         */
        public static function get timeoutRetry():uint
        {
            return _timeoutRetry;
        }
        
        /**
         * Sets the time after which the AssetLoader retries loading assets
         * Note: this can be set on a per loader bases by setting timeoutRetry on the individual loader.
         */
        public static function set timeoutRetry(value:uint):void
        {
            _timeoutRetry = value;
        }
        
        /**
         * Gets the number of retry attemps that the AssetLoader makes on a non-obvious fail.
         */
        public static function get retryAttemps():uint
        {
            return _retryAttemps;
        }
        
        /**
         * Sets the number of retry attemps that the AssetLoader makes on a non-obvious fail.
         */
        public static function set retryAttemps(value:uint):void
        {
            _retryAttemps = value;
        }
    }
}
