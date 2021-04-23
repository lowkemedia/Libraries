//
//  SmoothMove
//  Russell Lowke, August 23rd 2020
//
//  Copyright (c) 2020 Lowke Media
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
using System.Collections;
using System;
using CallbackTypes;

public class Mover : MonoBehaviour
{
    private static Mover _instance;

    public void Awake()
    {
        if (_instance != null) {
            Logger.Warning("Mover should only be attached once.");
            return;
        }
        _instance = this;
    }

    private static Mover Instance {
        get {
            if (_instance is null) {
                throw new Exception("Mover must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    public static void SmoothMove(Transform transform, Vector3 endpos, float seconds, Callback callback)
    {
        Vector3 startpos = transform.localPosition;
        Instance.DoSmoothMove(transform, startpos, endpos, seconds, callback);
    }

    // StartCoroutine() requires a MonoBehaviour instance
    private void DoSmoothMove(Transform moveTransform, Vector3 startpos, Vector3 endpos, float seconds, Callback callback)
    {
        IEnumerator coroutine = InvokeSmoothMove(moveTransform, startpos, endpos, seconds, callback);
        StartCoroutine(coroutine);
    }

    IEnumerator InvokeSmoothMove(Transform moveTransform, Vector3 startpos, Vector3 endpos, float seconds, Callback callback)
    {
        float t = 0f;
        while (t <= 1.0) {
            t += Time.deltaTime / seconds;
            moveTransform.localPosition = Vector3.Lerp(startpos, endpos, Mathf.SmoothStep(0f, 1f, t));
            yield return null;
        }

        callback?.Invoke();
    }
}