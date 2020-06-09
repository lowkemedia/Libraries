//
//  GoogleTranslate v 1.0 - assetLoader package
//  Russell Lowke, December 18th 2011
// 
//  Copyright (c) 2011 Lowke Media
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

// LoadGoogleTranslate intended for use with AssetLoader

package com.lowke.googleTranslate
{
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.AssetLoadedEvent;
    import com.lowke.assetLoader.loader.LoadData;
    import com.lowke.logger.Logger;
    
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    
    public class LoadGoogleTranslate extends LoadData
    {
        private static const GOOGLE_TRANSLATE_URL : String = "https://www.googleapis.com/language/translate/v2";
        
        // some common language codes
        //  For a list of standard language codes see http://www.loc.gov/standards/iso639-2/php/code_list.php
        public static const CODE_ENGLISH:String         = "en";
        public static const CODE_PORTUGUESE:String      = "pt";
        public static const CODE_FRENCH:String          = "fr";
        public static const CODE_SPANISH:String         = "es";
        public static const CODE_GERMAN:String          = "de";
        public static const CODE_JAPANESE:String        = "ja";
        public static const CODE_CHINESE:String         = "zh";
        public static const CODE_KOREAN:String          = "ko";
        public static const CODE_RUSSIAN:String         = "ru";
        public static const CODE_DUTCH:String           = "nl";
        public static const CODE_ITALIAN:String         = "it";
        public static const CODE_ARABIC:String          = "ar";
        
        private static var _googleKey:String;           // Google translate is a paid service, you must have a google key 
        // to be able to use google translate,
        //  see https://code.google.com/apis/console to obtain a key
        
        private var _query:String;                      // query string being translated
        private var _targetLanguageCode:String;         // target langauge being translated to
        private var _sourceLanguageCode:String;         // source language being translated from (typically english)
        
        //
        // constructor
        public function LoadGoogleTranslate(query:String, 
                                        targetLanguageCode:String, 
                                        sourceLanguageCode:String = CODE_ENGLISH) 
        {   
            _query = query;
            _sourceLanguageCode = sourceLanguageCode;
            _targetLanguageCode = targetLanguageCode;
            
            _query = stringReplace(_query, '\r', '•');          // convert returns and newline to '•', which will emerge as "% 95"
            _query = stringReplace(_query, '\n', '•');
            
            var url:String = GOOGLE_TRANSLATE_URL + "?";
            url += "key=" + _googleKey;                         // add the key
            url += "&q=" + _query;                              // add the query            // _query = escape(_query);
            url += "&source=" + _sourceLanguageCode;            // add the source language code
            url += "&target=" + _targetLanguageCode;            // add the target language
            
            super(url);
        }
        
        override protected function ioErrorHandler(event:IOErrorEvent):void 
        {    
            if (Object(event).errorID == 2032 || _httpStatus == 400) 
            {
                loadFailed("Google Translate rejected your translation request, probably because of a bad key (key = \""+_googleKey+"\").\n\n" +
                    "Google translate is a paid service, you must set a valid google key to be able to use google translate, " + 
                    "see https://code.google.com/apis/console to obtain a google key.\n", AssetLoader.WARNING_BAD_KEY);
            } 
            else 
            {
                super.ioErrorHandler(event);
            }
        }
        
        override public function fileLoaded(event:Event = null):void 
        {
            Logger.debug("File loaded (" + _id + "): " + _request.url, AssetLoader.DEBUG_FILE_LOADED);
            var jsonString:String = (_loader as URLLoader).data;
            var json:Object = JSON.parse(jsonString);
            var translatedText:String = json["data"]["translations"][0]["translatedText"];
            if (_targetLanguageCode == CODE_CHINESE) 
            {
                // in Chienese the % gets changed to ％ and can be switched around, which is... not helpful.
                translatedText = stringReplace(translatedText, "％92", '’');             // fix ’
                translatedText = stringReplace(translatedText, "％93", '“');             // fix “
                translatedText = stringReplace(translatedText, "％94", '”');             // fix ”
                translatedText = stringReplace(translatedText, "％95", '\r');            // convert '•' back to '\r'
                translatedText = stringReplace(translatedText, "92％", '’');             // fix ’        // THERE'S GOT TO BE A BETTER WAY
                translatedText = stringReplace(translatedText, "93％", '“');             // fix “
                translatedText = stringReplace(translatedText, "94％", '”');             // fix ”
                translatedText = stringReplace(translatedText, "95％", '\r');
            } 
            else 
            {
                translatedText = stringReplace(translatedText, "% 95", '\r');           // convert '•' back to '\r'
                translatedText = stringReplace(translatedText, "% 92", '’');            // fix ’
                translatedText = stringReplace(translatedText, "% 93", '“');            // fix “
                translatedText = stringReplace(translatedText, "% 94", '”');            // fix ”
            }
            
            dispatchEvent(new AssetLoadedEvent(AssetLoadedEvent.ASSET_LOADED, translatedText, _request.url));
            _assetLoader.removeAssetLoader(this);
        }
        
        public static function get googleKey():String                   { return _googleKey; }
        public static function set googleKey(value:String):void         { _googleKey = value; }
        
        
        /**
         * Replaces all instances of the replace string in the input string
         * with the replaceWith string.
         * 
         * @param input Original string
         * @param replace The string that will be replaced
         * @param replaceWith The string that will replace instances of replace
         * @returns A new String with the replace string replaced with replaceWith
         */
        public static function stringReplace(input:String, 
                                             replace:String, 
                                             replaceWith:String):String
        {
            return input.split(replace).join(replaceWith);
        }
    }
}