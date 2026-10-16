//
// Beep - a synthesized runtime notification sound, independent of gameplay audio.
// Copyright (c) 2026 Lowke Media.
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
using UnityEngine;

// Static entry point; the runtime component owns the audio objects and their cleanup.
public sealed class Beep : MonoBehaviour
{
    private static Beep _instance;
    private static float _lastBeepAt = -1f;
    private AudioSource _beepSource;
    private AudioClip _beepClip;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void ResetSession()
    {
        _instance = null;
        _lastBeepAt = -1f;
    }

    // Call on Unity's main thread during Play Mode. No prefab or SoundHelper is needed.
    public static void Play()
    {
        if (!Application.isPlaying) { return; }
        // Unscaled guard prevents duplicate events from one press and overlapping tones.
        float now = Time.realtimeSinceStartup;
        if (now - _lastBeepAt < 0.12f) { return; }
        _lastBeepAt = now;
        if (_instance == null) {
            // Reuse the host when the Editor has disabled scene/domain reload.
            _instance = FindObjectOfType<Beep>();
            if (_instance == null) {
                _instance = new GameObject("Beep").AddComponent<Beep>();
            }
            DontDestroyOnLoad(_instance.gameObject);
        }
        _instance.PlayGeneratedBeep();
    }

    private void PlayGeneratedBeep()
    {
        if (_beepClip == null) {
            const int sampleRate = 22050;
            const int samples = 2205; // 100 ms, with a short fade at either end.
            var data = new float[samples];
            for (int i = 0; i < samples; i++) {
                float envelope = Mathf.Min(1f, Mathf.Min(i, samples - 1 - i) / 110f);
                data[i] = 0.2f * envelope * Mathf.Sin(2f * Mathf.PI * 880f * i / sampleRate);
            }
            _beepClip = AudioClip.Create("Synthesized beep", samples, 1, sampleRate, false);
            _beepClip.SetData(data, 0);
        }
        if (_beepSource == null) {
            _beepSource = gameObject.AddComponent<AudioSource>();
            _beepSource.playOnAwake = false;
            _beepSource.spatialBlend = 0f;
            _beepSource.ignoreListenerPause = true;
        }
        // Use the scene's listener (including Launch's); respect global volume/mute.
        _beepSource.PlayOneShot(_beepClip);
    }

    private void OnDestroy()
    {
        if (_instance == this) { _instance = null; }
        if (_beepSource != null) { Destroy(_beepSource); }
        if (_beepClip != null) { Destroy(_beepClip); }
    }
}
