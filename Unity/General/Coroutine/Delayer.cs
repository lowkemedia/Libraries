//
//  Delayer
//  Russell Lowke, April 28th 2020
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

public class Delayer : MonoBehaviour
{
    private static Delayer _instance;

    public void Awake()
    {
        if (_instance != null) {
            Logger.Warning("Delayer should only be attached once.");
            return;
        }
        _instance = this;
    }

    private static Delayer Instance {
        get {
            if (_instance is null) {
                throw new Exception("Delayer must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    //
    // allow space for mouse clicks to flush, and updates be called
    public static void DoNext(Callback callback)
    {
        // wait 1/10th to allow Update() on MonoBehaviours
        // TODO: find a cleaner way to ensure an Update()
        Instance.DoDelay(0.1f, callback);
    }

    public static void Delay(float seconds, Callback callback, bool giveWarning = true)
    {
        if (giveWarning) {
            if (seconds <= 0) {
                Logger.Warning("Delay() called with an zero or negative seconds parameter");
            }
            if (callback is null) {
                Logger.Warning("Delay() called with an empty callback parameter");
            }
        }

        if (seconds <= 0) {
            callback?.Invoke();
            return;
        }

        Instance.DoDelay(seconds, callback);
    }

    // StartCoroutine() requires a MonoBehaviour instance
    protected void DoDelay(float seconds, Callback callback)
    {
        IEnumerator coroutine = InvokeWaitForSeconds(seconds, callback);
        StartCoroutine(coroutine);
    }

    private IEnumerator InvokeWaitForSeconds(float seconds, Callback callback)
    {
        yield return new WaitForSeconds(seconds);

        callback?.Invoke();
    }


    // TODO: keep dictionary of Delay calls
    // TODO: Give warning if _instance is destroyed while callback still pending
    // TODO: Add cancel() and trigger() functionality

    /*
    private List<IEnumerator> _delays;

    //
    // basically  StopAllCoroutines();
    private void KillDelays()               
    {
        if (_delays != null) {
            foreach (IEnumerator delay in _delays) {
                StopCoroutine(delay);
            }
        }
        _delays = null;
    }
    */
}