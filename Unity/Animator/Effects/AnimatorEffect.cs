//
//  AnimatorEffect v 2.0 - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2009-2019 Lowke Media
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
using AnimatorTypes;


public abstract class AnimatorEffect
{
    private const int DONT_CYCLE = 0;

    protected string _name;                 // name of this effect
    protected Animator _animator;           // animator
    protected Anime _anime;                 // anime object owning the effect
    protected GameObject _target;           // target object being affected
    protected EffectType _type;             // effect type, PERSIST, END, REMOVE, DESTROY, CYCLE or REVERSE
    protected float _startTime = float.NaN; // time effect starts, might be time-stamped future or past time
    protected float _updateTime;            // time of this update
    protected float _timePassed;            // time between updates
    protected int _cycles = DONT_CYCLE;     // # of cycles before ending effect
    protected Callback _callback;           // callback function to call when tween ends

    protected AnimatorEffect(string name, EffectType type)
    {
        _name = name;
        _type = type;
    }

    public void Initailize(Animator animator,
                           Anime anime)
    {
        _animator = animator;
        _anime = anime;
        _updateTime = Time.time;

        // target is usually the anime's target, 
        //  though may have been set to an alternative
        if (_target == null) {
            _target = _anime.Target;
        }

        // TimedEffect() may have set the _startTime
        if (float.IsNaN(_startTime)) {
            _startTime = _updateTime;
        }

        Initialize();
        Update(_updateTime);
    }

    public bool Update(float updateTime)
    {
        // calculate time passed since last update
        _timePassed = updateTime - _updateTime;

        // record time of update
        _updateTime = updateTime;

        if (_updateTime < _startTime) {
            // this effect is not ready to trigger yet, exit
            return false;
        }

        // perform effect!
        bool resolved = Update();

        if (resolved)
        {
            // check for cycling effects
            if (_cycles != DONT_CYCLE)
            {
                --_cycles;
                if (_cycles <= 0) {
                    _type = EffectType.END;
                }

                // can't cycle end, remove, or destroy types
                if (_type == EffectType.END ||
                    _type == EffectType.REMOVE ||
                    _type == EffectType.DESTROY) {
                    _cycles = DONT_CYCLE;
                }
            }

            // when effect finishes
            switch (_type)
            {
                case EffectType.PERSIST: 
                    break;
                case EffectType.END:            // remove this effect (thereby ending it)
                    Remove(); 
                    break;
                case EffectType.REMOVE:         // remove Anime from animator (ending all effects)
                    _anime.Remove(); 
                    break;
                case EffectType.DESTROY:        // destroy target GameObject
                    _anime.Destroy(); 
                    break;
                case EffectType.CYCLE:
                    Cycle(); 
                    break;
                case EffectType.REVERSE:
                    Reverse(); 
                    break;
            }

            // if finished cycles then trigger callback
            if (_cycles == DONT_CYCLE) {
                TriggerCallback();
            }
        }

        return resolved;
    }

    public void Remove(bool snapToEnd = false,
                       bool giveWarning = true)
    {
        _anime.RemoveEffect(this, snapToEnd, giveWarning);
    }

    public void SnapEffectToEnd()
    {
        SnapToEnd();
        TriggerCallback();
    }

    //
    // called by Anime.as immediately after calling snapToEnd();
    public void TriggerCallback() 
    {
        _callback?.Invoke();
    }

    //
    // primary methods for override
    //

    protected abstract void Initialize();

    protected abstract bool Update();

    protected abstract void SnapToEnd();

    //
    // secondary methods for override

    public virtual void Cleanup()
    {
        // some effects will need a Cleanup()
    }

    public virtual void Cycle()
    {
        Logger.Warning("Effect " + _name + " does not support Cycle() method.", LogID.WARNING_CYCLE_NOT_SUPPORTED);
    }
        
    public virtual void Reverse()
    {
        Logger.Warning("Effect " + _name + " does not support Reverse() method.", LogID.WARNING_REVERSE_NOT_SUPPORTED);
    }

    /*
    public virtual void Pause()
    {
        Ticker.Print("WARNING: Effect " + _name + " does not support Pause() method.");
    }
    */

    public override string ToString() 
    {
        return _name;
    }


    //
    // Getters and Setters
    //

    public string Name
    {
        get { return _name; }
        set { _name = value; }
    }

    public EffectType Type
    {
        get { return _type; }
        set { _type = value; }
    }

    public int Cycles
    {
        get { return _cycles; }
        set { _cycles = value; }
    }

    public float StartTime
    {
        get { return _startTime; }
        set { _startTime = value; }
    }

    public Callback Callback
    {
        get { return _callback; }
        set { _callback = value; }
    }
}
