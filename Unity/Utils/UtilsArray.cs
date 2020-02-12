//
//  UtilsArray - Utils package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
//  see http://www.lowkemedia.com for more information
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
using System.Linq;

public static class UtilsArray
{
    public static T[] CloneArray<T>(T[] array)
    {
        return (T[])array.Clone();
    }

    public static T[] Concat<T>(params T[][] arrays)
    {
        var result = new T[arrays.Sum(a => a.Length)];
        int offset = 0;
        for (int x = 0; x < arrays.Length; x++) {
            arrays[x].CopyTo(result, offset);
            offset += arrays[x].Length;
        }
        return result;
    }

    public static T[] AddTo<T>(T[] array, T value)
    {
        T[] updatedArray;
        if (array == null) {
            updatedArray = new T[] { value };
        } else {
            updatedArray = new T[array.Length + 1];
            Array.Copy(array, updatedArray, array.Length);
            updatedArray[array.Length] = value;
        }
        return updatedArray;
    }

    public static T[] RemoveFrom<T>(T[] array, T value)
    {
        T[] updatedArray = new T[array.Length - 1];
        int counter = 0;
        for (int i = 0; i < array.Length; ++i) {
            if (! array[i].Equals(value)) {
                updatedArray[counter++] = array[i];
            }
        }
        return updatedArray;
    }

    public static string Print<T>(T[] array)
    {
        string str = "[ ";
        for (int i = 0; i < array.Length; ++i) {
            str += array[i];
            str += (i < array.Length - 1) ? ", " : " ]";
        }
        return str;
    }
}
