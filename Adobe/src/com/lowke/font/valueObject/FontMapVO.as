//
//  FontMapVO v 1.0 - font package
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

package com.lowke.font.valueObject
{
	/**
	 * @author Russell Lowke
	 */
	public class FontMapVO
	{
		private var _fontName:String;
		private var _fontSize:Number;
		private var _fontTo:String;
		private var _sizeTo:Number;
		private var _bold:Boolean = true;
		private var _italic:Boolean = true;
		
		public function FontMapVO(fontName:String,
								fontSize:Number,
								fontTo:String, 
								sizeTo:Number,
								bold:Boolean,
								italic:Boolean)
		{
			_fontName = fontName;
			_fontSize = fontSize;
			_fontTo = fontTo;
			_sizeTo = sizeTo;
			_bold = bold;
			_italic = italic;
		}
		
		public function get fontName():String			{ return _fontName; }
		public function get fontSize():Number			{ return _fontSize; }
		public function get fontTo():String				{ return _fontTo; }
		public function get sizeTo():Number				{ return _sizeTo; }
		public function get bold():Boolean				{ return _bold; }
		public function get italic():Boolean			{ return _italic; }
	}
}