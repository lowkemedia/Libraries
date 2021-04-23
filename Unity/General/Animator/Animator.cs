//
//  Animator v 2.0 - Animator package
//  Russell Lowke, May 8th 2020
//
//  Copyright (c) 2006-2020 Lowke Media
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

using System.Collections.Generic;
using UnityEngine;
using AnimatorTypes;
using CallbackTypes;

public class Animator : MonoBehaviour
{
    private static Animator _instance;

    private Dictionary<GameObject, Anime> _animeDict;   // dictionary of Anime objects, for fast lookup
    private List<Anime> _animeList;                     // List of Anime objects, for fast iteration
    private float _updateTime = 0f;                     // time when update was last called
    private float _timePassed = 0f;                     // time between updates

    public static Animator Instance {
        get {
            if (_instance is null) {
                Logger.Warning("Animator must be attached to the Unity scene to work.", LogID.WARNING_ANIMATOR_NOT_ATTACHED);
            }

            return _instance;
        }
    }

    public Animator()
    {
        _instance = this;
        _animeDict = new Dictionary<GameObject, Anime>();
        _animeList = new List<Anime>();
    }

    public void Start()
    {
        // TODO: WebGL has issues with targetFrameRate = 60
        Application.targetFrameRate = 60;

        // change 0.2 into 1/60 ~ 0.01666667. 
        Time.fixedDeltaTime   = 0.01666666f;     // Sets to 60 fps
        Time.maximumDeltaTime = 0.05f;           // Sets worse case to 20 fps
        // https://docs.unity3d.com/Manual/class-TimeManager.html
    }

    // FixedUpdate is a MonoBehaviour alternatuve to Update(),
    //  and called once per frame
    public void FixedUpdate()
    {
        // Update all Anime objects in Animator, performing all effects attached to Animes.

        float updateTime = Time.time;
        _timePassed = updateTime - _updateTime;
        _updateTime = updateTime;

        // make a copy, as _animeList can modify during iteration 
        List<Anime> shallowCopy = new List<Anime>(_animeList);

        foreach (Anime anime in shallowCopy) {
            anime.Update(_updateTime);
        }
    }

    //
    // Returns an anime instance linked to the target. If one does not exist yet then one is created.
    // Anime() is typically used to create and get Anime objects.
    //
    // Note: Anime instances without any Effects attached will automatically be removed on the next Update().
    // To prevent this, set the Anime's _persist flag to true.</p>
    //
    public Anime Anime(GameObject target)
    {
        if (target is null) {
            target = gameObject;
        }

        // try to get the Anime
        Anime anime = GetAnime(target);

        // if no Anime found then create a new one
        if (anime is null)
        {
            anime = new Anime(this, target);
            _animeDict[target] = anime;
            _animeList.Add(anime);
        }

        return anime;
    }

    //
    // Returns the Anime object linked to the target, if any.
    //
    public Anime GetAnime(GameObject target)
    {
        bool found = _animeDict.TryGetValue(target, out Anime anime);
        return anime;
    }

    //
    // The name string can be set to use a unique effect name ID, 
    //  or use REPLACE to replace any effect with the same name ID, 
    //  or use SNAP_REPLACE to replace and snap to end any effect with the same name ID,
    //  or AUTO_RENAME to automatically create a new and unique name ID
    //
    public AnimatorEffect AddEffect(AnimatorEffect effect,
                                    Callback callback = null,
                                    string name = EffectString.REPLACE)
    {
        return Anime(null).AddEffect(effect, callback, name);
    }

    //
    // Removes any anime linked to the target GameObject.
    public void Remove(GameObject target, bool snapToEnd = false)
    {
        Anime anime = GetAnime(target);
        if (anime != null)
        {
            anime.ClearEffects(snapToEnd);
            _animeDict.Remove(target);
            _animeList.Remove(anime);
        }
    }

    //
    // Clears all Anime in Animator
    public void Clear(bool snapToEnd = false)
    {
        while (_animeList.Count > 0) {
            Remove(_animeList[0].Target, snapToEnd);
        }
    }

    // Give warning if _instance is destroyed while animations are pending
    private void OnDestroy()
    {
        if (_animeList.Count > 0) {
            Logger.Warning("Animator destroyed while still animating.", LogID.WARNING_ANIMATOR_DESTROYED_WHILE_ANIMATING);
        }
    }


    public override string ToString()
    {
        return DumpAnime();
    }

    public string DumpAnime()
    {
        string str = "";
        foreach (Anime anime in _animeList) {
            str += anime.ToString();
        }

        return str;
    }

    public float UpdateTime
    {
        get { return _updateTime; }
    }

    public float TimePassed
    {
        get { return _timePassed; }
    }
}
