//
//  Utils - Utils package
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
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

public static class Utils
{
    //
    // Make child GameObject on parent
    //
    public static GameObject MakeGameObject(this GameObject parent,
                                            string name = null)
    {
        GameObject child = new GameObject();
        if (!string.IsNullOrEmpty(name)) {
            child.name = name;
        }
        RectTransform rectTransform = child.AddComponent<RectTransform>();
        rectTransform.SetParent(parent.transform);
        rectTransform.sizeDelta = new Vector2(100, 100);    // width 100x100
        rectTransform.localScale = new Vector3(1, 1, 1);    // scale 1, 1, 1
        child.SetPosition(0, 0);                           // position 0, 0

        return child;
    }

    //
    // Get GameObject of UnityEngine.Object
    //
    public static GameObject GetGameObject(this Object obj)
    {
        GameObject gameObject;
        if (obj is Component)
        {
            gameObject = (obj as Component).gameObject;
        }
        else if (obj is GameObject)
        {
            gameObject = (obj as GameObject);
        }
        else
        {
            throw new Exception("GetGameObject() called on UnityEngine.Object that is not a Component or GameObject");
        }

        return gameObject;
    }

    //
    // Make Component on new child GameObject
    //
    public static T MakeComponent<T>(this GameObject parent,  T duplicate) where T : Component
    {
        GameObject child = MakeGameObject(parent, "" + duplicate.GetType());
        T target = child.AddComponent<T>();
        target.CopyComponent(duplicate);

        return target;
    }

    //
    // Copy Component using reflection
    //
    public static void CopyComponent<T>(this T target, T duplicate) where T : Component
    {
        foreach (PropertyInfo x in typeof(T).GetProperties())
        {
            if (x.CanWrite)
            {
                x.SetValue(target, x.GetValue(duplicate));
            }
        }
    }

    public static Color ConvertColor(string colorString)
    {
        ColorUtility.TryParseHtmlString(colorString, out Color returnColor);
        return returnColor;
    }
}
