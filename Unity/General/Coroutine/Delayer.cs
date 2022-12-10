//
//  Delayer
//  Russell Lowke, December 10th 2022
//
//  Copyright (c) 2020-2022 Lowke Media
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
using System.Collections.Generic;
using System;
using CallbackTypes;

public class Delayer : MonoBehaviour
{
    private static Delayer _instance;

    // queue of callbacks waiting trigger on next Update();
    private Queue<Callback> _doNextCallbacks;

    public void Awake()
    {
        if (_instance != null) {
            Logger.Warning("Delayer should only be attached once.");
            return;
        }

        _doNextCallbacks = new Queue<Callback>();
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

    public void NoNext(Callback callback)
    {
        _doNextCallbacks.Enqueue(callback);
    }

    private void Update()
    {
        if (_doNextCallbacks.Count > 0) {
            Queue<Callback> callbacksQueue = _doNextCallbacks;
            _doNextCallbacks = new Queue<Callback>();
            while (callbacksQueue.Count > 0) {
                Callback callback = callbacksQueue.Dequeue();
                callback?.Invoke();
            }
        }
    }


    //
    // allow space for mouse clicks to flush, and updates be called
    public static void DoNext(Callback callback)
    {
        Instance.NoNext(callback);
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

    // TODO: detect if Delay has been cut short due to change of scene and trigger. Try OnDestroy() perhaps.

    // TODO: async, await, and Task in C# are easier and cleaner to implement than coroutines
    //    e.g.     async public void OpenSocket() { _webSocket = new WebSocket("wss://api..." ...   await _webSocket.Connect();
    // see https://blog.logrocket.com/performance-unity-async-await-tasks-coroutines-c-job-system-burst-compiler/#what-is-async    
    //  Unity yield instructions... WaitForSeconds, WaitForEndOfFrame, WaitUntil, or WaitWhile.
    // TODO: keep list of Delay calls?
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