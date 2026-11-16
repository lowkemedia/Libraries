//
//  UtilsArray - Utils package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
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
using System.Collections.Generic;
using System.Linq;

public static class UtilsArray
{
    // Native equivalent: Array.Clear(array, 0, array.Length).
    public static void ResetArray<T>(this T[] array)
    {
        for (int i = 0; i < array.Length; ++i) {
            // default(T) will return the default value for whatever type T is
            // For example, if T is an int, default(T) would return 0
            array[i] = default(T);
        }
    }

    // Native equivalent for non-null arrays: (T[])array.Clone(); both are shallow copies.
    public static T[] CloneArray<T>(T[] array)
    {
        if (array == default) {
            return default;
        }
        return (T[])array.Clone();
    }

    // Native alternative: arrays.SelectMany(array => array).ToArray() (System.Linq).
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

    // Native alternative for non-null arrays: array.Append(value).ToArray() (System.Linq).
    // For repeated additions, prefer List<T>.Add to allocating an array each time.
    public static T[] AddTo<T>(T[] array, T value)
    {
        T[] updatedArray;
        if (array is null) {
            updatedArray = new T[] { value };
        } else {
            updatedArray = new T[array.Length + 1];
            Array.Copy(array, updatedArray, array.Length);
            updatedArray[array.Length] = value;
        }
        return updatedArray;
    }

    // Native alternative for a mutable collection: List<T>.Remove(value).
    // This legacy array helper assumes exactly one matching element and non-null elements.
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

    // Native expression: array == null || array.Length == 0.
    public static bool IsNullOrEmpty<T>(T[] array) {
        return array == null || array.Length == 0;
    }

    // Native expression: array?.Length ?? 0.
    public static int Length<T>(T[] array) {
        return IsNullOrEmpty(array) ? 0 : array.Length;
    }

    // Native building block: string.Join(", ", array); brackets and null/empty labels are custom.
    public static string Print<T>(T[] array)
    {
        if (array is null) { return "null"; }
        if (array.Length == 0) { return "[]"; }

        string str = "[ ";
        for (int i = 0; i < array.Length; ++i) {
            str += array[i];
            str += (i < array.Length - 1) ? ", " : " ]";
        }
        return str;
    }


    // using System.Linq;
    //
    // convert a List to an Array
    // T[] array = list.ToArray();
    //
    // convert an Array to a List
    // List<T> list = array.ToList();

    // Native building block: string.Join(", ", list); brackets and null/empty labels are custom.
    public static string Print<T>(List<T> list)
    {
        if (list == default) { return "default"; }
        if (list.Count == 0) { return "[]"; }

        string str = "[ ";
        for (int i = 0; i < list.Count; ++i) {
            str += list[i];
            str += (i < list.Count - 1) ? ", " : " ]";
        }
        return str;
    }

    // Native equivalent: first.SequenceEqual(second) (System.Linq).
    // Compares length, order and elements using C# default equality, including null elements.
    // Unlike ActionScript strict equality, this honors T's equality implementation.
    // Null arrays throw ArgumentNullException, as SequenceEqual does.
    public static bool ArraysAreEqual<T>(T[] first, T[] second)
    {
        if (first == null) {
            throw new ArgumentNullException(nameof(first));
        }
        if (second == null) {
            throw new ArgumentNullException(nameof(second));
        }
        if (first.Length != second.Length) {
            return false;
        }

        EqualityComparer<T> comparer = EqualityComparer<T>.Default;
        for (int i = 0; i < first.Length; i++) {
            if (!comparer.Equals(first[i], second[i])) {
                return false;
            }
        }
        return true;
    }
}
