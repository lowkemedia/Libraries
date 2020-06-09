//
//  ClassPacker v 1.0
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

package com.lowke.classPacker
{
import com.lowke.JsonVerifier;
import com.lowke.util.ObjectUtil;
import com.lowke.util.StringUtil;
import com.lowke.util.StringUtil;
    import com.lowke.Dump;
    import com.lowke.logger.Logger;
    
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    /**
     * @author Russell Lowke
     */
    public class ClassPacker
    {
        public static const LOG_PREFIX:String                                           = "CPK";
        public static const WARNING_VARIABLE_BEING_SET_ALREADY_EXISTS:String            = "CPK01";
        public static const WARNING_CANT_GET_REQUIRED_FIELD:String                      = "CPK02";
        public static const WARNING_OBJECT_NOT_JSON:String                              = "CPK03";

        public static const QUALIFIED_CLASS_NAME:String = "qualifiedClassName";
        public static const CONSTRUCTOR_PARAMETERS:String = "constructorParameters";
        
        private static const NULL:String = "null";
        
        private static const READWRITE:String = "readwrite";
        private static const READONLY:String = "readonly";
        private static const ACCESSOR:String = "accessor";
        private static const VARIABLE:String = "variable";
        
        
        /** 
         * helper method to add the qualified class name to a json packet
         *  so it can be unpacked as a specific class
         */
        public static function addQualifiedClassName(json:Object, classDefinition:Class):Object
        {
            var qualifiedClassname:String = getQualifiedClassName(classDefinition);
            setValue(json, QUALIFIED_CLASS_NAME, qualifiedClassname);
            
            return json;
        }
        
        
        public static function fromJson(json:Object,
                                        giveWarning:Boolean = true,
                                        classDefinition:Class = null):*
        {
            if (! Dump.isDynamicObject(json)) 
            {
                if (json) 
                {
                    Logger.warning("JsonVerifier.unpackClassObject() received invalid JSON Object of type:" + getQualifiedClassName(json) + ".\n\n value:\n" + Dump.toString(json), JsonVerifier.WARNING_OBJECT_NOT_JSON, true);
                }
                return null;
            }   
            
            var qualifiedClassName:String = json[QUALIFIED_CLASS_NAME];
            
            if (! StringUtil.stringHasValue(qualifiedClassName) && ! classDefinition)
            {
                if (giveWarning) 
                {
                    Logger.warning("To unpack a json into a Class Object the json must contain a " +
                        Dump.toString(QUALIFIED_CLASS_NAME) + " field.\n\njson:" + Dump.toString(json), JsonVerifier.WARNING_CANT_UNPACK_WITHOUT_CLASSNAME);
                }
                return;
            }
            
            // unpack a packed class object
            if (! classDefinition) 
            {
                classDefinition = Class(getDefinitionByName(qualifiedClassName));
            }
            
            var instance:*;
            var constructorParameters:Array = json[CONSTRUCTOR_PARAMETERS];
            if (constructorParameters) 
            {
                // construct the class according to supplied constructor variables
                var args:Array = new Array();
                for each (var constructorVariable:String in constructorParameters) 
                {
                    args.push(json[constructorVariable]);
                }
                instance = ObjectUtil.makeConstructorFunction(classDefinition).apply(null, args);
            } 
            else 
            {
                instance = new classDefinition();
            }
            
            for (var variable:String in json) 
            {
                if (variable == QUALIFIED_CLASS_NAME || 
                    variable == CONSTRUCTOR_PARAMETERS) 
                {
                    // don't try to unpack packing information
                    continue;
                }
                
                var value:* = getObject(json, variable);
                try 
                {
                    // try to assign all the variables we have
                    instance[variable] = value;
                } catch(error:Error) {}
            }
            return instance;
        }
        
        public static function toJson(instance:*,
                                      stripEmptyValues:Boolean = false, 
                                      constructorParameters:Array = null):Object
        {
            if (! constructorParameters && instance is IClassConstructor) 
            {
                constructorParameters = (instance as IClassConstructor).constructorParameters;
            }
            
            var json:Object = new Object();
            
            // pack the qualified class name
            var qualifiedClassName:String = getQualifiedClassName(instance);
            if (StringUtil.stringHasValue(qualifiedClassName) && qualifiedClassName != NULL)
            {
                json[QUALIFIED_CLASS_NAME] = qualifiedClassName;
            }
            
            // save constructor information
            if (constructorParameters) 
            {
                // pack constructor parameters
                json[CONSTRUCTOR_PARAMETERS] = constructorParameters;
                
                // pack constructor variables
                for each(var parameter:String in constructorParameters) 
                {
                    json[parameter] = packValue(instance[parameter]);
                }
            }
            
            // get reflection on the object
            var description:XML = describeType(instance);
            
            // pack variables
            var xml:XML;
            for each(xml in description[VARIABLE]) 
            {
                packVariable(json, xml, instance);
            }
            
            // pack accessable accessors
            for each(xml in description[ACCESSOR]) 
            {
                var access:String = xml.@access;
                if (access == READWRITE || access == READONLY) 
                {
                    packVariable(json, xml, instance);
                }
            }
            
            if (stripEmptyValues) 
            {
                json = removeEmptyValues(json);
            }
            
            return json;
        }
        
        private static function packVariable(json:Object, xml:XML, instance:*):void
        {
            var name:String = xml.@name;
            var type:String = xml.@type;
            var value:* = instance[name];
            json[name] = packValue(value);
        }
        
        private static function packValue(value:*):*
        {
            // TODO: PACK VECTOR?
            
            if (value is Array) 
            {
                // if value is an Array then walk the array packing each array item
                var array:Array = value as Array;
                var newArray:Array = new Array();
                for (var i:uint = 0; i < array.length; ++i) 
                {
                    newArray[i] = packValue(array[i]);
                }
                return newArray;
            } 
            else if (Dump.isPrimitiveType(value)) 
            {
                return value;
            } 
            else 
            {
                return toJson(value);
            }
        }

        public static function getObject(json:Object,
                                         field:String,
                                         required:Boolean = false,
                                         defaultValue:* = null):*
        {
            if (! Dump.isDynamicObject(json))
            {
                if (json)
                {
                    Logger.warning("JsonVerifier.getObject() received invalid JSON Object of type:" + getQualifiedClassName(json) + ".\n\n value:\n" + Dump.toString(json), WARNING_OBJECT_NOT_JSON, true);
                }
                return defaultValue;
            }

            var value:Object = json[field];
            if (! value)
            {
                if (required)
                {
                    Logger.warning("Could not find required field " + Dump.toString(field) + ".\n\njson:" +
                            Dump.toString(json), WARNING_CANT_GET_REQUIRED_FIELD, true);
                }

                return defaultValue;
            }

            return unpackValue(value);
        }


        private static function unpackValue(value:*):*
        {
            if (value is Array)
            {
                var array:Array = value as Array;
                value = array.map(function (element:*):*
                {
                    return unpackValue(element);
                });
            }
            else if (Dump.isDynamicObject(value))
            {
                var unpackedObject:* = ClassPacker.fromJson(value, false);
                if (unpackedObject)
                {
                    value = unpackedObject;
                }
            }

            return value;
        }

        /**
         * sometimes it's desirable to strip empty values
         * such as null, 0, NaN, false and ""
         *
         * By default this method will also strip empty Arrays [] and empty Objects {}
         */
        public static function removeEmptyValues(json:Object,
                                                stripEmptyArraysAndObjects:Boolean = true):Object
        {
            var counter:uint = 0;
            for (var key:String in json)
            {
                var value:* = json[key];

                if (! value ||
                        (value is String && ! StringUtil.stringHasValue(value as String)) ||
                        (value is Number && isNaN(value as Number)) )
                {
                    delete json[key];
                }
                else if (stripEmptyArraysAndObjects)
                {
                    // check for empty Objects or Arrays
                    if ((Dump.isDynamicObject(value) && Dump.dynamicObjectHasValue(value)) ||
                            (value is Array && ! (value as Array).length))
                    {
                        delete json[key];
                    }
                }
            }
            return json;
        }



        /**
         * Gives a warning if trying to add a field to JSON and that field already exists.
         *
         * @param json JSON object being edited
         * @param field Name of field in json being added
         * @param value Value field is being set to
         * @param replaceWithValue If false, any existing value for field is not overwritten
         * @param giveWarning If true, warning log is given if field already exists.
         * @return Modified JSON object is returned
         */
        public static function setValue(json:Object,
                                        field:String,
                                        value:*,
                                        replaceWithValue:Boolean = true,
                                        giveWarning:Boolean = true):Object
        {
            if (! Dump.isDynamicObject(json))
            {
                if (json && giveWarning)
                {
                    Logger.warning("JsonVerifier.setValue() received invalid JSON Object of type:" + getQualifiedClassName(json) + ".\n\n value:\n" + Dump.toString(json), WARNING_OBJECT_NOT_JSON, true);
                }
                return null;
            }

            if (json[field])
            {
                if (giveWarning)
                {
                    Logger.warning("Field " + Dump.toString(field) + " about to be set to " + Dump.toString(value) +
                            " already exists with value of " + Dump.toString(json[field]) +
                            ".\n\njson:" + Dump.toString(json), WARNING_VARIABLE_BEING_SET_ALREADY_EXISTS);
                }

                if (! replaceWithValue)
                {
                    return json;
                }
            }

            json[field] = value;

            return json;
        }

        public static function setObject(json:Object,
                                         field:String,
                                         instance:*,
                                         constructorParameters:Array = null,
                                         giveWarning:Boolean = true):Object
        {
            if (! Dump.isDynamicObject(json))
            {
                if (json)
                {
                    Logger.warning("JsonVerifier.setObject() received invalid JSON Object of type:" + getQualifiedClassName(json) + ".\n\n value:\n" + Dump.toString(json), WARNING_OBJECT_NOT_JSON, true);
                }
                return null;
            }

            var packedObject:Object = ClassPacker.toJson(instance, false, constructorParameters);
            return setValue(json, field, packedObject, true, giveWarning);
        }
    }
}