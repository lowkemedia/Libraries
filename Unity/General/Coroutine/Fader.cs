//
//  Fader
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
using UnityEngine.UI;

public class Fader : MonoBehaviour
{
    public delegate void Callback();

    private static Fader _instance;

    public void Awake()
    {
        if (_instance != null) {
            Logger.Warning("Fader should only be attached once.");
            return;
        }
        _instance = this;
    }

    private static Fader Instance {
        get {
            if (_instance is null) {
                throw new Exception("Fader must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    public static void FadeTextIn(Text text, Color color, float fadeOutTime = 0.333f)
    {
        Instance.DoFadeTextIn(text, color, fadeOutTime);
    }

    // StartCoroutine() requires a MonoBehaviour instance
    private void DoFadeTextIn(Text text, Color color, float fadeOutTime)
    {
        text.color = color;
        IEnumerator coroutine = InvokeFadeTextColor(text, Color.clear, text.color, fadeOutTime);
        StartCoroutine(coroutine);
    }

    private IEnumerator InvokeFadeTextColor(Text text, Color sourceColor, Color targetColor, float fadeOutTime)
    {
        for (float t = 0.01f; t < fadeOutTime; t += Time.deltaTime) {
            text.color = Color.Lerp(sourceColor, targetColor, Mathf.Min(1, t / fadeOutTime));
            yield return null;
        }
    }
}