//
//  FieldData v 1.0
//  Russell Lowke, May 22nd 2013
//
//  Copyright (c) 2013 Lowke Media
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

package com.lowke.textSetter.valueObject
{
	import com.lowke.Dump;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	/**
	 * @author Russell Lowke
	 */
	public class FieldVO
	{
		// dictionary of field information for localization. Weak keys are used 
		private static var _fieldDetails:Dictionary = new Dictionary(true);					
		
		private var _textFormat:TextFormat;
		private var _fontName:String;
		private var _fontSize:Number;
		private var _fontColor:uint;
		private var _text:String;
		private var _align:String;
		private var _bold:Boolean;
		private var _italic:Boolean;
		private var _width:Number;
		private var _height:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _x:Number;
		private var _y:Number;
		
		public function FieldVO(field:TextField)
		{
			_text = field.text;

			if (! stringHasValue(_text)) 
            {
				// ensure the field isn't empty so getTextFormat can get font name and size
				field.text = " ";
			}
			
			_textFormat = field.getTextFormat(_text.length ? 0 : -1);
			field.defaultTextFormat = _textFormat;
			
			_fontName = _textFormat.font;
			_fontSize = _textFormat.size as Number;
			_fontColor = _textFormat.color as uint;
            
			if (! _textFormat.align) 
            {		
				// deafult to align left if not set
				_textFormat.align = TextFormatAlign.LEFT;
			}
            
			_align = _textFormat.align;
			_bold = _textFormat.bold;
			_italic = _textFormat.italic;
			_width = field.width;
			_height = field.height;
			_scaleX = field.scaleX;
			_scaleY = field.scaleY;
			_x = field.x;
			_y = field.y;
			
			// Changing the text format to use a new
			// font shifts the field position down 1 pixel
			// for some reason, need to compensate 
			// for this.
			_y -= 1;
			
		}
		
		public function get textFormat():TextFormat			{ return _textFormat; }
		public function get fontName():String				{ return _fontName; }
		public function get fontSize():Number				{ return _fontSize; }
		public function get fontColor():uint				{ return _fontColor; }
		public function get text():String					{ return _text; }
		public function get align():String					{ return _align; }
		public function get bold():Boolean					{ return _bold; }
		public function get italic():Boolean				{ return _italic; }
		public function get width():Number					{ return _width; }
		public function get height():Number					{ return _height; }
		public function get scaleX():Number					{ return _scaleX; }
		public function get scaleY():Number					{ return _scaleY; }
		public function get x():Number						{ return _x; }
		public function get y():Number						{ return _y; }
		
		public function toString():String 
		{
			return Dump.toString(this);
		}
		
		
		/** 
		 * Keep track of original field information.
		 * Given a TextField returns a FieldDetail object
		 * 
		 * @param field TextField that original field detail is being requested for.
		 * @param generateFieldVO If true a FieldVO is generated to track the field.
		 * 
		 * @return Value Object containing detail about the field
		 */
		public static function fieldDetails(field:TextField, 
											generateFieldVO:Boolean = true):FieldVO
		{
			if (! field) 
            {
				return null;
			}
			
			var fieldDetail:FieldVO = _fieldDetails[field];
			
			if (! fieldDetail && generateFieldVO) 
            {
				fieldDetail = new FieldVO(field);
				_fieldDetails[field] = fieldDetail;
			}
			
			return fieldDetail;
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
	}
}