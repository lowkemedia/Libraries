//
//  MovieClipButton v 2.0 - buttonController package
//  Russell Lowke, September 19th 2011
//
//  Copyright (c) 2008-2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-buttoncontroller/ for code repository
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

package com.lowke.buttonController.flashButtons
{
    import com.lowke.buttonController.ButtonController;
    import com.lowke.buttonController.IStandardButton;
    
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.media.Sound;
    
    /** 
     * MovieClipButton is a useful wrapper for applying the ButtonController 
     *  on clips embedded in Flash.
     */
    public class MovieClipButton extends MovieClip implements IStandardButton
    {
        private var _clip:MovieClip;                        // MovieClip used by the button
        private var _buttonController:ButtonController;     // ButtonController controlling the button
        
        /**
         * MovieClipButton constructor
         * 
         * @param view The MovieClip view used for this button.
         */
        public function MovieClipButton(view:MovieClip = null)
        {
            if (! view) 
            {
                _clip = this;
            } 
            else 
            {
                _clip = view;
                
                // if the view not attached to a parent then
                //  attach it to this MovieClip
                if (! _clip.parent || _clip.parent is Loader) 
                {
                    addChild(_clip);
                }
            }
            
            _buttonController = new ButtonController(_clip);
            
            _clip.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
            _clip.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
            
            super();
        }
        
        
        private function addedToStage(evt:Event):void
        {
            // Flash MovieClip timelines often add items non-programmatically.
            //  It can be very useful to inform the MovieClip parent that 
            //  this button has been added
            if (parent is MovieClip) 
            {
                try 
                {
                    (parent as MovieClip)["buttonAdded"](this);
                } catch (err:Error) {}  
            }
        }
        
        private function removedFromStage(evt:Event):void
        {
            // Flash MovieClip timelines often remove items non-programmatically.
            //  It can be very useful to inform the MovieClip parent that 
            //  this button has been removed
            if (parent is MovieClip) 
            {
                try 
                {
                    (parent as MovieClip)["buttonRemoved"](this);
                } catch (err:Error) {}
            }
        }
        
        /**
         * Passthrough methods
         */
        public function clickButton(pressDuration:uint = 0):void    { _buttonController.clickButton(pressDuration); }
        public function addKey(key:String):void                     { _buttonController.addKey(key); }
        public function addKeyCode(keyCode:int):void                { _buttonController.addKeyCode(keyCode); }
        public function removeKey(key:String):void                  { _buttonController.removeKey(key); }
        public function removeKeyCode(keyCode:int):void             { _buttonController.removeKeyCode(keyCode); }
        public function clearKeys():void                            { _buttonController.clearKeys(); }
        public function set selected(value:Boolean):void            { _buttonController.selected = value; }
        public function set disabledAlpha(value:Number):void        { _buttonController.disabledAlpha = value; }
        public function set clickSound(value:Sound):void            { _buttonController.clickSound = value; }
        public function set rolloverSound(value:Sound):void         { _buttonController.rolloverSound = value; }
        public function set rolloutSound(value:Sound):void          { _buttonController.rolloutSound = value; }
        public function set mute(value:Boolean):void                { _buttonController.mute = value; }
        public function set misc(value:*):void                      { _buttonController.misc = value; }
        public function set text(value:String):void                 { _buttonController.text = value; }
        public function get buttonController():ButtonController     { return _buttonController; }
        public function get selected():Boolean                      { return _buttonController.selected; }
        public function get disabledAlpha():Number                  { return _buttonController.disabledAlpha; }
        public function get rolled():Boolean                        { return _buttonController.rolled; }
        public function get down():Boolean                          { return _buttonController.down; }
        public function get clickSound():Sound                      { return _buttonController.clickSound; }
        public function get rolloverSound():Sound                   { return _buttonController.rolloverSound; }
        public function get rolloutSound():Sound                    { return _buttonController.rolloutSound; }
        public function get mute():Boolean                          { return _buttonController.mute; }
        public function get misc():*                                { return _buttonController.misc; }
        public function get view():*                                { return _buttonController.view; }
        public function get text():String                           { return _buttonController.text; }
        override public function set enabled(value:Boolean):void    { if (_clip != this) { _clip.enabled = value; } else { super.enabled = value; } }
        override public function set x(value:Number):void           { if (_clip != this) { _clip.x = value; } else { super.x = value; } }
        override public function set y(value:Number):void           { if (_clip != this) { _clip.y = value; } else { super.y = value; } }
        override public function get enabled():Boolean              { if (_clip != this) { return _clip.enabled; } else { return super.enabled; } }
        override public function get x():Number                     { if (_clip != this) { return _clip.x; } else { return super.x; } }
        override public function get y():Number                     { if (_clip != this) { return _clip.y; } else { return super.y; } }
        override public function get width():Number                 { if (_clip != this) { return _clip.width; } else { return super.width; } }
        override public function get height():Number                { if (_clip != this) { return _clip.height; } else { return super.height; } }
        
        
        public function addWeakListener(type:String, 
                                        listener:Function, 
                                        useCapture:Boolean = false, 
                                        priority:int = 0, 
                                        useWeakReference:Boolean = true):void 
        {
            _buttonController.addWeakListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        
        /**
         * Passthrough method. It's the clip that must have eventlisteners added 
         * to it as it's the clip that's in the display list.
         */
        override public function addEventListener(type:String, 
                                                  listener:Function, 
                                                  useCapture:Boolean = false, 
                                                  priority:int = 0, 
                                                  useWeakReference:Boolean = false):void 
        {
            if (_clip != this) 
            {
                _clip.addEventListener(type, listener, useCapture, priority, useWeakReference);
            } 
            else 
            {
                super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            }
        }
        
        /**
         * Passthrough method. As the listeners were added to the clip, so too 
         * must they be removed from the clip.
         */
        override public function removeEventListener(type:String, 
                                                     listener:Function, 
                                                     useCapture:Boolean=false):void
        {
            if (_clip != this) 
            {
                _clip.removeEventListener(type, listener, useCapture);
            } 
            else 
            {
                super.removeEventListener(type, listener, useCapture);
            }
        }
        
        /**
         * Passthrough method, events dispatched are actually dispatched  
         * from the _clip
         */
        override public function dispatchEvent(event:Event):Boolean
        {
            if (_clip != this) 
            {
                return _clip.dispatchEvent(event);
            } 
            else 
            {
                return super.dispatchEvent(event);
            }
        }
        
        /**
         * Passthrough method, check for listener on the _clip
         */
        override public function hasEventListener(type:String):Boolean
        {
            if (_clip != this) 
            {
                return _clip.hasEventListener(type);
            } 
            else 
            {
                return super.hasEventListener(type);
            }
        }
        
        /**
         * Passthrough method, check for willTrigger on the _clip
         */
        override public function willTrigger(type:String):Boolean
        {
            if (_clip != this) 
            {
                return _clip.willTrigger(type);
            } 
            else 
            {
                return super.willTrigger(type);
            }
        }
    }
}