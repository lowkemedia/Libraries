//
// Click - a synthesized runtime button sound, independent of gameplay audio.
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
public sealed class Click : MonoBehaviour
{
    private static Click _instance;
    private AudioSource _clickSource;
    private AudioClip _clickClip;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void ResetSession()
    {
        _instance = null;
    }

    // Call on Unity's main thread during Play Mode. No prefab or SoundHelper is needed.
    public static void Play()
    {
        if (!Application.isPlaying) { return; }
        if (_instance == null) {
            // Reuse the host when the Editor has disabled scene/domain reload.
            _instance = FindObjectOfType<Click>();
            if (_instance == null) {
                _instance = new GameObject("Click").AddComponent<Click>();
            }
            DontDestroyOnLoad(_instance.gameObject);
        }
        _instance.PlayGeneratedClick();
    }

    private void PlayGeneratedClick()
    {
        if (_clickClip == null) {
            const int sampleRate = 22050;
            const int samples = 331; // About 15 ms: an unpitched, percussive snap.
            var data = new float[samples];
            var noise = new System.Random(0); // Repeatable without changing Unity's random state.
            float previousNoise = 0f;
            for (int i = 0; i < samples; i++) {
                float remaining = 1f - i / (float)(samples - 1);
                float envelope = Mathf.Min(1f, i / 5f) * remaining * remaining * remaining;
                float sample = (float)(noise.NextDouble() * 2.0 - 1.0);
                // Emphasize the sharp transient rather than a recognizable musical pitch.
                data[i] = 0.3f * envelope * (sample - previousNoise) * 0.5f;
                previousNoise = sample;
            }
            _clickClip = AudioClip.Create("Synthesized click", samples, 1, sampleRate, false);
            _clickClip.SetData(data, 0);
        }
        if (_clickSource == null) {
            _clickSource = gameObject.AddComponent<AudioSource>();
            _clickSource.playOnAwake = false;
            _clickSource.spatialBlend = 0f;
            _clickSource.ignoreListenerPause = true;
        }
        // Use the scene's listener (including Launch's); respect global volume/mute.
        _clickSource.PlayOneShot(_clickClip);
    }

    private void OnDestroy()
    {
        if (_instance == this) { _instance = null; }
        if (_clickSource != null) { Destroy(_clickSource); }
        if (_clickClip != null) { Destroy(_clickClip); }
    }
}
