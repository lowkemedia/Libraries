package com.lowke.util
{
    import com.lowke.logger.Logger;

    import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class PlotUtil
	{
        public static const LOG_PREFIX:String                                       = "PLT";
        public static const WARNING_MUST_HAVE_STAGE:String                          = "PLT01";
        public static const WARNING_MUST_HAVE_STAGE_FOR_TOP_LEFT:String             = "PLT02";
        public static const WARNING_NEEDS_PARENT:String                             = "PLT03";


		/**
		 * Plots the position of a Sprite on stage.
		 *
		 * @param sprite Sprite being plotted.
		 * @param color Color to draw plot.
		 * @param dotSize Size of dot to use when drawing plot.
		 * @return Returns the plot Shape that was added to the stage.
		 */
		public static function plotPosition(displayObject:DisplayObject,
											color:uint = 0xFF0000,
											dotSize:Number = 4,
                                            giveWarning:Boolean = true):Shape
		{
			var stage:Stage = displayObject.stage;
			if (! stage)
			{
                if (giveWarning)
                {
                    Logger.warning("DisplayObject " + displayObject + " needs to be on the stage to be able to plot it.", WARNING_MUST_HAVE_STAGE);
                }

				return null;
			}

			var location:Point = registrationPoint(displayObject);
			var box:Shape = makeBoxShape(dotSize, dotSize, color);
			box.x = location.x - dotSize/2;
			box.y = location.y - dotSize/2;
			stage.addChild(box);

			return box;
		}


		/**
		 * Plots the rect of a Sprite on stage.
		 *
		 * @param displayObject DisplayObject whose bounds are being drawn.
		 * @param color Color to draw bounding box.
		 * @param lineThickness Line thinkness of bounding box.
		 * @param paddingDX Size increase added to left and right.
		 * @param paddingDY Size increase added to top and bottom.
		 *
		 * @return Returns the bounds Shape that was added to the stage.
		 */
		public static function plotBounds(displayObject:DisplayObject,
										  color:uint = 0xFF0000,
										  lineThickness:Number = 1,
										  paddingDX:Number = 0,
										  paddingDY:Number = 0,
                                          giveWarning:Boolean = true):Shape
		{
			var stage:Stage = displayObject.stage;
			if (! stage)
			{
                if (giveWarning)
                {
                    Logger.warning("DisplayObject " + displayObject + " needs to be on the stage to be able to plot it.", WARNING_MUST_HAVE_STAGE);
                }

				return null;
			}

			var rectangle:Rectangle = displayObject.getBounds(stage);
			rectangle.inflate(paddingDX, paddingDY);
			var box:Shape = makeBoxShape(rectangle.width, rectangle.height, color, lineThickness);
			var topLeft:Point = topLeftPoint(displayObject);
			box.x = topLeft.x;
			box.y = topLeft.y;
			stage.addChild(box);

			return box;
		}


        /**
         * Return the registration Point (global/Stage location) of a DisplayObject
         *
         * @param displayObject DisplayObject whose global position is being sought
         * @return Global location of displayObject as a point
         */
        public static function registrationPoint(displayObject:DisplayObject,
                                                 giveWarning:Boolean = true):Point
        {
            var point:Point = new Point(displayObject.x, displayObject.y);
            if (displayObject.parent)
            {
                point = displayObject.parent.localToGlobal(point);
            }
            else
            {
                if (giveWarning)
                {
                    Logger.warning("DisplayObject " + displayObject + " needs a parent to read its registration position.", WARNING_NEEDS_PARENT);
                }
            }

            return point;
        }


        /**
         * Return the top left Point (global/Stage location) of a DisplayObject
         *
         * @param displayObject DisplayObject whose global position is being sought
         * @return Global top left of displayObject as a point
         */
        public static function topLeftPoint(displayObject:DisplayObject):Point
        {
            var stage:Stage = displayObject.stage;
            if (! stage)
            {
                Logger.warning("DisplayObject " + displayObject + " needs to be on the stage to get its top left Point.", WARNING_MUST_HAVE_STAGE_FOR_TOP_LEFT);

                return null;
            }
            var bounds:Rectangle = displayObject.getBounds(stage);
            var topLeft:Point = stage.localToGlobal(bounds.topLeft);

            return topLeft;
        }


		/**
		 * Creates a rectangle "box" Shape of specific size and color,
		 * where x = 0, y = 0 is the top left of the rectangle.
		 *
		 * @param width Width of the box in pixels.
		 * @param height Height of the box in pixels.
		 * @param color Color of box, e.g. 0xFF0000 is red.
		 * @param lineThickness Thickness of line to be draw, 0 indicates a solid box.
		 * @return Returns the box Shape.
		 */
		public static function makeBoxShape(width:Number,
											height:Number,
											color:uint = 0xFF0000,
											lineThickness:Number = 0):Shape
		{
			var box:Shape = new Shape();

			if (lineThickness)
			{
				// use a line thickness
				box.graphics.lineStyle(lineThickness, color);
			}
			else
			{
				// fill the box
				box.graphics.beginFill(color);
			}

			// draw the box
			box.graphics.drawRect(0, 0, width, height);

			return box;
		}


		/**
		 * Creates a circle Shape of specific radius and color,
		 * where x = 0, y = 0 is the center of the circle.
		 *
		 * @param radius Radius of the circle in pixels.
		 * @param color Color of box, e.g. 0xFF0000 is red.
		 * @param lineThickness Thickness of line to be draw, 0 indicates a solid circle.
		 * @return Returns the circle Shape.
		 */
		public static function makeCircleShape(radius:Number,
											   color:uint = 0xFF0000,
											   lineThickness:Number = 0):Shape
		{
			var circle:Shape = new Shape();

			if (lineThickness)
			{
				// use a line thickness
				circle.graphics.lineStyle(lineThickness, color);
			}
			else
			{
				// fill the circle
				circle.graphics.beginFill(color);
			}

			// draw the box
			circle.graphics.drawCircle(0, 0, radius);

			return circle;
		}


		/**
		 * Creates a polygon Shape of specific size and color,
		 * where x = 0, y = 0 is the center of the polygon.
		 *
		 * @param numberOfSides Number of sides of the polygon (3 = triangle, 4 = diamond, 6 = hexagon, 8 = octagon, etc).
		 * @param length Length of each side of the polygon
		 * @param rotation Rotation of polygon in degrees.
		 * @param color Color of polygon, e.g. 0xFF0000 is red.
		 * @param lineThickness Thickness of polygon line to be draw, 0 indicates a solid polygon.
		 * @return Returns the polygon Shape.
		 */
		public static function makePolygonShape(numberOfSides:uint,
												length:Number,
												rotation:Number = 0,
												color:uint = 0xFF0000,
												lineThickness:Number = 0):Shape
		{
			var polygon:Shape = new Shape();
			var graphics:Graphics = polygon.graphics;

			// require 3 or more sides
			if (numberOfSides < 3)
			{
				throw new Error("Polygon must have at least 3 sides.");
			}

			if (lineThickness)
			{
				// use a line thickness
				graphics.lineStyle(lineThickness, color);
			}
			else
			{
				// fill the polygon
				graphics.beginFill(color);
			}

			var radians:Number = NumberUtil.degreesToRadians(rotation);
			var angle:Number = (2*Math.PI)/numberOfSides;
			var radius:Number = (length/2)/Math.sin(angle/2);
			var x:Number = Math.cos(radians)*radius;
			var y:Number = Math.sin(radians)*radius;

			graphics.moveTo(x, y);

			for (var i:int = 1; i <= numberOfSides; ++i)
			{
				x = (Math.cos((angle*i) + radians)*radius);
				y = (Math.sin((angle*i) + radians)*radius);
				graphics.lineTo(x, y);
			}

			return polygon;
		}


		/**
		 * Creates a "pie" Shape of specific radius and color,
		 * where x = 0, y = 0 is the tip of the pie.
		 *
		 * @param radius Radius of the pie in pixels.
		 * @param arc Arc length in degrees.
		 * @param color Color of pie, e.g. 0xFF0000 is red.
		 * @param lineThickness Thickness of pie line to be draw, 0 indicates a solid pie.
		 * @return Returns the pie Shape.
		 */
		public static function makePieShape(radius:Number,
											arc:Number,
											color:uint = 0xFF0000,
											lineThickness:Number = 0):Shape
		{
			var pie:Shape = new Shape();
			var graphics:Graphics = pie.graphics;

			if (lineThickness)
			{
				// use a line thickness
				graphics.lineStyle(lineThickness, color);
			}
			else
			{
				// fill the polygon
				graphics.beginFill(color);
			}

			var arcRadians:Number = NumberUtil.degreesToRadians(arc);

			var angleDelta:Number = arcRadians/8;
			var dist:Number = radius/Math.cos(angleDelta/2);
			var angle:Number = 0;
			var ctrlX:Number;
			var ctrlY:Number;
			var anchorX:Number;
			var anchorY:Number;
			var startX:Number = Math.cos(0)*radius;
			var startY:Number = Math.sin(0)*radius;

			graphics.lineTo(startX, startY);
			for (var i:int = 0; i < 8; ++i)
			{
				angle += angleDelta;

				ctrlX = Math.cos(angle-(angleDelta/2))*(dist);
				ctrlY = Math.sin(angle-(angleDelta/2))*(dist);

				anchorX = Math.cos(angle)*radius;
				anchorY = Math.sin(angle)*radius;

				graphics.curveTo(ctrlX, ctrlY, anchorX, anchorY);
			}
			graphics.lineTo(0, 0);

			return pie;
		}
	}
}