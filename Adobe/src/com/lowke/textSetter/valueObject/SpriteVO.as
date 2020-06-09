//
//  SpriteVO v 1.0
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
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * @author Russell Lowke
	 */
	public class SpriteVO
	{
		// dictionary of sprites with oddball scales, used mainly for text reflow
		private static var _sprites:Dictionary = new Dictionary(true);											
		
		private var _x:Number;
		private var _y:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _height:Number;
		private var _spritePadding:Number;
		
		public function SpriteVO(x:Number,
								 y:Number,
								 scaleX:Number,
								 scaleY:Number, 
								 height:Number)
		{
			_x = x;
			_y = y;
			_scaleX = scaleX;
			_scaleY = scaleY;
			_height = height;
		}
		
		public function get x():Number							{ return _x; }
		public function get y():Number							{ return _y; }
		public function get scaleX():Number						{ return _scaleX; }
		public function get scaleY():Number						{ return _scaleY; }
		public function get height():Number						{ return _height; }
		public function get spritePadding():Number				{ return _spritePadding; }
		
		public function set spritePadding(value:Number):void	{ _spritePadding = value; }
		
		public function toString():String 
		{
			return Dump.toString(this);
		}
		
		/**
		 * Keep track of original sprite information, mainly for resizing
		 * 
		 * @param sprite Sprite being stored and/or retrieved
		 * 
		 * @return Returns a SpriteScale object with original sprite scale information
		 */
		public static function spriteDetails(sprite:Sprite, 
											 generateSpriteData:Boolean = true):SpriteVO
		{
			if (! sprite) 
            {
				return null;
			}
			
			// try to retrieve spriteVO
			var spriteDetail:SpriteVO = _sprites[sprite];
			if (! spriteDetail && generateSpriteData) 
            {
				spriteDetail = new SpriteVO(sprite.x, sprite.y, sprite.scaleX, sprite.scaleY, sprite.height);
				_sprites[sprite] = spriteDetail;
			}
			
			return spriteDetail;
		}
	}
}