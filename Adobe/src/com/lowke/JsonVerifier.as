//
//  JsonVerifier v 1.3
//  Russell Lowke, September 9th 2016
//
//  Copyright (c) 2013-2016 Lowke Media
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
    import com.lowke.Dump;
    import com.lowke.logger.Logger;
    
    import flash.utils.getQualifiedClassName;
    
    /**
     * @author Russell Lowke
     */
    public class JsonVerifier
    {   
        private static const TRUE:String = "true";
        private static const FALSE:String = "false";

        public static const LOG_PREFIX:String                                           = "JSV";
        public static const WARNING_CANT_GET_REQUIRED_STRING:String                     = "JSV01";
        public static const WARNING_CANT_GET_REQUIRED_BOOLEAN:String                    = "JSV02";
        public static const WARNING_CANT_GET_REQUIRED_NUMBER:String                     = "JSV03";
        public static const WARNING_CANT_GET_REQUIRED_ARRAY:String                      = "JSV04";
        public static const WARNING_CANT_GET_REQUIRED_OBJECT:String                     = "JSV05";
        public static const WARNING_STRING_VALUE_NOT_LEGAL:String                       = "JSV06";
        public static const WARNING_DEFAULT_VALUE_NOT_LEGAL:String                      = "JSV07";
        public static const WARNING_STRING_VALUE_IS_ILLEGAL:String                      = "JSV08";
        public static const WARNING_NUMBER_EXCEEDS_MAXIMUM:String                       = "JSV09";
        public static const WARNING_NUMBER_BELOW_MINIMUM:String                         = "JSV10";
        public static const WARNING_INT_PASSED_AS_REAL:String                           = "JSV11";
        public static const WARNING_UINT_PASSED_AS_REAL:String                          = "JSV12";
        public static const WARNING_CANT_UNPACK_WITHOUT_CLASSNAME:String                = "JSV13";
        public static const WARNING_OBJECT_NOT_JSON:String                              = "JSV14";
        
		
		public static function getString(json:Object,
										 field:String,
										 required:Boolean = false,
										 defaultValue:String = null,
										 forceToLowerCase:Boolean = false,
										 legalValues:Vector.<String> = null,
										 illegalValues:Vector.<String> = null):String
		{
            if (! isJson(json))
            {
                return defaultValue;
            }
			
			// get the string
			var string:String = json[field];
			
			// if required and has no value then give a warning
			if (required && ! Dump.stringHasValue(string))
			{
				Logger.warning("Can't get required String field " + Dump.toString(field) + ".\n\njson:" + Dump.toString(json), WARNING_CANT_GET_REQUIRED_STRING);
			}
			
			if (forceToLowerCase)
			{
				if (stringHasValue(string))
				{
					string = string.toLowerCase();
				}
				if (stringHasValue(defaultValue))
				{
					defaultValue = defaultValue.toLowerCase();
				}
			}
			
			// if no string set it to the default
			if (! string) 
			{
				string = defaultValue;
				
				// check that the default is legal
				if (illegalValues && illegalValues.indexOf(string) != -1)
				{
					// warn default illegal
					Logger.warning("String field " + Dump.toString(field) + " uses default value of " + Dump.toString(string) + " which is flagged as an illegal value.\n\njson:" + Dump.toString(json), WARNING_DEFAULT_VALUE_NOT_LEGAL);
				}
				else if (legalValues && legalValues.indexOf(defaultValue) == -1)
				{
					// warn default not legal
					Logger.warning("String field " + Dump.toString(field) + " uses default value of " + Dump.toString(defaultValue) + " when it should be set to one of the following:" +
						Dump.toString(legalValues) + ".\n\njson:" + Dump.toString(json), WARNING_DEFAULT_VALUE_NOT_LEGAL);
				}
			}
			else if (illegalValues && illegalValues.indexOf(string) != -1)
			{
				// give warning if string on list of illegal values
				Logger.warning("String field " + Dump.toString(field) + " = " + Dump.toString(string) + " which is flagged as an illegal value.\n\njson:" + Dump.toString(json), WARNING_STRING_VALUE_IS_ILLEGAL);
				string = defaultValue;
			}
			else if (legalValues && legalValues.indexOf(string) == -1)
			{
				// give warning if string not on the list of legal values
				Logger.warning("String field " + Dump.toString(field) + " = " + Dump.toString(string) + " when it should be set to one of the following:" +
					Dump.toString(legalValues) + ".\n\njson:" + Dump.toString(json), WARNING_STRING_VALUE_NOT_LEGAL);
				string = defaultValue;
			}
			
			return string;
		}


        public static function getBoolean(json:Object,
                                          field:String,
                                          required:Boolean = false,
                                          defaultValue:Boolean = false):Boolean
        {
            if (! isJson(json))
            {
                return defaultValue;
            }

            var string:String = json[field];
            if (string)
            {
                string = string.toLowerCase();

                if (string == TRUE)
                {
                    return true;
                }
                else if (string == FALSE)
                {
                    return false;
                }
                else
                {
                    return defaultValue;
                }
            }

            if (required)
            {
                Logger.warning("Could not find required Boolean field " + Dump.toString(field) + ".\n\njson:" +
                        Dump.toString(json), WARNING_CANT_GET_REQUIRED_BOOLEAN);
            }
            return defaultValue;
        }


        // returns "true", "false", or null, if no Boolean was found.
        public static function getBooleanAsString(json:Object, 
                                                  field:String, 
                                                  required:Boolean = false):String
        {
            if (! isJson(json))
            {
                return null;
            }
            
            var string:String = json[field];
            if (string) 
			{
                string = string.toLowerCase();
                if (string == TRUE || string == FALSE) 
                {
                    return string;
                } 
                else 
                {
                    return null;
                }
            }
            
            if (required) 
            {
                Logger.warning("Could not find required Boolean field " + Dump.toString(field) + ".\n\njson:" +
                    Dump.toString(json), WARNING_CANT_GET_REQUIRED_BOOLEAN);
            }
            
            return null;
        }

        
        public static function getNumber(json:Object, 
                                         field:String, 
                                         required:Boolean = false,
                                         defaultValue:Number = NaN,
                                         minimum:Number = NaN,
                                         maximum:Number = NaN):Number
        {
            if (! isJson(json))
            {
                return defaultValue;
            }
            
            var number:Number;
            var string:String = json[field];
            if (! string) 
            {
                if (required) 
                {
                    Logger.warning("Could not find required field " + Dump.toString(field) + ".\n\njson:" +
                        Dump.toString(json), WARNING_CANT_GET_REQUIRED_NUMBER);
                }
                number = defaultValue;
            } 
            else 
            {
                number = json[field];
            }
            
            if (! isNaN(minimum) && number < minimum) 
            {
                Logger.warning("Field " + Dump.toString(field) + " = " + number + " when it shouldn't be < " + minimum + ".\n\njson:" +
                    Dump.toString(json), WARNING_NUMBER_BELOW_MINIMUM);
                number = minimum;
            }
            
            if (! isNaN(maximum) && number > maximum) 
            {
                Logger.warning("Field " + Dump.toString(field) + " = " + number + " when it shouldn't be > " + maximum + ".\n\njson:" +
                    Dump.toString(json), WARNING_NUMBER_EXCEEDS_MAXIMUM);
                number = maximum;
            }
            
            return number;
        }

        public static function getInt(json:Object,
                                      field:String,
                                      required:Boolean = false,
                                      defaultValue:int = 0,
                                      maximum:Number = NaN,
                                      minimum:Number = NaN,
                                      round:Boolean = false):int
        {
            var number:Number = getNumber(json, field, required, defaultValue, int.MIN_VALUE, int.MAX_VALUE);
            var integer:int = round ? Math.round(number) : Math.floor(number);
            if (number != integer)
            {
                Logger.warning("int field " + Dump.toString(field) + " = " + number + ". An int value should not have decimal places.\n\njson:" +
                        Dump.toString(json), WARNING_INT_PASSED_AS_REAL);
            }
            return integer;
        }
        
        public static function getUint(json:Object, 
                                       field:String, 
                                       required:Boolean = false,
                                       defaultValue:uint = 0,
                                       maximum:Number = NaN,
                                       minimum:Number = NaN,
                                       round:Boolean = false):uint
        {
            var unsignedInteger:uint;
            var string:String = json[field];
            if (string && string.indexOf("0x") != -1)
            {
                unsignedInteger = uint(string);
            }
            else
            {
                var number:Number = getNumber(json, field, required, defaultValue, uint.MIN_VALUE, uint.MAX_VALUE);
                unsignedInteger = round ? Math.round(number) : Math.floor(number);
                if (number != unsignedInteger)
                {
                    Logger.warning("uint field " + Dump.toString(field) + " = " + number + ". A uint value should not have decimal places.\n\njson:" +
                        Dump.toString(json), WARNING_UINT_PASSED_AS_REAL);
                }
            }

            return unsignedInteger;
        }

        public static function getArray(json:Object,
                                        field:String,
                                        required:Boolean = false,
                                        defaultValue:Array = null):Array
        {
            if (! isJson(json))
            {
                return defaultValue;
            }

            var array:Array = json[field];
            if (array == null)
            {
                if (required)
                {
                    Logger.warning("Could not find required field " + Dump.toString(field) + ".\n\njson:" + Dump.toString(json), WARNING_CANT_GET_REQUIRED_ARRAY);
                }

                return defaultValue;
            }

            return array;
        }

        public static function getObject(json:Object,
                                         field:String,
                                         required:Boolean = false,
                                         defaultValue:* = null):Object
        {
            if (! isJson(json))
            {
                return defaultValue;
            }

            var value:Object = json[field];
            if (! value)
            {
                if (required)
                {
                    Logger.warning("Could not find required field " + Dump.toString(field) + ".\n\njson:" + Dump.toString(json), WARNING_CANT_GET_REQUIRED_OBJECT);
                }

                return defaultValue;
            }

            return value;
        }

        private static function isJson(json:Object):Boolean
        {
            if (! Dump.isDynamicObject(json))
            {
                if (json)
                {
                    Logger.warning("JsonVerifier received invalid JSON Object of type:" + getQualifiedClassName(json) + ".\n\n value:\n" + Dump.toString(json), WARNING_OBJECT_NOT_JSON, true);
                }
                else
                {
                    Logger.warning("JsonVerifier received a null JSON Object.", WARNING_OBJECT_NOT_JSON, true);
                }
                return false;
            }

            return true;
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
    }
}