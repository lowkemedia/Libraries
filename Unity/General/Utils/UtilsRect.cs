//
//  UtilsRect - Utils package
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

using UnityEngine;
using TMPro;
using Object = UnityEngine.Object;

public static class UtilsRect
{
    //
    // Make child GameObject with UI RectTransform on parent
    //
    public static GameObject MakeUiObject(this GameObject parent,
                                          string name = null)
    {
        GameObject child = new GameObject();
        RectTransform rectTransform = child.AddComponent<RectTransform>();
        rectTransform.SetParent(parent.transform);
        rectTransform.sizeDelta = new Vector2(0, 0);        // width 0x0
        rectTransform.localScale = new Vector3(1, 1, 1);    // scale 1, 1, 1
        child.SetLocalPosition(0, 0);                            // position 0, 0

        if (!string.IsNullOrEmpty(name)) {
            child.name = name;
        }
        return child;
    }

    //
    // Copy child GameObject with RectTransform on parent
    //
    public static T MakeUiComponent<T>(this GameObject parent,
                                       T template,
                                       string name = null,
                                       string[] ignore = null) where T : Component
    {
        GameObject gameObject = parent.MakeUiObject();
        T component = gameObject.AddComponent<T>();
        component.CopyComponent(template, ignore);
        component.CopyRect(template);

        if (name != null) {
            component.name = name;
        }
        return component;
    }

    public static TextMeshProUGUI MakeTextMesh(this GameObject parent,
                                          TextMeshProUGUI template,
                                          string name = null)
    {
        string[] ignore = { "fontSharedMaterials", "fontSharedMaterial", "fontMaterial", "fontMaterials" };
        return parent.MakeUiComponent(template, name, ignore);
    }

    //
    // Copy RectTransform using reflection
    //
    public static void CopyRect(this Object target, Object template, bool ignoreParent = true)
    {
        RectTransform targetRect = target.GetRectTransform();
        RectTransform templateRect = template.GetRectTransform();
        string[] ignore = ignoreParent ? new string[] { "parent" } : null;
        targetRect.CopyComponent(templateRect, ignore);
    }

    //
    // Get RectTransform from a UnityEngine Object
    //
    public static RectTransform GetRectTransform(this Object obj)
    {
        GameObject gameObject = obj.GetGameObject();
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        if (rectTransform == null) {
            rectTransform = gameObject.AddComponent<RectTransform>();
        }
        return rectTransform;
    }

    //
    // set and get size (height and width) of UnityEngine Object
    //
    public static void SetSize(this Object obj, Vector2 size)
    {
        obj.GetRectTransform().sizeDelta = size;
    }

    public static void SetSize(this Object obj, float width, float height)
    {
        obj.SetSize(new Vector2(width, height));
    }

    public static float GetHeight(this Object obj)
    {
        return obj.GetRectTransform().sizeDelta.y;
    }

    public static float GetWidth(this Object obj)
    {
        return obj.GetRectTransform().sizeDelta.x;
    }

    //
    // return true if objA is wholly inside objB
    //
    public static bool AinsideB(RectTransform objA,
                                RectTransform objB)
    {
        Vector3[] aCorners = new Vector3[4];
        objA.GetWorldCorners(aCorners);

        Vector3[] bCorners = new Vector3[4];
        objB.GetWorldCorners(bCorners);

        if (aCorners[0].x >= bCorners[0].x &&
            aCorners[2].x <= bCorners[2].x &&
            aCorners[0].y >= bCorners[0].y &&
            aCorners[2].y <= bCorners[2].y) {
            return true;
        }

        return false;
    }

    public static bool AinsideB(Object objA, Object objB)
    {
        return AinsideB(objA.GetRectTransform(), objB.GetRectTransform());
    }

    // attach to parent, and set width and height to 1
    public static RectTransform AttachChild(GameObject parent, GameObject child)
    {
        RectTransform rectTransform = child.GetRectTransform();
        rectTransform.SetParent(parent.transform);
        rectTransform.sizeDelta = new Vector2(1, 1);

        return rectTransform;
    }
}