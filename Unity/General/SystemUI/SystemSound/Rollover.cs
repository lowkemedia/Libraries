//
// Rollover - a quiet synthesized runtime pointer sound, independent of gameplay audio.
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

public sealed class Rollover : MonoBehaviour
{
    private static Rollover _instance;
    private AudioSource _source;
    private AudioClip _clip;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void ResetSession() { _instance = null; }

    // Main-thread Play Mode access only; obtaining the clip does not play it.
    // The persistent host owns this shared clip. Do not modify or destroy it.
    public static AudioClip Clip => Application.isPlaying ? Instance.GetClip() : null;

    public static void Play()
    {
        if (!Application.isPlaying) { return; }
        Instance.PlayGeneratedRollover();
    }

    private static Rollover Instance {
        get {
            if (_instance == null) {
                _instance = FindObjectOfType<Rollover>();
                if (_instance == null) { _instance = new GameObject("Rollover").AddComponent<Rollover>(); }
                DontDestroyOnLoad(_instance.gameObject);
            }
            return _instance;
        }
    }

    private AudioClip GetClip()
    {
        if (_clip == null) {
            const int sampleRate = 32000;
            const int samples = 241; // About 7.5 ms: shorter, brighter and quieter than Click.
            // Shared AudioSource.Play calls restart this silence during rapid pointer sweeps.
            const int leadInSamples = 1120; // 35 ms before the audible tick.
            var data = new float[leadInSamples + samples];
            var noise = new System.Random(0);
            float previousNoise = 0f;
            for (int i = 0; i < samples; i++) {
                float remaining = 1f - i / (float)(samples - 1);
                // Round off only the first millisecond, retaining the original noise and decay.
                float attack = Mathf.Min(1f, i / 32f);
                attack = attack * attack * (3f - 2f * attack);
                float envelope = attack * remaining * remaining * remaining;
                float sample = (float)(noise.NextDouble() * 2.0 - 1.0);
                // Click's crisp noise transient, at a higher sample rate and lower level.
                data[leadInSamples + i] = 0.14f * envelope * (sample - previousNoise) * 0.5f;
                previousNoise = sample;
            }
            _clip = AudioClip.Create("Synthesized rollover", data.Length, 1, sampleRate, false);
            _clip.SetData(data, 0);
        }
        return _clip;
    }

    private void PlayGeneratedRollover()
    {
        AudioClip clip = GetClip();
        if (_source == null) {
            _source = gameObject.AddComponent<AudioSource>();
            _source.playOnAwake = false;
            _source.spatialBlend = 0f;
            _source.ignoreListenerPause = true;
        }
        _source.PlayOneShot(clip);
    }

    private void OnDestroy()
    {
        if (_instance == this) { _instance = null; }
        if (_source != null) { Destroy(_source); }
        if (_clip != null) { Destroy(_clip); }
    }
}
