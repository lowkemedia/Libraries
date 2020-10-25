//
//  Anime v 2.0 - Animator package
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

using System;
using System.Collections.Generic;
using UnityEngine;
using AnimatorTypes;

// TODO: Anime should be a Coroutine for better performance

public class Anime
{
    private Animator _animator;
    private GameObject _target;
    private List<AnimatorEffect> _effects;
    private bool _persist = false;      // when true, this anime isn't automatically removed when without Effects

    public Anime(Animator animator, 
                 GameObject gameObject)
    {
        _animator = animator;
        _target = gameObject;
        _effects = new List<AnimatorEffect>();
    }

    public void Update(float updatetime)
    {
        // if there are no effects on anime then remove the anime
        if (_effects.Count == 0 && !_persist) {
            Remove();
        } else
        {
            // iterate through effects
            List<AnimatorEffect> shallowCopy = new List<AnimatorEffect>(_effects);
            foreach(AnimatorEffect effect in shallowCopy) {
                effect.Update(updatetime);
            }
        }
    }


    //
    // The name string can be set to use a unique effect name ID, 
    //  or use REPLACE to replace any effect with the same name ID, 
    //  or use SNAP_REPLACE to replace and snap to end any effect with the same name ID,
    //  or AUTO_RENAME to automatically create a new and unique name ID
    //
    public AnimatorEffect AddEffect(AnimatorEffect effect,              // effect being added
                                    Callback callback = null,           // callback to call when done.
                                    string name = EffectString.REPLACE) // name of effect, or use REPLACE, SNAP_REPLACE or AUTO_RENAME
    {
        //
        // name effect
        //  Note: renaming efects allows you to stack effects of the same type
        if (name != null && 
            name != EffectString.REPLACE && 
            name != EffectString.SNAP_REPLACE &&
            name != EffectString.AUTO_RENAME) 
        {
            effect.Name = name;
        }

        //
        // deal with any existing effect with the same name
        AnimatorEffect existingEffect = GetEffect(effect.Name, false);
        if (existingEffect != null) 
        {
            if (name == EffectString.REPLACE || 
                name == EffectString.SNAP_REPLACE) 
            {
                Logger.Debug("Effect \"" + effect.Name + "\" being replaced on anime " + _target, LogID.DEBUG_EFFECT_BEING_REPLACED);

                // remove existing effect so no conflict occurs
                RemoveEffect(existingEffect, (name == EffectString.SNAP_REPLACE));
                
            } else if (name == EffectString.AUTO_RENAME) 
            {
                // rename effect so no conflict occurs
                int counter = 1;
                string newName;
                do {
                    ++counter;
                    newName = effect.Name + "_" + counter;
                } while (GetEffect(newName, false) != null);
                
                effect.Name = newName;
            } 
            else 
            { 
                // can't replace existing effect
                throw new Exception("Effect \"" + effect.Name + "\" already exists on anime " + _target +  ".\n" +
                    "Rename your effect, or remove the existing effect using removeEffect(), before adding your new effect.");
            }
        }

        _effects.Add(effect);
        effect.Callback = callback;
        effect.Initailize(_animator, this);

        return effect;
    }

    // add effect to an anime that triggers on a timestamp, 
    //  which may be past or persent.
    public AnimatorEffect TimedEffect(AnimatorEffect effect, 
                                      float timestamp,
                                      Callback callback = null,
                                      string name = EffectString.REPLACE)
    {
        effect.StartTime = timestamp;
        return AddEffect(effect, callback, name);
    }

    // add effect to anime that cycles a number of times.
    public AnimatorEffect CycleEffect(AnimatorEffect effect,
                                      int cycles,
                                      Callback callback = null,
                                      string name = EffectString.REPLACE)
    {
        effect.Cycles = cycles;
        return AddEffect(effect, callback, name);
    }


    //
    // get effect from effects list by name
    public AnimatorEffect GetEffect(string effectName,
                                    bool giveWarning = true) 
    {
        foreach(AnimatorEffect effect in _effects) {
            if (effect.Name == effectName) {
                return effect;
            }
        }
            
        if (giveWarning) {
            Logger.Warning("Could not find effect \"" + effectName + "\" on " + _target + ".\n" +
                         "Effects that were found were the following: " + DumpEffects() + ".", LogID.WARNING_CANT_FIND_EFFECT);
        }
            
        return null;
    }
        
        
    //
    // remove any effects containing str in name
    //  if no str passed then clear effects
    public void RemoveEffects(string str = null,
                              bool snapToEnd = false)
    {   
        if (str is null) {
            ClearEffects(snapToEnd);
        } else 
        {
            List<AnimatorEffect> shallowCopy = new List<AnimatorEffect>(_effects);
            foreach (AnimatorEffect effect in shallowCopy) {
                if (effect.Name.IndexOf(str, StringComparison.Ordinal) != -1) {
                    RemoveEffect(effect, snapToEnd);
                }
            }
        }
    }
        
        
    public void RemoveEffect(string effectName,
                             bool snapToEnd = false,
                             bool giveWarning = true)
    {
        AnimatorEffect effect = GetEffect(effectName, giveWarning);
        if (effect != null) {
            RemoveEffect(effect, snapToEnd);
        }
    }

    //
    // remove specific effect
    public void RemoveEffect(AnimatorEffect effect,
                             bool snapToEnd = false,
                             bool giveWarning = true)
    {
        // ensure effect in effects list
        int index = _effects.IndexOf(effect);
        if (index != -1)
        {
            if (snapToEnd) {
                effect.SnapEffectToEnd();
            }

            effect.Cleanup();

            // delete from _effects list
            _effects.Remove(effect);

        } else if (giveWarning) {
            Logger.Warning("Could not remove effect \"" + effect.Name + "\" on " + _target + ".\n" +
                           "Effects that were found were the following: " + DumpEffects() + ".", LogID.WARNING_CANT_REMOVE_EFFECT);
        }
    }
        
        
    //
    // clear all effects on this anime
    public void ClearEffects(bool snapToEnd = false) 
    {
        // remove all effects
        while (_effects.Count > 0) {
            RemoveEffect(_effects[0], snapToEnd);
        }
    }
        
        
    //
    // remove this anime
    public void Remove() 
    {   
        // tell Animator to delete reference
        _animator.Remove(_target);
    }  

    //
    // not only remove the anime, but destroy its target GameObject
    public void Destroy() 
    {
        Remove();
        UnityEngine.Object.Destroy(_target);
    }

    //
    // print anime with list of effects
    public override string ToString()
    {
        return _target +  " effects:" + DumpEffects() + "\n";
    }

    public string DumpEffects() 
    {   
        int nEffects = _effects.Count;
        if (nEffects == 0) 
        {
            return "[ none ]";
        }
        
        // iterate through effects
        string str = "";
        for (int i = 0; i < nEffects; ++i) 
        {
            if (i == 0)
            { 
                str += "[ "; 
            }
            str += _effects[i];
            str += (i == (nEffects - 1)) ? " ]" : ", ";
        }
        
        return str;
    }


    //
    // Getters and Setters
    //

    public GameObject Target
    {
        get { return _target; }
        set { _target = value; }
    }

    public bool Persist
    {
        get { return _target; }
        set { _persist = value; }
    }
}
