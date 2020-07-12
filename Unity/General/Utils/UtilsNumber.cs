//
//  UtilsNumber - Utils package
//  Russell Lowke, July 7th 2019
//
//  Copyright (c) 2014-2020 Lowke Media
//  see https://github.com/lowkemedia/Libraries for more information
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

public static class UtilsNumber
{

    //
    // Convert radians to degrees.
    // degrees = radians*180/PI
    //
    public static float RadiansToDegrees(float radians)
    {
        // precalculate 180/PI = 57.295779513082289
        return radians * 57.295779513082289f;
    }


    //
    // Convert degrees to radians.
    // radians = degrees*PI/180
    //
    public static float DegreesToRadians(float degrees)
    {
        // precalculate PI/180 = 0.01745329251994
        return degrees * 0.01745329251994f;
    }



    /*
        //
        // Returns an angle in degrees given an x and y velocity.
        // Note: Zero degrees is facing to the right (or "east") of the screen.
        //
        // @param x X velocity.
        // @param y Y velocity.
        //
        // @return Returns an angle in degrees an x and y velocity.
        ///
        public static function XYToAngle(x:Number, y:Number):Number
        {
            if (x == 0 && y == 0)
            {
                return NaN;     // there is no angle without an x or y
            }

            if (x == 0)
            {                   // avoid error due to divide by zero.
                if (y > 0)
                {
                    return 90;  //  down
                }
                else
                {
                    return 270;  //  up
                }
            }
            else
            {                    // quadrants
                var degrees:Number = radiansToDegrees(Math.atan(y/x));
                if (x > 0)
                {
                    if (degrees < 0)
                    {
                        return 360 + degrees;
                    }
                    else
                    {
                        return degrees;
                    }
                }
                else
                {
                    return 180 + degrees;
                }
            }
        }

        //
        // Converts a velocity vector (stored as a Point) into an angle
        //
        // @see #XYToAngle()
        ///
        public static function vectorToAngle(vector:Point):Number
        {
            return XYToAngle(vector.x, vector.y);
        }

        //
        // Return a velocity vector (as a Point) when given an angle (in degrees)
        // and (optionally) a velocity.
        //
        // @param degrees Angle of movement, in degrees, where 0 is facing to the right (or "east") of the screen.
        // @param velocity Velocity of movement, defaukts to 1.
        //
        // @return Returns a velocity vector (as a Point) with resultant x and y velocities
        ///
        public static function angleToVector(degrees:Number,
                                             velocity:Number = 1):Point
        {
            var radians:Number = degreesToRadians(degrees);
            return new Point(Math.cos(radians)*velocity, Math.sin(radians)*velocity);
        }

        //
        // Returns distance between two points, with points expressed as Numbers x1, y1, x2, y2.
        //
        // @return Returns distance between two points.
        ///
        public static function distance(x1:Number,
                                        y1:Number,
                                        x2:Number,
                                        y2:Number):Number
        {
            return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
        }

        //
        // Returns distance between two points, with points expressed as Point pt1, pt2.
        //
        // @return Returns distance between two points.
        ///
        public static function distanceBtwnPts(pt1:Point,
                                               pt2:Point):Number
        {
            return distance(pt1.x, pt1.y, pt2.x, pt2.y);
        }


        //
        // Rotates a point around (0, 0) by an angle expressed in degrees.
        //
        // @param pt Point being rotated
        // @param angle Angle to be rotated by, in degrees.
        //
        // @return Returns a new rotated Point.
        ///
        public static function rotate(pt:Point,
                                      angle:Number):Point
        {
            var theta:Number = degreesToRadians(angle);
            var x:Number = Math.cos(theta)*pt.x - Math.sin(theta)*pt.y;
            var y:Number = Math.sin(theta)*pt.x + Math.cos(theta)*pt.y;

            return new Point(x, y);
        }


        //
        // @return Returns y, given x through point with gradient m.
        ///
        public static function yOnALine(x:Number,
                                        pt:Point, m:Number):Number
        {
            return m*(x - pt.x) + pt.y;
        }


        //
        // @return Returns x, given y through point with gradient m.
        ///
        public static function xOnALine(y:Number,
                                        pt:Point,
                                        m:Number):Number
        {
            if (m == 0)
            {
                return 0; // avoid divide by zero
            }
            else
            {
                return pt.x + (y - pt.y)/m;
            }
        }


        //
        // @return Returns y, given x on a curve through three points
        ///
        public static function yOnACurve(x:Number, ptA:Point, ptB:Point, ptC:Point):Number
        {
            var m2:Number = gradientFromPts(ptA, ptB);
            var m3:Number = gradientFromPts(ptA, ptC);

            var a:Number = (m2 - m3)/(ptB.x - ptC.x);
            var b:Number = m2 - a*(ptB.x - ptA.x);
            var y:Number = b*(x - ptA.x) + ptA.y + a*Math.pow((x - ptA.x), 2);

            return y;
        }


        //
        // @return Return gradient (m) from a rise and run. m = rise/run.
        ///
        public static function gradient(rise:Number, run:Number):Number
        {
            if (rise == 0)
            {
                return 0;
            }
            else if (run == 0)
            {
                return rise;  // infinity
            }
            else
            {
                return rise/run;
            }
        }


        //
        // @return Returns gradient of a line joining two points.
        ///
        public static function gradientFromPts(ptA:Point,
                                               ptB:Point):Number
        {
            return gradient(ptB.y - ptA.y, ptB.x - ptA.x);
        }

        //
        // Returns true if value with range of other two values.
        //
        // @param value Value being checked if within range of other tqo parameters.
        // @param valueA First value defining range limit.
        // @param valueB Second value defining range limit.
        ///
        private static function withinRange(value:Number,
                                            valueA:Number,
                                            valueB:Number):Boolean
        {
            var low:Number;
            var high:Number;
            if (valueA < valueB)
            {
                low = valueA;
                high = valueB;
            }
            else
            {
                low = valueB;
                high = valueA;
            }

            if (value < low)
            {
                return false;
            }
            else if (value > high)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        
        public static function cleanAngle(angle:Number):Number
        {
            angle %= 360;
            if (angle < 0)
            {
                return 360 + angle;
            }
            return angle;
        }
        
        //
        // given a looping sequence in both directions with a range of max
        // if at n which direction (+ or -) is quickest to get to dest
        public static function incOrDec(n:uint,
                                        dest:uint,
                                        max:uint):int
        {
            // ensure integers
            
            var inc:int = 0;
            var dec:int = 0;
    
            if (n == dest)
            {
                return 0;
            }
            else
            {
                if (n < dest)
                {
                    inc = dest - n;
                    dec = n + (
                        max - dest);
                }
                else
                {
                    if (n > dest)
                    {
                        inc = dest + (
                            max - n);
                        dec = n - dest;
                    }
                }
            }
    
            if (inc > dec)
            {
                return -1;
            }
            else
            {
                return +1;
            }
        }
        
        //
        // Abbreviate number to units of billions, millions, or thousands,
        // as appropriate, trying to keep length of number under four digits.
        //
        // Numbers are returned as a String, are rounded//down* to one decimal place,
        // and a 'B' (billions), 'M' (millions), or 'K' (thousands) suffix
        // added to indicate units rounded to.
        //
        // @param value Value being abbreviated.
        // @param decemalPlaces Number of decimal places to abbreviate to, default 1.
        // @param fRound When true numbers are rounded, defaults false.
        // @param fDontAbbrieviateThousands  When true, thousands (1,000 = 1K) are not abbreviated, but tens of thousands are.
        // @return Rounded value formatted as a string.
        ///
        public static function abbreviateNumber(value:Number,
                                                decemalPlaces:uint = 1,
                                                fRound:Boolean = false,
                                                fDontAbbrieviateThousands:Boolean = false):String
        {
            const THOUSANDS:int 		= Math.pow(10, 3);  // ten hundred (10^3) is a thousand
            const TENS_OF_THOUSANDS:int = Math.pow(10, 4);	// ten thousand (10^4)
            const MILLIONS:int 			= Math.pow(10, 6);	// thousand thousand (10^6) is a million
            const BILLIONS:int 			= Math.pow(10, 9);	// thousand million (10^9) is a billion

            // ignore +ive or -ive
            var stSuffix:String = "";
            var absValue:Number = Math.abs(value);
            if (absValue >= BILLIONS)
            {
                stSuffix = "B";
                value /= BILLIONS;
            }
            else if (absValue >= MILLIONS)
            {
                stSuffix = "M";
                value /= MILLIONS;
            }
            else if ((absValue >= THOUSANDS && ! fDontAbbrieviateThousands) ||
                    absValue >= TENS_OF_THOUSANDS)
            {
                stSuffix = "K";
                value /= THOUSANDS;
            }

            return formatNumber(value, decemalPlaces, fRound) + stSuffix;
        }

        public static function formatNumber(value:Number,
                                            decimalPlaces:uint = 0,
                                            fRound:Boolean = false,
                                            separator:String = null):String
        {
            const NUMBER_SEPARATOR:String = ',';
            const DECIMAL_POINT:String = '.';

            if (! separator)
            {
                separator = NUMBER_SEPARATOR;
            }

            if (isNaN(value))
            {
                return "NaN";
            }

            // set to number of decimal places
            value = toDecimalPrecision(value, decimalPlaces, fRound);

            // save sign if negative
            var stSign:String = "";
            if (value < 0)
            {
                stSign = "-";
                value = Math.abs(value);
            }

            // save any decimal places
            var stDecimals:String = "";
            var stNumber:String = "" + value;
            var iDecimal:int = stNumber.indexOf(DECIMAL_POINT);
            if (iDecimal != -1)
            {
                stDecimals = stNumber.substr(iDecimal);
                stNumber = "" + Math.floor(value);
            }

            // add number separators
            var stReturn:String = "";
            while (stNumber.length > 3)
            {
                var chunk:String = stNumber.substr(-3);
                stNumber = stNumber.substr(0, stNumber.length - 3);
                stReturn = separator + chunk + stReturn;
            }

            // put sign, remaining digits, and decimals back
            stReturn = stSign + stNumber + stReturn + stDecimals;

            return stReturn;
        }

        public static function toDecimalPrecision(value:Number,
                                                  decemalPlaces:uint,
                                                  fRound:Boolean = false):Number
        {
            var sign:Number = (value < 0) ? -1 : +1;
            value = Math.abs(value);
            var units:Number = Math.pow(10, decemalPlaces);
            if (fRound)
            {
                value =  Math.round(value// units);
            }
            else
            {
                value =  Math.floor(value// units);
            }
            value = value/units*sign;

            return value;
        }
    
        public static function addCommasToNumber(number:Number):String
        {
            var numString:String = "" + number;
            var result:String = '';

            while (numString.length > 3)
            {
                var chunk:String = numString.substr(-3);
                numString = numString.substr(0, numString.length - 3);
                result = ',' + chunk + result
            }

            if (numString.length > 0)
            {
                result = numString + result;
            }

            return result
        }


        public static function convertMillisecondsToTimeRemaining(milliseconds:Number):Object
		{
			// ignore negative time remaining
			if (milliseconds < 0)
			{
				milliseconds = 0;
			}
			
			// convert to seconds remaining
			var seconds:Number = Math.floor(milliseconds / 1000);
			
			if (seconds <= 60)
			{
				return {dDuration: seconds,
					stDurationUnits: (
					seconds == 1) ? "second" : "seconds"
				};
			}
			
			// convert to minutes remaining
			var minutes:Number = Math.floor(seconds / 60);
			if (minutes <= 60)
			{
				return {dDuration: minutes,
					stDurationUnits: (
					minutes == 1) ? "minute" : "minutes"
				};
			}
			
			// convert to hours remaining
			var hours:Number = Math.floor(minutes / 60);
			if (hours <= 24)
			{
				return {dDuration: hours,
					stDurationUnits: (
					hours == 1) ? "hour" : "hours"
				};
			}
			
			// convert to days remaining
			var days:Number = Math.floor(hours / 24);
			if (days <= 30)
			{
				return {dDuration: days,
					stDurationUnits: (
					days == 1) ? "day" : "days"
				};
			}
			
			// convert to (approx.) months remaining
			var months:Number = Math.floor(days / 30);
			return {dDuration: months,
				stDurationUnits: (
				months == 1) ? "month" : "months"
			};
		}
    */
}