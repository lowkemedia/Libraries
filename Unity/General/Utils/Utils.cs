//
//  Utils - Utils package
//  Russell Lowke, October 6th 2022
//
//  Copyright (c) 2019-2022 Lowke Media
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
using UnityEngine.UI;
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
        } else if (obj is null) {
            throw new Exception("GetGameObject() called on null Object");
        } else {
            throw new Exception("GetGameObject() called on Object " + obj + " that is not a Component or GameObject");
        }

        return gameObject;
    }

    public static Transform GetTransform(this Object obj)
    {
        GameObject gameObject = obj.GetGameObject();
        return gameObject.transform;
    }

    public static Canvas GetCanvas(this Object obj)
    {
        Canvas[] canvases = obj.GetTransform().GetComponentsInParent<Canvas>();
        if (canvases.Length != 1) {
            throw new Exception("Could not find Canvas on object");
        }

        Canvas canvas = canvases[0];
        return canvas;
    }

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
        return parent is null ? null : parent.gameObject;
    }


    public static GameObject GetChild(this Object obj, string name)
    {
        Transform transform = obj.GetTransform();

        // iterate through children loking for named child
        foreach(Transform childTransform in transform) {
            GameObject childGameObject = childTransform.GetGameObject();
            if (childGameObject.name == name) {
                return childGameObject;
            }
        }

        return default;
    }

    //
    // Move child to top of display list
    public static void MoveToTop(this Object obj)
    {
        Transform transform = obj.GetTransform();
        transform.SetAsLastSibling();
    }

    //
    // Move child to bottom of display list
    public static void MoveToBottom(this Object obj)
    {
        Transform transform = obj.GetTransform();
        transform.SetAsFirstSibling();
    }

    public static int GetLayer(this Object obj)
    {
        Transform transform = obj.GetTransform();
        return transform.GetSiblingIndex();
    }

    public static void SetLayer(this Object obj, int index)
    {
        Transform transform = obj.GetTransform();
        transform.SetSiblingIndex(index);
    }

    //
    // set and get local position of UnityEngine Object
    //
    public static void SetLocalPosition(this Object obj, Vector3 localPosition)
    {
        obj.GetTransform().localPosition = localPosition;
    }

    public static void SetLocalPosition(this Object obj,
                                        float x, float y, float z = float.NaN)
    {
        Transform transform = obj.GetTransform();
        Vector3 localPosition = transform.localPosition;
        if (!float.IsNaN(x)) {
            localPosition.x = x;
        }
        if (!float.IsNaN(y)) {
            localPosition.y = y;
        }
        if (!float.IsNaN(z)) {
            localPosition.z = z;
        }
        transform.localPosition = localPosition;
    }

    public static Vector3 GetLocalPosition(this Object obj)
    {
        return obj.GetTransform().localPosition;
    }

    // get local position of world Vector3
    public static Vector3 GetLocalPosition(this Object obj, Vector3 worldPosition)
    {
        Transform transform = obj.GetTransform();
        return transform.InverseTransformPoint(worldPosition);
    }

    // get local position of a world object
    public static Vector3 GetLocalPosition(this Object obj, Object worldObj)
    {
        Vector3 worldPosition = worldObj.GetTransform().position;
        return obj.GetLocalPosition(worldPosition);
    }

    // get world position of local Vector3
    public static Vector3 GetWorldPosition(this Object obj, Vector3 localPosition)
    {
        Transform transform = obj.GetTransform();
        return transform.TransformPoint(localPosition);
    }

    public static void SetX(this Object obj, float x)
    {
        obj.SetLocalPosition(x, float.NaN);
    }

    public static void SetY(this Object obj, float y)
    {
        obj.SetLocalPosition(float.NaN, y);
    }

    public static float GetX(this Object obj)
    {
        return obj.GetLocalPosition().x;
    }

    public static float GetY(this Object obj)
    {
        return obj.GetLocalPosition().y;
    }

    //
    // set and get scale of UnityEngine Object
    //
    public static void SetScale(this Object obj, Vector3 scale)
    {
        obj.GetTransform().localScale = scale;
    }

    public static void SetScale(this Object obj, float scale)
    {
        obj.SetScale(new Vector3(scale, scale, 1));
    }

    public static float GetScale(this Transform transform, bool giveWarnig = true)
    {
        Vector3 localScale = transform.localScale;
        if (giveWarnig && localScale.x != localScale.y) {
            Logger.Warning("localScale.x != localScale.y in GetScale()");
        }
        return localScale.x;
    }

    public static float GetScale(this Object obj)
    {
        return obj.GetTransform().GetScale();
    }

    public static void SetRotation(this Object obj, float angle)
    {
        Transform transform = obj.GetTransform();
        transform.Rotate(new Vector3(0, 0, angle));
    }

    // clear all child gameObjects from this parent
    public static void ClearChildren(this GameObject parent)
    {
        Transform transform = parent.GetTransform();
        foreach (Transform child in transform) {
            GameObject.Destroy(child.gameObject);
        }
    }

    // set the raycastTarget of all Graphics on this gameObject
    public static void RaycastGraphics(this GameObject gameObject, bool raycastTarget)
    {
        Graphic[] graphics = gameObject.GetComponentsInChildren<Graphic>();
        foreach (Graphic graphic in graphics) {
            graphic.raycastTarget = raycastTarget;
        }
    }

    // make all Graphics on this gameObject invisible (color = Color.clear)
    public static void MakeInvisible(this GameObject gameObject)
    {
        Graphic[] graphics = gameObject.GetComponentsInChildren<Graphic>();
        foreach (Graphic graphic in graphics) {
            graphic.color = Color.clear;
        }
    }

    // return the root Image on this gameObject
    public static Image RootImage(this GameObject gameObject)
    {
        Image image = gameObject.GetComponent<Image>();
        if (image == default) {
            throw new Exception("Could not find root Image on gameObject");
        }
        return image;
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

    //
    // Swap a value
    public static void Swap<T>(ref T x, ref T y)
    {
        T t = y;
        y = x;
        x = t;
    }

    public static bool IsDestroyed(GameObject gameObject)
    {
        // UnityEngine overloads the == opeator for the GameObject type
        // and returns null when the object has been destroyed, but 
        // actually the object is still there but has not been cleaned up yet
        // if we test both we can determine if the object has been destroyed.
        return gameObject is null && !ReferenceEquals(gameObject, null);
    }
}
