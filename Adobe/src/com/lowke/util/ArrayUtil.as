package com.lowke.util
{
    public class ArrayUtil
    {
        /**
         * Compares two arrays and returns a boolean indicating whether the arrays
         * contain the same values at the same indexes.
         *
         * @param arr1 The first array that will be compared to the second.
         * @param arr2 The second array that will be compared to the first.
         * @return True if the arrays contains the same values at the same indexes.
         *          False if they do not.
         */
        public static function arraysAreEqual(arr1:Array, arr2:Array):Boolean
        {
            if (arr1.length != arr2.length)
            {
                return false;
            }

            var len:Number = arr1.length;

            for (var i:Number = 0; i < len; i++)
            {
                if (arr1[i] !== arr2[i])
                {
                    return false;
                }
            }

            return true;
        }


        /**
         * Insterts a value into an array at position
         *
         * @param array Array being modified
         * @param value Value being inserted
         * @param index Position value is inserted into array
         * @return Reference to the modified array
         */
        public static function insertIntoArray(array:Array, value:*, index:uint):Array
        {
            return array.splice(index, 0, value);
        }


        /**
         * Removes a value from an array
         *
         * @param array Array being modified
         * @param index Position of value being removed from array
         * @return Reference to the modified array
         */
        public static function removeIndex(arr:Array, index:uint):Array
        {
            return arr.splice(index, 1);
        }


        /**
         * Copies an array of references
         */
        public static function copyReferences(array:Array):Array
        {
            return array.map(function (e:*):* { return e; });
        }


        /**
         * Specifies whether the specified Array is either non-null, or contains
         * characters (i.e. length is greater than 0)
         *
         * @param array The Array which is being checked for a value
         * @return Returns true if the Array has a value
         */
        public static function arrayHasValue(array:Array):Boolean
        {
            return (array != null && array.length > 0);
        }
    }
}
