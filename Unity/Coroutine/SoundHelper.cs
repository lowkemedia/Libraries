//
//  SoundHelper
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

public class SoundHelper : MonoBehaviour
{
    public delegate void Callback();

    private static SoundHelper _instance;

    public void Start()
    {
        _instance = this;
    }

    // TODO: Give warning if _instance is destroyed while callback still pending
    // TODO: keep dictionary of SoundCallback calls
    // TODO: Add cancel() and trigger() functionality

    // StartCoroutine is a MonoBehaviour method
    //  so SoundHelper must depend on an a MonoBehaviour
    private static SoundHelper Instance {
        get {
            if (_instance == null) {
                Logger.Warning("SoundHelper must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    // TODO: Make callback a UnityEvent ?
    public static void SoundCallback(AudioSource sound, Callback callback, bool giveWarning = true)
    {
        if (giveWarning) {
            if (sound == null) {
                Logger.Warning("SoundCallback() called with an empty sound parameter");
            }
            if (callback == null) {
                Logger.Warning("SoundCallback() called with an empty callback parameter");
            }
        }

        Instance.DoSoundCallback(sound, callback);
    }

    public void DoSoundCallback(AudioSource sound, Callback callback)
    {
        if (sound != null) {
            sound.Play();
            StartCoroutine(InvokeAfterSound(sound, callback));
            return;
        }

        callback?.Invoke();
    }

    IEnumerator InvokeAfterSound(AudioSource sound, Callback callback)
    {
        sound.Play();
        yield return new WaitWhile(() => sound.isPlaying);

        callback?.Invoke();
    }
}