package com.lowke.util
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;

	public class TintUtil
	{
		
		/**
		 * Convert a 0x000000 colorHex uint into RGB percentiles
		 * 
		 * @param colorHex Color being converted to RGB
		 * @return Returns an object with red green blue percentage values
		 */
		public static function colorHexToRGB(colorHex:uint):Object 
		{
			var r:Number = ((colorHex & 0xFF0000) >> 16)/255;
			var g:Number = ((colorHex & 0xFF00) >> 8)/255;
			var b:Number = (colorHex & 0xFF)/255;
			
			return { r:r, g:g, b:b };
		}
		
		
		/**
		 * Convert RGB percentiles to a 0x000000 colorHex
		 * 
		 * @param r Red percentile
		 * @param g Green percentile
		 * @param b Blue percentile
		 * @return Resultant colorHex
		 */
		public static function RGBtoColorHex(r:Number, g:Number, b:Number):uint 
		{
			var red:uint   = Math.round(r*255);
			var green:uint = Math.round(g*255);
			var blue:uint  = Math.round(b*255);
			return (red << 16) | (green << 8) | blue;
		}
		
		
		/**
		 * Convert a 0x000000 colorHex value to a Flash ColorTransform
		 */
		public static function makeTransformation(colorHex:uint):ColorTransform
		{
			var rgb:Object = colorHexToRGB(colorHex);
			return new ColorTransform(rgb["r"], rgb["g"], rgb["b"]);
		}
		
		
		/**
		 * Convert a Flash ColorTransform to a 0x000000 colorHex value
		 */
		public static function makeColorHex(colorTransform:ColorTransform):uint 
		{
			return RGBtoColorHex(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier);
		}
		
		
		/**
		 * Tint a DisplayObject with a color
		 */
		public static function tint(displayObject:DisplayObject, color:uint):void {
			var colorTransform:ColorTransform = makeTransformation(color);
			var transform:Transform = new Transform(displayObject);
			transform.colorTransform = colorTransform;
		}
		
		
		/**
		 * Tint a DisplayObject using RGB values
		 */
		public static function tintRGB(displayObject:DisplayObject, r:Number, g:Number, b:Number):void 
		{
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.redOffset = r;
			colorTransform.greenOffset = g;
			colorTransform.blueOffset = b;
			var transform:Transform = new Transform(displayObject);
			transform.colorTransform = colorTransform;
		}
		
		
		/**
		 * Highlight a DisplayObject with a brightness
		 * 
		 * @param brightness Should be a value from 0 to 255
		 */
		public static function highlight(displayObject:DisplayObject, brightness:Number):void 
		{
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.redOffset = brightness;
			colorTransform.greenOffset = brightness;
			colorTransform.blueOffset = brightness;
			var transform:Transform = new Transform(displayObject);
			transform.colorTransform = colorTransform;
		}
		
	}
}