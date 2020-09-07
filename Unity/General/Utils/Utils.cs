//
//  Utils - Utils package
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
using System.Reflection;
using UnityEngine;
using Object = UnityEngine.Object;

public static class Utils
{
    //
    // Get GameObject of UnityEngine.Object
    //
    public static GameObject GetGameObject(this Object obj)
    {
        GameObject gameObject;
        if (obj is Component) {
            gameObject = (obj as Component).gameObject;
        } else if (obj is GameObject) {
            gameObject = obj as GameObject;
        } else if (obj == null) {
            throw new Exception("GetGameObject() called on null Object");
        } else {
            throw new Exception("GetGameObject() called on Object " + obj + " that is not a Component or GameObject");
        }

        return gameObject;
    }

    //
    // set and get UnityEngine Object parent
    //
    public static void SetParent(this Object child, Object parent)
    {
        // TODO: Include optional straight transform.parent assign?
        // child.GetGameObject().transform.parent = parent.GetGameObject().transform;

        child.GetGameObject().transform.SetParent(parent.GetGameObject().transform);
        // native transform.SetParent() is better as parent-relative position,
        //  scale and rotation are modified such that the object keeps the same world space position
    }

    public static GameObject GetParent(this Object obj)
    {
        Transform parent = obj.GetGameObject().transform.parent;
        return parent == null ? null : parent.gameObject;
    }

    //
    // Copy Component using reflection
    //
    public static void CopyComponent<T>(this T target, T template, string[] ignore = null) where T : Component
    {
        foreach (PropertyInfo propertyInfo in typeof(T).GetProperties())
        {
            if (propertyInfo.CanWrite && propertyInfo.CanRead) {
                if (ignore != null && Array.IndexOf(ignore, propertyInfo.Name) != -1) {
                    // skip this property as it's on the ignore list
                    continue;
                }
                propertyInfo.SetValue(target, propertyInfo.GetValue(template));
            }
        }
    }

    //
    // Copy specific Component properties
    //
    public static void CopyProperties<T>(this T target, T template, string[] properties) where T : Component
    {
        foreach (PropertyInfo propertyInfo in typeof(T).GetProperties()) {
            if (propertyInfo.CanWrite && Array.IndexOf(properties, propertyInfo.Name) != -1) {
                propertyInfo.SetValue(target, propertyInfo.GetValue(template));
            }
        }
    }

    //
    // Clamp a value
    public static T Clamp<T>(T value, T min, T max) where T : IComparable
    {
        T output = value;
        if (value.CompareTo(max) > 0) {
            return max;
        }
        if (value.CompareTo(min) < 0) {
            return min;
        }
        return output;
    }
}
