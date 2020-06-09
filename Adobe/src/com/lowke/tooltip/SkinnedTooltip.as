//
//  SkinnedToolTip v 1.0 - toolTip package
//  Russell Lowke, May 22nd 2013
// 
//  Copyright (c) 2010-2011 Lowke Media
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
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER  
//  DEALINGS IN THE SOFTWARE. 
//
// 

package com.lowke.tooltip
{
    import com.lowke.textSetter.TextSetter;
    import com.lowke.logger.Logger;
    import com.lowke.playFrames.PlayFrames;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.text.TextField;
    
    /**
     * @author Russell Lowke
     */
    public class SkinnedTooltip extends Tooltip
    {
        // text constants
        public static const TEXT_WRAPPER:String = "textWrapper";
        public static const TEXT_FIELD:String = "textField";
        
        private static var _view:Sprite;            // "skin" used for displaying Tooltip
        private static var _fps:Number;             // fps to play the skin.
        
        public static function addToolTip(displayObject:DisplayObject,
                                          message:String,
                                          useMousePosition:Boolean = false,
                                          duration:int = USE_DEFAULT):Tooltip 
        {   
            return new SkinnedTooltip(displayObject, message, useMousePosition, duration);
        }
        
        public function SkinnedTooltip(displayObject:DisplayObject, 
                                    message:String,
                                    useMousePosition:Boolean = false, 
                                    duration:int = USE_DEFAULT)
        {
            super(displayObject, message, useMousePosition, duration);
            
            // remove traditional box and the text field
            removeChild(_box);
            removeChild(_textField);
        }
        
        override public function showToolTip():void 
        {
            if (! _view) 
            {
                Logger.warning("ToolTipClip view for skinning has not been set yet.  ToolTipClip cannot display properly.", Tooltip.WARNING_SKIN_NOT_SET);
                return;
            }
            
            var movieClip:MovieClip = _view as MovieClip;
            var tooltipTextField:TextField = this.textField;
            if (tooltipTextField)
            {
                if (movieClip)
                {
                    // the final frame will have the TextField in its ideal state
                    movieClip.gotoAndStop(movieClip.totalFrames);
                }
                TextSetter.setSpriteField(_view, tooltipTextField, message);
            }
            else
            {
                Logger.warning("ToolTipClip could not find TextField on tooltip skin.", Tooltip.WARNING_SKIN_NOT_SET);
            }
            
            // show the skinned view sprite
            addChild(_view);
            
            _view.mouseEnabled = false;
            _view.mouseChildren = false;
            
            
            if (movieClip && movieClip.totalFrames > 1) 
            {
                PlayFrames.play(movieClip, PlayFrames.FIRST_FRAME, PlayFrames.LAST_FRAME, _fps);
            } 
            
            super.showToolTip();
        }
        
        
        /** Convenience method for getting textField on the button. */
        public function get textField():TextField
        {
            var textField:TextField;
            
            // if there's no view then there's no textField
            if (! _view) 
            {
                return null;
            }
            
            // 1st check for text field on specific textWrapper
            var textWrapper:MovieClip = _view[TEXT_WRAPPER];
            if (textWrapper) 
            {
                textField = searchForTextField(textWrapper);
                if (textField) 
                {
                    return textField;
                }
            }
            
            // 2nd check for text field on the view
            textField = searchForTextField(_view);
            if (textField) 
            {
                return textField;
            }
            
            return null;
        }
        
        private function searchForTextField(sprite:Sprite):TextField
        {
            var textField:TextField = sprite[TEXT_FIELD];
            if (textField) 
            {
                return textField;
            } 
            else 
            {
                // return 1st TextField on the sprite
                for (var i:uint = 0; i < sprite.numChildren; ++i) 
                {
                    if (sprite.getChildAt(i) is TextField) 
                    {
                        return sprite.getChildAt(i) as TextField;
                    }
                }
            }
            
            return null;
        }
        
        public static function get view():Sprite
        {
            return _view;
        }
        
        public static function get fps():Number
        {
            return _fps;
        }
        
        public static function set view(value:Sprite):void
        {
            _view = value;
        }
        
        public static function set fps(value:Number):void
        {
            _fps = value;
        }
        
    }
}