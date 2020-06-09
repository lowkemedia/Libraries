//
//  Dump v 1.2
//  Russell Lowke, June 23rd 2014
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

package com.lowke
{
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;


    public class Dump
    {
        public static const NULL:String = "null";
        private static const READWRITE:String = "readwrite";
        private static const READONLY:String = "readonly";
        private static const ACCESSOR:String = "accessor";
        private static const VARIABLE:String = "variable";

		/**
		 * Dump v 1.2
		 * Russell Lowke,  June 23rd 2014
		 *
		 * Very useful method to convert Arrays, Vectors, dynamic Objects, Classes, whatever, to readable Strings.
		 * Reflection is used to recursively inspect instances of all exposed readable values.
		 *
		 * Usage:
		 *      Dump.toString(yourInstance);
		 *
		 * @param value Value or instance being converted to a String.
		 * @param stripEmptyValues If true all empty values are omitted.
		 * @param ignoreCustomToStrings If true any customToStrings are ignored and reflection used instead.
		 * @param delimiter Delimiter used between each listed item.
		 * @return com.lowke.Dump of the contents of the instance as String.
		 */
		public static function toString(value:*,
										stripEmptyValues:Boolean = false,
										ignoreCustomToStrings:Boolean = false,
										delimiter:String = ", "):String
		{
			if (! value)
			{
				return NULL;
			}
			
			var string:String = "";
			if (value is String) 
			{
				string += "\"" + value + "\"";
			}
			else if (isPrimitiveType(value)) 
			{
				string += value;
			}
			else if (value is Array) 
			{
				string += dumpArray(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			else if (isVector(value)) 
			{
				string += dumpVector(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			else if (isDynamicObject(value)) 
			{
				string += dumpObject(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			else
			{
				string += dumpClass(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			
			return string;
		}
		
		/**
		 * Returns a string with a dump of the comtents of a dynamic Object.
		 *
		 * @param object Object being inspected
		 * @param stripEmptyValues If true any empty values are omitted.
		 * @param ignoreCustomToStrings If true any customToStrings are ignored and reflection used instead.
		 * @param delimiter Delimiter used between each listed item.
		 * @return com.lowke.Dump of the contents of the Object as String.
		 */
		public static function dumpObject(object:Object,
										  stripEmptyValues:Boolean = false,
										  ignoreCustomToStrings:Boolean = false,
										  delimiter:String = ", \n"):String
		{
			if (! object)
			{
				return NULL;
			}
			
			var string:String = "{ ";
			for (var key:String in object) 
			{
				var value:* = object[key];
				if (stripEmptyValues && valueIsEmpty(value))
				{
					continue;
				}
				
				if (string != "{ ") 
				{
					string += delimiter;
				}
				string += key + ":" + toString(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			string += " }";
			
			return string;
		}
		
		/**
		 * Returns a string with a dump of the comtents of an Array.
		 * 
		 * @param array Array being inspected
		 * @param stripEmptyValues If true any empty values are omitted.
		 * @param ignoreCustomToStrings If true any customToStrings are ignored and reflection used instead.
		 * @param delimiter Delimiter used between each listed item.
		 * @return com.lowke.Dump of the contents of the Array as String.
		 */
		public static function dumpArray(array:Array,
										 stripEmptyValues:Boolean = false,
										 ignoreCustomToStrings:Boolean = false,
										 delimiter:String = ", "):String
		{
			if (! array)
			{
				return "null";
			}
			
			var string:String = "[ ";
			
			for each (var value:* in array) 
			{
				if (stripEmptyValues && valueIsEmpty(value))
				{
					continue;
				}
				
				if (string != "[ ") 
				{
					string += ", ";
				}
				string += toString(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			string += " ]";
			
			return string;
		}
		
		
		/**
		 * Returns a string with a dump of the comtents of a Vector.
		 * 
		 * @param instance Vector being inspected
		 * @param stripEmptyValues If true any empty values are omitted.
		 * @param ignoreCustomToStrings If true any customToStrings are ignored and reflection used instead.
		 * @param delimiter Delimiter used between each listed item.
		 * @return com.lowke.Dump of the contents of the Vector as String.
		 */
		public static function dumpVector(instance:*,
										  stripEmptyValues:Boolean = false,
										  ignoreCustomToStrings:Boolean = false,
										  delimiter:String = ", "):String
		{
			if (! instance)
			{
				return "null";
			}
			
			if (! isVector(instance))
			{
				throw new Error("Can't dumpVector() as instance passed is not a Vector.");
			}
			
			var string:String = "[ ";
			
			for each (var value:* in instance) 
			{
				if (stripEmptyValues && valueIsEmpty(value))
				{
					continue;
				}
				
				if (string != "[ ") 
				{
					string += ", ";
				}
				string += toString(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			string += " ]";
			
			string = "[object " + getClassName(instance) + "] " + string;
			
			return string;
		}
		
		/**
		 * Use reflection to dump a string of all accessible 
		 * variables on a class instance.
		 * 
		 * @param instance Class instance being inspected
		 * @param stripEmptyValues If true any empty values are omitted.
		 * @param ignoreCustomToStrings If true any customToStrings are ignored and reflection used instead.
		 * @param delimiter Delimiter used between each listed item.
		 * @return com.lowke.Dump of accessible variables as String.
		 */
		public static function dumpClass(instance:*,
										 stripEmptyValues:Boolean = false,
										 ignoreCustomToStrings:Boolean = false,
										 delimiter:String = ", "):String
		{
			if (! instance)
			{
				return "null";
			}
			
			// check for a custom toString()
			var className:String = getClassName(instance);
			var customToString:String = instance.toString();
			var objectIdentifier:String = "[object " + className + "]"
			if (! ignoreCustomToStrings && customToString != objectIdentifier)
			{
				return objectIdentifier + " \"" + customToString + "\"";
			}
			
			var string:String = "{ ";
			
			// get reflection on the object
			var description:XML = describeType(instance);
			
			// pack variables
			var xml:XML;
			var key:String;
			for each (xml in description[VARIABLE]) 
			{
				string = appendValue(string, xml, instance, stripEmptyValues, ignoreCustomToStrings, delimiter);
			}
			
			// pack accessable accessors
			for each (xml in description[ACCESSOR])
			{
				var access:String = xml.@access;
				if (access == READWRITE || access == READONLY) 
				{
					string = appendValue(string, xml, instance, stripEmptyValues, ignoreCustomToStrings, delimiter);
				}
			}
			
			string += " }";
			
			// prepend objectIdentifier to string
			string = objectIdentifier + " " + string;
			
			return string;
		}
		
		// private helper method used by dumpClass()
		private static function appendValue(string:String,
											xml:XML, 
											instance:*,
											stripEmptyValues:Boolean,
											ignoreCustomToStrings:Boolean,
											delimiter:String):String
		{
			var key:String = xml.@name;
			var value:* = instance[key];
			
			if (stripEmptyValues && valueIsEmpty(value))
			{
				return string;
			}
			
			if (string != "{ ") 
			{
				string += delimiter;
			}
			string += key + ":" + toString(value, stripEmptyValues, ignoreCustomToStrings, delimiter);
			
			return string;
		}
		
		public static function getClassName(instance:*):String
		{
			var qualifiedClassName:String = getQualifiedClassName(instance);
			var split:Array = qualifiedClassName.split("::");
			var className:String = split[split.length - 1];
			
			return className;
		}
		
		public static function valueIsEmpty(value:*):Boolean
		{
			if (! value)	// caters for Booleans too
			{
				return true;
			} 
			else if (value is String && ! stringHasValue(value as String))
			{
				return true;
			} 
			else if (value is Number && (isNaN(value as Number) || value == 0))
			{
				return true;
			} 
			else if (isDynamicObject(value) && ! dynamicObjectHasValue(value))
			{
				return true;
			} 
			else if ((value is Array || isVector(value)) && ! value.length)
			{
				return true;
			}
			
			return false;
		}
		
		
		public static function isPrimitiveType(value:*):Boolean
		{
			if (value == null) 
			{
				return false;
			}
			
			if (value is String ||
				value is int || 
				value is uint || 
				value is Number || 
				value is Boolean) 
			{
				return true;
			} 
			else 
			{
				return false;
			}
		}
		
		public static function isVector(value:*):Boolean
		{
			return (getQualifiedClassName(value).indexOf("__AS3__.vec::Vector") == 0);
		}
		
		public static function isDynamicObject(value:*):Boolean
		{
			if (value == null) 
			{
				return false;
			}
			
			return (getQualifiedClassName(value) == "Object");
		}

		/**
		 * Specifies whether the specified String is either non-null, or contains
		 * characters (i.e. length is greater than 0)
		 *
		 * @param string The String which is being checked for a value
		 * @return Returns true if the String has a value
		 */
		public static function stringHasValue(string:String):Boolean
		{
			return (string != null && string.length > 0);
		}
		
		/**
		 * Specifies whether the dynamic Object has any value.
		 *
		 * @param instance The dynamic Object which is being checked for a value
		 * @return Returns true if the dynamic Object has a value
		 */
		public static function dynamicObjectHasValue(instance:Object):Boolean
		{
			if (instance == null)
			{
				return false;
			}
			
			if (isDynamicObject(instance))
			{
				for (var i:String in instance)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Apply all values from a dynamic Object to an instance
		 */
		public static function applyObjectValues(instance:*, object:Object):*
		{
			if (! isDynamicObject(object)) 
			{
				return;
			}
			
			for (var key:String in object) 
			{
				var value:* = object[key];
				try 
				{
					instance[key] = value;
				}
				catch (error:Error) {}
			}
			
			return instance;
		}
	}
}