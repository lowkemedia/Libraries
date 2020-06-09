//
//  FontLoader v 1.0 - font package
//  Russell Lowke, May 22nd 2013
// 
//  Copyright (c) 2010-2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
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

package com.lowke.font
{
	import com.lowke.assetLoader.AssetLoader;
	import com.lowke.font.event.FontsReadyEvent;
    import com.lowke.font.valueObject.FontMapVO;
	import com.lowke.logger.Logger;
	
	import flash.events.EventDispatcher;
	import flash.text.Font;
	
	public class FontLoader extends EventDispatcher
	{	
        //
        // error, warning and info IDs
        public static const LOG_PREFIX:String											= "FNT";
        public static const PRINT_FONT_LOADED:String 									= "FNT00";
        public static const WARNING_FONT_LOADED_DOESNT_MATCH_FONT_REQUESTED:String 		= "FNT01";
        public static const WARNING_EMPTY_FONTMAPDATA_RECEIVED:String 					= "FNT02";
        
        public static const SYSTEM_FONT_TYPEWRITER:String	= "_typewriter";
        public static const SYSTEM_FONT_SERIF:String		= "_serif";
        public static const SYSTEM_FONT_SANS_SERIF:String	= "_sans";
        public static const SYSTEM_FONT_TIMES_ROMAN:String	= "TimesRoman";
        public static const SYSTEM_FONT_ARIAL:String		= "Arial";
        
        private static const BOLD_KEYWORD:String = " Bold";				// keyword used for Bold font
        private static const ITALIC_KEYWORD:String = " Italic";			// keyword used for Italic font
        
        // contant used in key for hashing font, indicates font size
        private static const FONT_SIZE_INDICATOR:String = " size:";
        
        private static var _instance:FontLoader;
        
        // hash of font maps
        private var _fontMapData:Object = new Object();                 // hash of FontMapData objects
        private var _defaultFontName:String = SYSTEM_FONT_SANS_SERIF;	// default font to use if font can't be found
        private var _fontPath:String = "";								// path to fonts folder
        
		private var _failedFonts:Vector.<String>;		// list of fonts that failed to load
		private var _defaultFontPath:String = "";
		private var _laoding:Boolean;
		
		public function FontLoader()
		{   
            if (_instance != null) 
            {
                // show error to prevent new instances of FontLoader being created.
                throw new Error("FontLoader is a singleton, it should never be created twice.\n" +
                                "Use FontLoader.instance to get a reference to FontLoader.");
            }
            _instance = this;
            
			_failedFonts = new Vector.<String>;
		}
		
		
		public function loadFont(fontName:String, assetPath:String = null):void 
		{
			var assetLoader:AssetLoader = AssetLoader.instance;
			
			if (FontLoader.getFont(fontName)) 
            {
				// font already loaded
				assetLoader.whenDone(dispatchFontsReady);
				return;
			}
			
			if (! assetPath) 
            {
				assetPath = _defaultFontPath;
			}
			
			_laoding = true;
			
			// add font mapping data
			var fontMap:FontMapVO = getFontMap(fontName);
			if (! fontMap)
            {
				// if no font map then create a basic one
				var fontTo:String = fontName;
				var baseFontName:String = fontTo.substr(1, fontTo.length - 1);	// strip out the '_'
				createFontMap(baseFontName, 0, fontName, 0, false, false);
			}
			
			assetLoader.loadFile(assetPath + fontName + ".swf", fontLoaded, fontName);
			assetLoader.whenDone(dispatchFontsReady);
		}
		
		
		private function fontLoaded(fontFile:IFont, 
                                    fontName:String):void
		{
			if (! fontFile)
            {
				// font failed to load. An error will already have been given
				_failedFonts.push(fontName);
				return;
			}
			
			if (fontFile.fontName != fontName) 
            {
				Logger.warning("Font loaded \"" + fontFile.fontName + "\" does not match font requested \"" + fontName + "\"",
                    WARNING_FONT_LOADED_DOESNT_MATCH_FONT_REQUESTED);
			}
			
			Logger.print("Font Loaded: \"" + fontFile.fontName + "\"", PRINT_FONT_LOADED);
		}
		
		public function fontFaild(fontName:String):Boolean
		{
			if (_failedFonts.indexOf(fontName) != -1) 
            {
				return true;
			}
			return false;
		}
		
		private function dispatchFontsReady():void
		{
			_laoding = false;
			dispatchEvent(new FontsReadyEvent(FontsReadyEvent.FONTS_READY_EVENT));
		}
        
        /**
         * Given a font name and its font size return mapping data, if any.
         * 
         * @param fontName name of font being searched for
         * @param fontSize size of font being searched for
         * 
         * @return Returns font mapping data
         */
        public function getFontMap(fontName:String,
                                   fontSize:Number = 0):FontMapVO
        {
            fontName = stripFontName(fontName);
            
            // 1st check for fontmap with a specific size
            var key:String = fontKey(fontName, fontSize);
            var fontMapData:FontMapVO = _fontMapData[key];
            if (! fontMapData) 
            {	
                // 2nd check for fontmap without a size
                key = fontKey(fontName);
                fontMapData = _fontMapData[key];
            }
            
            return fontMapData;
        }
        

        /**
         * Create a font map
         */
        public function createFontMap(fontName:String,
                                      fontSize:Number,
                                      fontTo:String,
                                      sizeTo:Number, 
                                      bold:Boolean, 
                                      italic:Boolean):void
        {
            var key:String = fontKey(fontName, fontSize);
            _fontMapData[key] = new FontMapVO(fontName, fontSize, fontTo, sizeTo, bold, italic);
        }
            
        /**
         * "quick fix" way of mapping from one font to another
         */
        public function mapFont(fontFrom:String, fontTo:String):void
        {
            createFontMap(fontFrom, 0, fontTo, 0, false, false);
        }
        
		public function set defaultFontPath(value:String):void
		{
			_defaultFontPath = value;
		}
		
		public function get loading():Boolean
		{
			return _laoding;
		}
        
        public function get defaultFontName():String
        { 
            return _defaultFontName; 
        }
        
        public function set defaultFontName(value:String):void
        { 
            _defaultFontName = value;
        }
		
		public static function get instance():FontLoader 
		{
			if (! _instance) 
            {
				_instance = new FontLoader();
			}
			return _instance;
		}
		
		
		
		//
		// static helper methods
		//

		
		/**
		 * Searches for a registered font by font name and returns that font
		 * 
		 * @param fontName Name of the font being searched for
		 * @param includeDeviceFonts If true then device fonts are included in the search
		 * 
		 * @returns Returns a reference to the registered font
		 * 			If the font is not registered <code>null</code> is returned.
		 */
		public static function getFont(fontName:String, 
									   includeDeviceFonts:Boolean = false):Font
		{
			for each (var font:Font in Font.enumerateFonts(includeDeviceFonts)) 
            {
				if (fontName == font.fontName) 
                {
					return font;	
				}
			}
			return null;
		}
        
        /**
         * @param fontName Font name being stripped of "Bold" and "Italic" keywords
         * 
         * @return Returns the font name with "Bold" and "Italic" keywords removed
         */
        public static function stripFontName(fontName:String):String 
        {	
            if (! fontName) 
            {
                return null;
            }
            
            // not using string.replace() here because it's not Scaleform compliant
            //  as Scaleform does not support Regular Expressions.
            var string:String = fontName;
            
            // in some cases Flash adds bold and italic keywords to the end of the font name
            string = stringReplace(string, ITALIC_KEYWORD, "");			// remove italic
            string = stringReplace(string, BOLD_KEYWORD, "");			// remove bold
            
            string = stringReplace(string, " ", "");					// remove any spaces
            
            return string;
        }
        
        /**
         * generate a key from a fontName and (optionally) its fontSize.
         * 
         * @param fontName Name of font key is being generated for
         * @param fontSize Size of font key is being generated for
         * 
         * @return Key to use for this font and font size
         */
        private static function fontKey(fontName:String, 
                                        fontSize:Number = 0):String
        {
            var key:String = fontName;
            if (fontSize) 
            {
                key += FONT_SIZE_INDICATOR + fontSize;
            }
            
            return key;
        }
        
        public static function isSystemFont(fontName:String):Boolean
        {
            switch (fontName)
            {
                case SYSTEM_FONT_TYPEWRITER:
                case SYSTEM_FONT_SERIF:
                case SYSTEM_FONT_SANS_SERIF:
                case SYSTEM_FONT_TIMES_ROMAN:
                case SYSTEM_FONT_TIMES_ROMAN:
                    return true;
            }
            return false;
        }
        
        
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