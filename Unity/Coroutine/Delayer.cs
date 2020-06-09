//
//  Delayer
//  Russell Lowke, April 28th 2020
//
//  Copyright (c) 2020 Lowke Media
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

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Delayer : MonoBehaviour
{
    public delegate void Callback();

    private static Delayer _instance;

    public void Start()
    {
        _instance = this;
    }

    // TODO: keep dictionary of Delay calls
    // TODO: Give warning if _instance is destroyed while callback still pending
    // TODO: Add cancel() and trigger() functionality

    // StartCoroutine is a MonoBehaviour method
    //  so Delayer must depend on an a MonoBehaviour
    private static Delayer Instance {
        get {
            if (_instance == null) {
                Logger.Warning("Delayer must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    // TODO: Make callback a UnityEvent? Overload Delay with UnityEvent callback?
    public static void Delay(float seconds, Callback callback, bool giveWarning = true)
    {
        if (giveWarning) {
            if (seconds <= 0) {
                Logger.Warning("Delay() called with an zero or negative seconds parameter");
            }
            if (callback == null) {
                Logger.Warning("Delay() called with an empty callback parameter");
            }
        }

        Instance.DoDelay(seconds, callback);
    }

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

    public void DoDelay(float seconds, Callback callback)
    {
        if (seconds <= 0) {
            callback?.Invoke();
            return;
        }

        IEnumerator coroutine = InvokeWaitForSeconds(seconds, callback);
        StartCoroutine(coroutine);

        /*
        if (_delays == null) {
            _delays = new List<IEnumerator>();
        }
        _delays.Add(coroutine);
        */
    }

    IEnumerator InvokeWaitForSeconds(float seconds, Callback callback)
    {
        yield return new WaitForSeconds(seconds);

        callback?.Invoke();
    }
}