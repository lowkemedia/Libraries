package com.lowke.util
{
	
	import flash.utils.describeType;

	public class StringUtil
	{


        /**
         * Returns true if all values in a String are numbers
         */
        public static function isNumeric(string:String):Boolean
        {
            for (var i:uint = 0; i < string.length; ++i)
            {
                var char:String = string.charAt(i);
                switch (char)
                {
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                    case '.':
                    case ',':
                    case ' ':
                        // ok, is number
                        break;

                    default:
                        return false;
                }
            }

            return true;
        }

        public static function trimWhitespace(string:String):String
        {
            if (stringHasValue(string))
            {
                return string.replace(/^\s+|\s+$/g, "");
            }
            else
            {
                return "";
            }
        }

        public static function trimSpaces(string:String):String
        {
            while(beginsWith(string, ' '))
            {
                string = string.substring(1);
            }

            while(endsWith(string, ' '))
            {
                string = string.substring(0, string.length - 1);
            }

            return string;
        }

        /**
         * Converts a number to a string and adds zeros in front according
         * to its maximum value.  Useful for filenames where zeros have
         * been added to the beginning of the sequence.
         *
         * @param value Value being converted to a String.
         * @param maximumValue Maximum value value can be.
         * @return String representation of value.
         */
        public static function addLeadingZeros(value:uint, maximumValue:uint):String
        {
            var maximumAsString:String = ("" + maximumValue);
            var valueAsString:String = ("" + value);

            // add '0''s if any
            for (var i:uint = valueAsString.length; i < maximumAsString.length; ++i)
            {
                valueAsString = "0" + valueAsString;
            }

            return valueAsString;
        }



        /**
         * Make the first letter in a string uppercase, ie --> "color" --> "Color"
         *
         * @param  string  String
         * @return String
         */
        public static function makeFirstLetterUpperCase(string:String):String
        {
            var char:String = string.charAt(0).toUpperCase();
            return (string.length > 1) ? char + string.substr(1, string.length - 1) : char;
        }


        /**
         * Replaces all instances of the replace string in the input string
         * with the replaceWith string.
         *
         * @param input Original string
         * @param replace The string that will be replaced
         * @param replaceWith The string that will replace instances of replace
         * @returns A new String with the replace string replaced with replaceWith
         */
        public static function stringReplace(input:String,
                                             replace:String,
                                             replaceWith:String):String
        {
            return input.split(replace).join(replaceWith);
        }

        /**
         * Determines whether the specified string begins with the spcified prefix.
         *
         * @param input The string that the prefix will be checked against.
         * @param prefix The prefix that will be tested against the string.
         * @returns True if the string starts with the prefix, false if it does not.
         */
        public static function beginsWith(input:String, prefix:String):Boolean
        {
            if (! stringHasValue(input) || ! stringHasValue(prefix))
            {
                return false;
            }
            return (prefix == input.substring(0, prefix.length));
        }


        /**
         * Determines whether the specified string ends with the spcified suffix.
         *
         * @param input The string that the suffic will be checked against.
         * @param prefix The suffic that will be tested against the string.
         * @returns True if the string ends with the suffix, false if it does not.
         */
        public static function endsWith(input:String, suffix:String):Boolean
        {
            if (! stringHasValue(input) || ! stringHasValue(suffix))
            {
                return false;
            }
            return (suffix == input.substring(input.length - suffix.length));
        }


        public static function enclosedBy(input:String, prefix:String, suffix:String):String
        {
            input = trimSpaces(input);
            if (beginsWith(input, prefix) &&
                    endsWith(input, suffix))
            {
                return input.substring(prefix.length, input.length - suffix.length);
            }

            return null;
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
         * Looks through a String for Array brackets and parses as an array
         */
        public static function findArray(input:String,
                                         prefix:String = '[',
                                         suffix:String = ']',
                                         delimiter:String = ","):Array
        {
            input = trimSpaces(input);
            var startIndex:int = input.indexOf(prefix);
            var endIndex:int = input.lastIndexOf(suffix);
            if (startIndex == -1 || endIndex == -1)
            {
                // can't find prefix or suffix identifiers
                return null;
            }

            var contents:String = input.substring(startIndex + 1, endIndex);
            if (! stringHasValue(contents))
            {
                // no content
                return [];
            }

            var array:Array = contents.split(delimiter);

            // trim whitespace
            for (var i:uint = 0; i < array.length; ++i)
            {
                var item:String = array[i];
                item = trimSpaces(item);
                array[i] = item;
            }

            return array;
        }
		
		
		/**
		 * Given a URL return the path but exclude any file name
		 * 
		 * @param url URL String with a path
		 * 
		 * @return Returns the path in the url
		 */
		public static function urlPath(url:String):String
		{
			stripCGI(url);
			
			var index:int = url.lastIndexOf('/');
			var path:String = "";
			
			if (index == -1 && 
				url.lastIndexOf('.') == -1) {
				
				// ensure path ends in a '/'
				if (stringHasValue(url)) {
					var lastIndex:Number = url.length - 1;
					var lastCharacter:String = path.charAt(lastIndex);
					path = url + "/";
				} else {
					path = "";
				}
			} else {
				index += 1;
				path = url.substring(0, index);
			}
			
			return path;
		}
		
		/**
		 * Given a URL return the file name
		 * 
		 * @param url URL String with file name
		 * 
		 * @return Returns the file name in the url
		 */
		public static function urlFileName(url:String):String
		{
			stripCGI(url);
			var index:uint = url.lastIndexOf('/') + 1;
			var fileName:String = url.substring(index);
			return fileName;
		}
		
		public static function fileTypeSuffix(url:String):String
		{
			var suffix:String = stripCGI(url);
			suffix = suffix.slice(suffix.lastIndexOf("."));
			suffix = suffix.toLowerCase();
			return suffix;
		}

			
		/**
		 * Strips any CGI "?" variables from a url String.
		 *
		 * @param url URL String being stripped
		 * 
		 * @return Returns the cleaned URL String
		 */
		public static function stripCGI(url:String):String
		{
			if (! url)
			{
				return null;
			}
			
			var index:int = url.indexOf('?');
			if (index > -1)
			{
				// strip out any "?" CGI data
				url = url.slice(0, index);
			}
			return url;
		}

        public static function truncate(string:String,
                                        maxChars:uint = 256):String
        {
            if (string.length > maxChars)
            {
                string = string.slice(0, maxChars - 3);
                string += "...";
            }
            return string;
        }

        /**
         * With strings coming from XML it's often handy to strip whitespace.
         */
        public static function stripWhitespace(str:String):String
        {
            var whitespace:RegExp = /(\t|\n|\s{2,})/g;
            str = str.replace(whitespace, "");
            return str;
        }


        /**
         * Strings read from xml files don't have the escape sequences such
         * as new line recognized in the string. This utility puts the New Line,
         * Carriage Return and Tab escape sequences back in.
         *
         * @param string String being scanned for escape sequences.
         * @return The fixed string is returned.
         */
        public static function fixEscapeSequences(string:String):String
        {
            var fixedString:String = string;
            var array:Array = string.split('\\');
            if (array.length > 0)
            {
                fixedString = array[0];
                for (var i:uint = 1; i < array.length; ++i)
                {
                    var line:String = array[i];
                    var char:String = line.substr(0, 1);
                    line = line.substr(1);
                    switch (char)
                    {
                        case 'n':                   // New Line
                            line = '\n' + line;
                            break;
                        case 'r':                   // Carriage Return
                            line = '\r' + line;
                            break;
                        case 't':                   // Tab
                            line = '\t' + line;
                            break;
                    }
                    fixedString += line;
                }
            }

            return fixedString;
        }
	}
}