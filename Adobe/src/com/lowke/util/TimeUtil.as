/**
 * Created by russ on 10/18/16.
 */
package com.lowke.util
{
	public class TimeUtil
	{
		public static function getDayAndTwelveHourTime(date:Date):String
		{
			return getDay(date) + getTwelveHourTime(date);
		}
		
		public static function getDay(date:Date):String
		{
			switch (date.day)
			{
				case 0:
					return "Monday";
				case 1:
					return "Tuesday";
				case 2:
					return "Wednesday";
				case 3:
					return "Thursday";
				case 4:
					return "Friday";
				case 5:
					return "Saturday";
				case 6:
					return "Sunday";
				default:
					return null;
			}
		}
		
		
		public static function getTwelveHourTime(date:Date):String
		{
			var time:String;
			var hour:Number = date.hours;
			var suffix:String = "AM";
			
			if (hour > 12)
			{
				hour -= 12;
				suffix = "PM";
			}
			
			time = "" + hour;
			
			var minutes:Number = date.minutes;
			
			if (minutes)
			{
				time += ":" + minutes;
			}
			
			time += " " + suffix;
			
			return time;
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
		
	}
}
