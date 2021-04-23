//
//  AnimatorTypes - Animator package
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

namespace AnimatorTypes
{
    public delegate float EasingFunct(float time,
                               float begin,
                               float range,
                               float duration);

    //
    // used for rename string parameter of AddFX() in Anime.as
    //  Note: to name effect being added, use a unique string, otherwise use one of these constants
    public static class EffectString
    {
        // old effect is replaced with new effect [deault]
        public const string REPLACE = "_replace_";

        // old effect snaps to end, triggering any callback, and is then replaced with new effect
        public const string SNAP_REPLACE = "_snap_replace_";

        // new effect is renamed using numbered suffix, so it doesn't conflict with old effect
        public const string AUTO_RENAME = "_rename_";           
    }


    public enum EffectType
    {
        PERSIST,                // leave effect in place
        END,                    // end effect by removing effect from the anime
        REMOVE,                 // remove anime along with all effects on it, ending all effects
        DESTROY,                // remove anime AND remove GameObject from parent
        CYCLE,                  // cycle effect back to the beginning
        REVERSE                 // reverse the effect/play effect backwards
    };

    public static class LogID
    {
        //
        // error, warning and info IDs
        public const string LOG_PREFIX = "ANI";
        public const string WARNING_ANIMATOR_NOT_ATTACHED = LOG_PREFIX + "00";
        public const string WARNING_ANIMATOR_DESTROYED_WHILE_ANIMATING = LOG_PREFIX + "01";
        public const string WARNING_CANT_FIND_EFFECT = LOG_PREFIX + "02";
        public const string WARNING_CANT_REMOVE_EFFECT = LOG_PREFIX + "03";
        public const string WARNING_CYCLE_NOT_SUPPORTED = LOG_PREFIX + "04";
        public const string WARNING_REVERSE_NOT_SUPPORTED = LOG_PREFIX + "05";
        public const string DEBUG_EFFECT_BEING_REPLACED = LOG_PREFIX + "06";
    }
}