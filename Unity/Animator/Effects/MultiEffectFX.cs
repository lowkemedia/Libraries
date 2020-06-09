//
//  MultiEffectFX v 2.0 - Animator package
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

using System.Collections.Generic;
using AnimatorTypes;

public class MultiEffectFX : AnimatorEffect
{
    protected List<AnimatorEffect> _effects;    // list of effects
    private bool[] _doneFlags;                  // array of flags indicating which effects have finished
    private bool _done;                         // indicates if all effects finished

    public MultiEffectFX(List<AnimatorEffect> effects,
                         string name = "MultiEffectFX",
                         EffectType type = EffectType.END) :
    base(name, type)
    {
        _effects = effects;
    }

    protected override void Initialize()
    {
        ClearFlags();

        // add each effect to the _anime
        int counter = 0;
        foreach (AnimatorEffect effect in _effects)
        {
            int index = counter++;
            _anime.TimedEffect(effect, _startTime, delegate { EffectDone(index); }, _name + "/" + effect.Name);
        }
    }

    private void ClearFlags()
    {
        _doneFlags = new bool[_effects.Count];
        _done = false;
    }

    // effect finished
    private void EffectDone(int index)
    {
        // flag effect as done
        _doneFlags[index] = true;

        // if all effects finished then set _done flag to true
        foreach (bool flag in _doneFlags) {
            if (!flag) {
                return;
            }
        }
        _done = true;
    }

    protected override bool Update()
    {
        return _done;
    }

    protected override void SnapToEnd()
    {
        foreach (AnimatorEffect effect in _effects) {
            effect.SnapEffectToEnd();
        }
        _done = true;
    }

    public override void Cleanup()
    {
        foreach (AnimatorEffect effect in _effects) {
            effect.Remove(false, false);
        }
    }

    public override void Cycle()
    {
        ClearFlags();
    }

    public override void Reverse()
    {
        ClearFlags();
    }
}
