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

using System;
using System.Globalization;
using UnityEngine;

public static class UtilsNumber
{
    //
    // Native equivalent: radians * Mathf.Rad2Deg.
    // Convert radians to degrees.
    // degrees = radians*180/PI
    //
    public static float RadiansToDegrees(float radians) {
        // precalculate 180/PI = 57.295779513082289
        return radians * 57.295779513082289f;
    }


    //
    // Native equivalent: degrees * Mathf.Deg2Rad.
    // Convert degrees to radians.
    // radians = degrees*PI/180
    //
    public static float DegreesToRadians(float degrees) {
        // precalculate PI/180 = 0.01745329251994
        return degrees * 0.01745329251994f;
    }

    // Native alternative: value.ToString("D4", CultureInfo.InvariantCulture).
    // D4 pads digits after the sign; this method pads the entire string to n characters.
    public static string PadZerosToNumber(int value, int n)
    {
        string result = "" + value;
        while (result.Length < n) {
            result = '0' + result;
        }

        return result;
    }

    // Native alternative: value.ToString("N0", CultureInfo.InvariantCulture).
    // This legacy method groups the whole string, including any minus sign.
    public static string AddCommasToNumber(int value)
    {
        string intString = "" + value;
        string result = "";

        while (intString.Length > 3) {
            string chunk = intString.Substring(intString.Length - 3);
            intString = intString.Substring(0, intString.Length - 3);
            result = ',' + chunk + result;
        }

        if (intString.Length > 0) {
            result = intString + result;
        }

        return result;
    }

    //
    // Returns an angle in degrees given an x and y velocity.
    // Note: Zero degrees is facing to the right (or "east") of the screen.
    //
    // @param x X velocity.
    // @param y Y velocity.
    //
    // @return Returns an angle in degrees given an x and y velocity.
    //
    // Native alternative: Math.Atan2(y, x) * 180 / Math.PI, then CleanAngle.
    // Returns degrees in [0, 360); zero points right and positive Y points up in Unity.
    // The zero vector has no direction, so it returns NaN.
    public static double XYToAngle(double x, double y)
    {
        if (x == 0 && y == 0) {
            return double.NaN;     // there is no angle without an x or y
        }

        if (x == 0) {                   // avoid error due to divide by zero.
            if (y > 0) {
                return 90;  // positive Y (up in Unity; down in screen coordinates)
            } else {
                return 270; // negative Y (down in Unity; up in screen coordinates)
            }
        } else {                   // quadrants
            double degrees = Math.Atan(y/x)*180/Math.PI;
            if (x > 0) {
                if (degrees < 0) {
                    return 360 + degrees;
                } else {
                    return degrees;
                }
            } else {
                return 180 + degrees;
            }
        }
    }

    //
    // Converts a velocity vector (stored as a Vector2) into an angle
    //
    // @see #XYToAngle()
    //
    // Native alternative: Mathf.Atan2(vector.y, vector.x) * Mathf.Rad2Deg.
    // As with XYToAngle, this wraps negative headings and returns NaN for a zero vector.
    public static double VectorToAngle(Vector2 vector) {
        return XYToAngle(vector.x, vector.y);
    }

    //
    // Return a velocity vector (as a Vector2) when given an angle (in degrees)
    // and (optionally) a velocity.
    //
    // @param degrees Angle of movement, in degrees, where 0 is facing to the right (or "east") of the screen.
    // @param velocity Velocity of movement, defaults to 1.
    //
    // @return Returns a velocity vector (as a Vector2) with resultant x and y velocities
    //
    // Native building blocks: Mathf.Cos/Sin(degrees * Mathf.Deg2Rad).
    // Vector2 replaces ActionScript Point; its components use float precision.
    public static Vector2 AngleToVector(double degrees,
                                        double velocity = 1)
    {
        double radians = degrees*Math.PI/180;
        return new Vector2((float)(Math.Cos(radians)*velocity), (float)(Math.Sin(radians)*velocity));
    }

    //
    // Returns distance between two points, with points expressed as numbers x1, y1, x2, y2.
    //
    // @return Returns distance between two points.
    //
    // Native alternative: Vector2.Distance(new Vector2(x1, y1), new Vector2(x2, y2)).
    // This scalar version retains double precision.
    public static double Distance(double x1,
                                  double y1,
                                  double x2,
                                  double y2)
    {
        return Math.Sqrt(Math.Pow(x2 - x1, 2) + Math.Pow(y2 - y1, 2));
    }

    //
    // Returns distance between two points, with points expressed as Vector2 pt1, pt2.
    //
    // @return Returns distance between two points.
    //
    // Native equivalent: Vector2.Distance(pt1, pt2), with a float result.
    public static double DistanceBtwnPts(Vector2 pt1,
                                         Vector2 pt2)
    {
        return Distance(pt1.x, pt1.y, pt2.x, pt2.y);
    }

    //
    // Rotates a point around (0, 0) by an angle expressed in degrees.
    //
    // @param pt Vector2 being rotated
    // @param angle Angle to be rotated by, in degrees.
    //
    // @return Returns a new rotated Vector2.
    //
    // Native alternative: Quaternion.Euler(0, 0, angle) * new Vector3(pt.x, pt.y, 0).
    // Rotates about the origin; angle is in degrees.
    public static Vector2 Rotate(Vector2 pt,
                                 double angle)
    {
        double theta = angle*Math.PI/180;
        double x = Math.Cos(theta)*pt.x - Math.Sin(theta)*pt.y;
        double y = Math.Sin(theta)*pt.x + Math.Cos(theta)*pt.y;

        return new Vector2((float)x, (float)y);
    }

    //
    // @return Returns y, given x through point with gradient m.
    //
    // No direct slope-based API; Vector2.LerpUnclamped interpolates between endpoints.
    // Returns y on the line through point with the given gradient.
    public static double YOnALine(double x,
                                  Vector2 pt, double m)
    {
        return m*(x - pt.x) + pt.y;
    }

    //
    // @return Returns x, given y through point with gradient m.
    //
    // No direct slope-based API; Vector2.LerpUnclamped is an endpoint-based alternative.
    // Preserves the legacy zero-gradient result of 0; a horizontal line has no unique x.
    public static double XOnALine(double y,
                                  Vector2 pt,
                                  double m)
    {
        if (m == 0) {
            return 0; // avoid divide by zero
        } else {
            return pt.x + (y - pt.y)/m;
        }
    }

    //
    // @return Returns y, given x on a curve through three points
    //
    // No direct equivalent: AnimationCurve.Evaluate uses authored keys and tangents.
    // Evaluates the quadratic through three points, which must have distinct x values.
    public static double YOnACurve(double x, Vector2 ptA, Vector2 ptB, Vector2 ptC)
    {
        double m2 = GradientFromPts(ptA, ptB);
        double m3 = GradientFromPts(ptA, ptC);

        double a = (m2 - m3)/(ptB.x - (double)ptC.x);
        double b = m2 - a*(ptB.x - (double)ptA.x);
        double y = b*(x - ptA.x) + ptA.y + a*Math.Pow((x - ptA.x), 2);

        return y;
    }

    //
    // @return Return gradient (m) from a rise and run. m = rise/run.
    //
    // Native arithmetic: rise / run, after deciding how to handle a vertical line.
    // Preserves the legacy convention: zero rise returns 0; zero run returns rise,
    // not infinity. That vertical-line result is not a mathematical gradient.
    public static double Gradient(double rise, double run)
    {
        if (rise == 0) {
            return 0;
        } else if (run == 0) {
            return rise;  // legacy vertical-line convention, not infinity
        } else {
            return rise/run;
        }
    }

    //
    // @return Returns gradient of a line joining two points.
    //
    // Native arithmetic: (ptB.y - ptA.y) / (ptB.x - ptA.x).
    // Uses Gradient's legacy vertical-line convention.
    public static double GradientFromPts(Vector2 ptA,
                                         Vector2 ptB)
    {
        return Gradient(ptB.y - (double)ptA.y, ptB.x - (double)ptA.x);
    }

    //
    // Returns true if value is within range of other two values.
    //
    // @param value Value being checked if within range of other two parameters.
    // @param valueA First value defining range limit.
    // @param valueB Second value defining range limit.
    //
    // Native equivalent: value >= Math.Min(valueA, valueB) && value <= Math.Max(valueA, valueB).
    // Inclusive endpoints in either order; intended for finite numbers.
    public static bool WithinRange(double value,
                                   double valueA,
                                   double valueB)
    {
        double low;
        double high;
        if (valueA < valueB) {
            low = valueA;
            high = valueB;
        } else {
            low = valueB;
            high = valueA;
        }

        if (value >= low && value <= high) {
            return true;
        } else {
            return false;
        }
    }

    // Native arithmetic: ((angle % 360) + 360) % 360.
    // Wraps degrees into [0, 360), including negative angles.
    public static double CleanAngle(double angle)
    {
        angle %= 360;
        if (angle < 0) {
            return 360 + angle;
        }
        return angle;
    }

    //
    // given a looping sequence in both directions with a range of max
    // if at n which direction (+ or -) is quickest to get to destination
    // Native alternative for angular movement: Mathf.DeltaAngle(current, target).
    // For circular indices, max is the exclusive upper bound; n and destination must be < max.
    // Returns the shortest direction (-1/+1), 0 at the destination, and +1 on a halfway tie.
    public static int IncOrDec(uint n,
                               uint destination,
                               uint max)
    {
        uint inc = 0;
        uint dec = 0;

        if (n == destination) {
            return 0;
        } else {
            if (n < destination) {
                inc = destination - n;
                dec = n + (max - destination);
            } else {
                if (n > destination) {
                    inc = destination + (max - n);
                    dec = n - destination;
                }
            }
        }

        if (inc > dec) {
            return -1;
        } else {
            return +1;
        }
    }

    //
    // Abbreviate number to units of billions, millions, or thousands,
    // as appropriate, trying to keep length of number under four digits.
    //
    // Numbers are returned as a string, are rounded down (toward zero) to one decimal place,
    // and a 'B' (billions), 'M' (millions), or 'K' (thousands) suffix
    // added to indicate units rounded to.
    //
    // @param value Value being abbreviated.
    // @param decimalPlaces Number of decimal places to abbreviate to, default 1.
    // @param round When true numbers are rounded, defaults false.
    // @param dontAbbreviateThousands  When true, thousands (1,000 = 1K) are not abbreviated, but tens of thousands are.
    // @return Rounded value formatted as a string.
    //
    // Native building block: (value / 1000).ToString("0.#", CultureInfo.InvariantCulture) + "K".
    // K/M/B selection is custom policy; thresholds are chosen before rounding.
    // Truncates toward zero by default; dontAbbreviateThousands delays K until 10,000.
    public static string AbbreviateNumber(double value,
                                          uint decimalPlaces = 1,
                                          bool round = false,
                                          bool dontAbbreviateThousands = false)
    {
        const int THOUSANDS = 1000;          // ten hundred (10^3) is a thousand
        const int TENS_OF_THOUSANDS = 10000; // ten thousand (10^4)
        const int MILLIONS = 1000000;        // thousand thousand (10^6)
        const int BILLIONS = 1000000000;     // thousand million (10^9) is a billion

        // ignore +ive or -ive
        string suffix = "";
        double absValue = Math.Abs(value);
        if (!double.IsInfinity(value)) {
            if (absValue >= BILLIONS) {
                suffix = "B";
                value /= BILLIONS;
            } else if (absValue >= MILLIONS) {
                suffix = "M";
                value /= MILLIONS;
            } else if ((absValue >= THOUSANDS && !dontAbbreviateThousands) ||
                     absValue >= TENS_OF_THOUSANDS) {
                suffix = "K";
                value /= THOUSANDS;
            }
        }

        return FormatNumber(value, decimalPlaces, round) + suffix;
    }

    // Native alternative: value.ToString("N2", CultureInfo.InvariantCulture).
    // Unlike N2, this truncates by default and omits trailing fractional zeros.
    // Uses '.' for decimals and a custom group separator (null/empty means comma).
    // This is invariant formatting, not localized display text; decimalPlaces is 0..15.
    public static string FormatNumber(double value,
                                      uint decimalPlaces = 0,
                                      bool round = false,
                                      string separator = null)
    {
        // set to number of decimal places
        value = ToDecimalPrecision(value, decimalPlaces, round);
        if (double.IsNaN(value) || double.IsInfinity(value)) {
            return value.ToString(CultureInfo.InvariantCulture);
        }
        if (string.IsNullOrEmpty(separator)) {
            separator = ",";
        }

        // save sign if negative
        string sign = "";
        if (value < 0) {
            sign = "-";
        }

        // save any decimal places
        string number = Math.Abs(value).ToString("F" + decimalPlaces, CultureInfo.InvariantCulture);
        string decimals = "";
        int decimalIndex = number.IndexOf('.');
        if (decimalIndex != -1) {
            decimals = number.Substring(decimalIndex).TrimEnd('0').TrimEnd('.');
            number = number.Substring(0, decimalIndex);
        }

        // add number separators
        string result = "";
        while (number.Length > 3) {
            string chunk = number.Substring(number.Length - 3);
            number = number.Substring(0, number.Length - 3);
            result = separator + chunk + result;
        }

        // put sign, remaining digits, and decimals back
        return sign + number + result + decimals;
    }

    // Native alternatives: Math.Round(value, places, MidpointRounding.AwayFromZero),
    // or Math.Truncate(value * units) / units. Binary floating-point can affect decimal ties.
    // Keeps the original sign/scale/round-or-truncate approach; decimalPlaces is 0..15.
    public static double ToDecimalPrecision(double value,
                                            uint decimalPlaces,
                                            bool round = false)
    {
        if (decimalPlaces > 15) {
            throw new ArgumentOutOfRangeException(nameof(decimalPlaces), "Use 0 to 15 decimal places.");
        }
        if (double.IsNaN(value) || double.IsInfinity(value)) {
            return value;
        }

        double sign = value < 0 ? -1 : +1;
        double units = Math.Pow(10, decimalPlaces);
        double scaledValue = Math.Abs(value) * units;
        if (double.IsInfinity(scaledValue)) {
            return value; // Scaling overflowed; fractional precision cannot change this magnitude.
        }
        if (round) {
            scaledValue = Math.Round(scaledValue, MidpointRounding.AwayFromZero);
        } else {
            scaledValue = Math.Floor(scaledValue);
        }
        return scaledValue / units * sign;
    }

    // Native alternative: TimeSpan.FromMilliseconds(milliseconds).TotalSeconds/Minutes/Hours/Days.
    // Unit selection is custom: keeps inclusive 60-second, 60-minute, 24-hour and 30-day limits.
    // Negative time becomes zero; months approximate 30 days and labels remain English.
    // Intended for finite input. The typed result replaces the ActionScript anonymous object.
    public static TimeRemaining ConvertMillisecondsToTimeRemaining(double milliseconds)
    {
        // ignore negative time remaining
        if (milliseconds < 0) {
            milliseconds = 0;
        }

        // convert to seconds remaining
        double seconds = Math.Floor(milliseconds / 1000);
        if (seconds <= 60) {
            return new TimeRemaining(seconds, seconds == 1 ? "second" : "seconds");
        }

        // convert to minutes remaining
        double minutes = Math.Floor(seconds / 60);
        if (minutes <= 60) {
            return new TimeRemaining(minutes, minutes == 1 ? "minute" : "minutes");
        }

        // convert to hours remaining
        double hours = Math.Floor(minutes / 60);
        if (hours <= 24) {
            return new TimeRemaining(hours, hours == 1 ? "hour" : "hours");
        }

        // convert to days remaining
        double days = Math.Floor(hours / 24);
        if (days <= 30) {
            return new TimeRemaining(days, days == 1 ? "day" : "days");
        }

        // convert to (approx.) months remaining
        double months = Math.Floor(days / 30);
        return new TimeRemaining(months, months == 1 ? "month" : "months");
    }

    public readonly struct TimeRemaining
    {
        public double Duration { get; }
        public string DurationUnits { get; }

        public TimeRemaining(double duration, string durationUnits) {
            Duration = duration;
            DurationUnits = durationUnits;
        }
    }
}