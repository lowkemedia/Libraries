//
//  _SampleFont v 1.0 - font package
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

package com.lowke.font.fontPackaging
{
    import flash.display.Sprite;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import com.lowke.font.IFont;

    public class _SampleFont extends Sprite implements IFont
    {
        // Unicode range generators can be found at
        // http://inspiritgames.com/blog/2010/09/unicode-range-generator-for-as3/ or
        // http://zenoplex.jp/tools/unicoderange_generator.html
        
        private static const FONT_NAME:String = "_SampleFont";
        
        // [Embed(source="fontFolder/Georgia/Georgia.ttf", fontFamily = "_Georgia", embedAsCFF="false", unicodeRange = "U+0020-007E,U+00A1-00FF,U+0400-04CE,U+2000-206F,U+20A0-20CF,U+2100-2183")]
        public var fontPlain:Class;

        // [Embed(source="fontFolder/Georgia/Georgia-Bold.ttf", fontFamily = "_Georgia", fontWeight="bold", embedAsCFF="false", unicodeRange = "U+0020-007E,U+00A1-00FF,U+0400-04CE,U+2000-206F,U+20A0-20CF,U+2100-2183")]
        public var fontBold:Class;

        // [Embed(source="fontFolder/Georgia/Georgia-Italic.ttf", fontFamily = "_Georgia", fontStyle="italic", embedAsCFF="false", unicodeRange = "U+0020-007E,U+00A1-00FF,U+0400-04CE,U+2000-206F,U+20A0-20CF,U+2100-2183")]
        public var fontItalic:Class;

        // [Embed(source="fontFolder/Georgia/Georgia-BoldItalic.ttf", fontFamily = "_Georgia", fontWeight="bold", fontStyle="italic", embedAsCFF="false", unicodeRange = "U+0020-007E,U+00A1-00FF,U+0400-04CE,U+2000-206F,U+20A0-20CF,U+2100-2183")]
        public var fontBoldItalic:Class;

        public function _SampleFont()
        {
            Font.registerFont(fontPlain);
            Font.registerFont(fontBold);
            Font.registerFont(fontItalic);
            Font.registerFont(fontBoldItalic);

            var textField:TextField = new TextField();
            textField.embedFonts = true;
            textField.text = "The quick brown fox jumped over the lazy dog.";
            textField.autoSize = TextFieldAutoSize.LEFT;
            textField.setTextFormat(new TextFormat(FONT_NAME, 18));
            addChild(textField);
        }

        public function get fontName():String
        {
            return FONT_NAME;
        }

		public function get hasBold():Boolean
		{
			return true;
		}
		
		public function get hasItalic():Boolean
		{
			return true;
		}
    }
}


