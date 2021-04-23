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
using CallbackTypes;

public class SoundHelper : MonoBehaviour
{
    public enum SoundType
    {
        Click,
        Roll,
        Beep
    };

    public AudioSource click;                       // default click sound
    public AudioSource roll;                        // default roll sound
    public AudioSource beep;                        // default beep sound

    private static SoundHelper _instance;

    public static bool IsAvalable {
        get { return _instance != null; }
	}

    public static AudioSource ClickSound {
        get { return Instance.click; }
	}

    public static AudioSource RollSound {
        get { return Instance.roll; }
    }

    public static AudioSource BeepSound {
        get { return Instance.beep; }
    }

    public static void Play(SoundType soundType)
	{
        AudioSource audio = default;
        switch (soundType) {
            case SoundType.Click:
                audio = ClickSound;
                break;
            case SoundType.Roll:
                audio = RollSound;
                break;
            case SoundType.Beep:
                audio = BeepSound;
                break;
        }

        if (audio != default) {
            audio.Play();
        }
    }

    private void Awake()
    {
        if (_instance != null) {
            Logger.Warning("SoundHelper should only be attached once.");
            return;
        }
        _instance = this;
    }

    private static SoundHelper Instance {
        get {
            if (_instance is null) {
                Logger.Warning("SoundHelper must be attached to the Unity scene to work.");
            }

            return _instance;
        }
    }

    public static void SoundCallback(AudioSource sound, Callback callback, bool giveWarning = true)
    {
        if (giveWarning) {
            if (sound is null) {
                Logger.Warning("SoundCallback() called with an empty sound parameter");
            }
            if (callback is null) {
                Logger.Warning("SoundCallback() called with an empty callback parameter");
            }
        }

        Instance.DoSoundCallback(sound, callback);
    }

    // StartCoroutine() requires a MonoBehaviour instance
    protected void DoSoundCallback(AudioSource sound, Callback callback)
    {
        if (sound) {
            sound.Play();
            StartCoroutine(InvokeAfterSound(sound, callback));
            return;
        }

        callback?.Invoke();
    }

    private IEnumerator InvokeAfterSound(AudioSource sound, Callback callback)
    {
        sound.Play();
        yield return new WaitWhile(() => sound.isPlaying);

        callback?.Invoke();
    }
}




/* ClickSound
//
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class ClickSound : MonoBehaviour

{
    public AudioClip sound;
    private Button button { get { return GetComponent<Button>(); } }
    private AudioSource source { get { return GetComponent<AudioSource>(); } }

    // public delegate void Callback();
    // public event Callback OnClicked;


    void Start()
    {
        gameObject.AddComponent<AudioSource>();
        source.clip = sound;
        source.playOnAwake = false;
        button.onClick.AddListener(PlaySound);
        // button.onClick += PlaySound;
        // button.onClick.AddListener(() => PlaySoundParam(1));
        // button.onClick.AddListener(delegate { PlaySoundParam(1); });
    }

    void PlaySound()
    {
        source.PlayOneShot(sound);
    }

    void PlaySoundParam(int i)
    {
        source.PlayOneShot(sound);
    }

    void Destroy()
    {
        button.onClick.RemoveListener(PlaySound);
        // button.onClick -= PlaySound;
    }
}
*/