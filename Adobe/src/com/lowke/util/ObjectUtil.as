package com.lowke.util
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ObjectUtil
	{

		public static function getClassName(object:Object):String
		{
			const CLASS_IDENTIFIER:String = "::";

			var className:String = getQualifiedClassName(object);
			if (className.indexOf(CLASS_IDENTIFIER) != -1)
			{
				var split:Array = className.split(CLASS_IDENTIFIER);
				className = split[1];
			}

			return className;
		}

		/**
		 * Returns a String containing all of the publically accessible variables
		 * and their values for the passed in class.
		 *
		 * @param  classObject Object
		 * @return String
		 */
		public static function classVariablesDescription(classObject:Object):String
		{

			var descriptionString:String = "";

			var description:XMLList = describeType(classObject)..variable;

			for (var i:int; i < description.length(); i++)
			{
				// using the += operator on descriptionString sometimes doesn't work.  Don't know the reason why.
				descriptionString = descriptionString.concat("\n" + description[i].@name + ':' + classObject[description[i].@name] + " ");
			}

			return descriptionString;
		}

		
		public static function dynamicObjectHasValue(value:*):Boolean
		{
			if (value == null) 
			{
				return false;
			}
			
			if (isDynamicObject(value))
			{
				for (var i:String in value) 
				{
					return true;
				}
			}
			return false;
		}
		
		
		public static function isDynamicObject(value:*):Boolean
		{
			if (value == null) 
			{
				return false;
			}
			
			return (getQualifiedClassName(value) == "Object");
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
				value is Boolean ||
				value is Array) {
				
				// normal value
				return true;
				
			} 
			else 
			{
				return false;
			}
		}

		/**
		 * Given an object return the class definition
		 *
		 * @return Returns the class defnition from an object
		 */
		public static function getClass(obj:Object):Class
		{
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}

		/**
		 * Make a deep copy of an object.
		 * Works particularly well with indexed and associative arrays,
		 *  but doesn't work with DisplayObjects. With DisplayObjects
		 *  try var objectClass:Class = Object(source).constructor;
		 *      var object:* = new objectClass();
		 *
		 * @param object Object being copied
		 */
		public static function clone(object:Object):*
		{
			var data:ByteArray = new ByteArray();
			data.writeObject(object);
			data.position = 0;
			return data.readObject();
		}


		
		/**
		 *	Create a Function that, when called, instantiates a class.
		 *	This is needed as ActionScript will not allow you to use apply()
		 * 	on a constructor, it only works on a function.
		 * 
		 *	@param classDefinition Class to instantiate
		 *	@return A function that, when called, instantiates a class with the
		 *           arguments passed to said Function or null if the given class
		 *           is null.
		 */
		public static function makeConstructorFunction(classDefinition:Class):Function
		{
			const MAX_ARGUMENTS_ERROR:String = " exceeds the 20 argument limit.";

			if (classDefinition == null)
			{
				return null;
			}
			
			/**
			 *   The function to call to instantiate the class
			 *   @param args Arguments to pass to the constructor. There may be up to
			 *               20 arguments.
			 *   @return The instantiated instance of the class or null if an instance
			 *          couldn't be instantiated. This happens if the given class or
			 *          arguments are null, there are more than 20 arguments, or the
			 *          constructor of the class throws an exception.
			 */
			return function(...args:Array): Object
			{
				switch (args.length)
				{
					case 0:
						return new classDefinition();
						break;
					case 1:
						return new classDefinition(args[0]);
						break;
					case 2:
						return new classDefinition(args[0], args[1]);
						break;
					case 3:
						return new classDefinition(args[0], args[1], args[2]);
						break;
					case 4:
						return new classDefinition(args[0], args[1], args[2], args[3]);
						break;
					case 5:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4]);
						break;
					case 6:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5]);
						break;
					case 7:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
						break;
					case 8:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
						break;
					case 9:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
						break;
					case 10:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
						break;
					case 11:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
						break;
					case 12:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
						break;
					case 13:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
						break;
					case 14:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
						break;
					case 15:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);
						break;
					case 16:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);
						break;
					case 17:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16]);
						break;
					case 18:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17]);
						break;
					case 19:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18]);
						break;
					case 20:
						return new classDefinition(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19]);
						break;
					default:
						break;
				}
				throw new Error(args.length + MAX_ARGUMENTS_ERROR);
			};
		}
	}
}
