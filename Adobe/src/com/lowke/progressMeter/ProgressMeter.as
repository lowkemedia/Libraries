//
//  ProgressMeter v 1.03 - progressMeter package
//  Russell Lowke, January 28th 2011
// 
//  Copyright (c) 2009-2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
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
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE. 
//
//

package com.lowke.progressMeter
{   
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.tween.TweenFX;
    import com.lowke.animator.effect.tween.easing.ParabolaEasing;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.media.Sound;
    import flash.text.TextField;
    
    /**
     * ProgressMeter v 1.03<br>
     * <p>Russell Lowke, January 28th 2011</p>
     * 
     * ProgressMeter is a base class for dealing with various meters that need
     * to animate when their values change.
     */
    public class ProgressMeter extends EventDispatcher 
    {   
        // constants used for type variable
        public static const PERCENT:String              = "displayAsPercent";
        public static const DOLLARS:String              = "displayAsDollars";
        public static const DOLLARS_AND_CENTS:String    = "displayAsDollarsAndCents";
        public static const VALUE:String                = "displayValue";
        public static const VALUE_AND_MAX:String        = "displayValueAndMaximum";
        
        // event dispatched after progess bar finsihed animating
        public static const ANIMATION_DONE:String       = "progressMeterAnimationDone";
        
        
        private var _ani:Animator = Animator.instance;  // animator
        
        private var _value:Number;                      // current value of the progress bar
        private var _displayValue:Number;               // current display value of the progress bar, used for animation
        private var _animDuration:uint;                 // duration of animation when changing values
        private var _displayType:String;                // either PERCENT, VALUE, or VALUE_AND_MAX
        
        private var _textField:TextField;               // filed used for displaying value, can be null
        protected var _maxValue:Number = NaN;           // maximum value for progress bar, defaults NaN (none);
        private var _minValue:Number = 0;               // minimum value for progress bar, defaults 0;
        
        private var _changeSound:Sound;                 // sound triggered when meter changes
        private var _warningThreshold:Number;           // threshold below which text color changes
        private var _normalTextColor:uint;              // color of text when normal
        private var _warningTextColor:uint = 0xFF0000;  // color of text when in warning
        
        
        public function ProgressMeter(textField:TextField) 
        {   
            _textField = textField;
            if (_textField) 
            {
                _normalTextColor = _textField.textColor;
            }
            _displayType = VALUE;
            _animDuration = 800;
            this.value = 0;
        }
        
        // convenience call for changing the meter by an amount
        public function changeVal(value:Number):void 
        {
            valTo(_value + value);
        }
        
        public function valTo(value:Number, duration:int = -1):void 
        {
            if (duration == -1) 
            {
                // use default animation speed
                duration = _animDuration;
            }
            _value = capValue(value);
            _ani.anime(this).addEffect(new TweenFX("dValue", NaN, _value, duration, ParabolaEasing.easeOut)).whenDone(dispatchReady);
        }
        
        private function dispatchReady():void 
        {
            dispatchEvent(new Event(ANIMATION_DONE));
        }
        
        public function set value(value:Number):void 
        {
            _value = capValue(value);
            _ani.anime(this).removeEffects();
            dValue = _value;
        }
        
        private function capValue(value:Number):Number 
        {
            if (value > _maxValue) 
            {
                value = _maxValue;
            } 
            else if (value < _minValue) 
            {
                value = _minValue;
            }
            
            return value;
        }
        
        public function set dValue(value:Number):void 
        {
            if (_displayValue != value) 
            {
                _displayValue = value;
                if (_changeSound) 
                {
                    _changeSound.play();
                }
                update();
            }
        }
        
        protected function update():void 
        {   
            // update text field
            if (_textField) 
            {
                var str:String;
                var value:Number;
                switch (_displayType) 
                {
                    case PERCENT:
                        value = Math.round(this.dPercent*100);
                        str = value + "%";
                        break;
                    case DOLLARS:
                        str = toDollars(_displayValue);
                        break;
                    case DOLLARS_AND_CENTS:
                        str = toDollars(_displayValue, true);
                        break;
                    case VALUE_AND_MAX:
                        value = Math.round(_displayValue);
                        str = value + "/" + _maxValue;
                        break;
                    case VALUE:
                    default:
                        value = Math.round(_displayValue);
                        str = String(value);
                        break;
                }
                
                if (_textField.text != str) 
                {
                    if (! isNaN(_warningThreshold)) 
                    {
                        if (value > _warningThreshold) 
                        {
                            _textField.textColor = _normalTextColor;
                        } 
                        else 
                        {
                            _textField.textColor = _warningTextColor;
                        }
                    }
                    
                    _textField.text = str;
                }
            }
        }
        
        private function toDollars(value:Number, 
                                   andCents:Boolean = false):String 
        {
            var cents:String = "";
            if (andCents) 
            {
                // save the cents ".00" into a string
                cents = value.toFixed(2);
                cents = cents.substr(cents.length - 3, 3);
            }
            
            var nStr:String = "";
            var str:String = "" + Math.round(value);  // dollars
            while (str.length > 3) 
            {
                nStr = "," + str.substr(str.length - 3, 3) + nStr;
                str = str.substr(0, str.length - 3);
            }
            nStr = str + nStr;
            
            return "$" + nStr + cents;
        }
        
        public function set percent(value:Number):void 
        {
            if (isNaN(_maxValue)) 
            {
                this.value = 0;
            } 
            else 
            {
                this.value = value*_maxValue;
            }
        }
        
        public function get percent():Number 
        {
            if (isNaN(_maxValue)) 
            {
                return 1;
            } 
            else 
            {
                return _value/_maxValue;
            }
        }
        
        public function get dPercent():Number 
        {
            if (isNaN(_maxValue)) 
            {
                return 1;
            } 
            else 
            {
                return _displayValue/_maxValue;
            }
        }
        
        // accessors and mutators
        public function get value():Number                      { return _value; }
        public function get dValue():Number                     { return _displayValue; }
        public function get minValue():Number                   { return _minValue; }
        public function get maxValue():Number                   { return _maxValue; }
        public function get displayType():String                { return _displayType; }
        public function get animDuration():uint                 { return _animDuration; }
        public function get changeSound():Sound                 { return _changeSound; }
        
        public function set minValue(value:Number):void           { _minValue = value; }
        public function set maxValue(value:Number):void           { _maxValue = value; update(); }
        public function set displayType(value:String):void        { _displayType = value; update(); }
        public function set animDuration(value:uint):void         { _animDuration = value; }
        public function set changeSound(value:Sound):void         { _changeSound = value; }
        public function set warningThreshold(value:Number):void   { _warningThreshold = value; }
        public function set warningTextColor(value:uint):void     { _warningTextColor = value; }
    }
}