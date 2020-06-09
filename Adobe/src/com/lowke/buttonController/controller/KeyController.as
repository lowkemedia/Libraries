//
//  KeyController v 1.01 - buttonController package
//  Russell Lowke, February 11th 2011
//
//  Copyright (c) 2010-2011 Lowke Media
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

package com.lowke.buttonController.controller
{   
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    
    /**
     * @author Russell Lowke
     */
    public class KeyController
    {
        /** useful key codes */
        public static const SPACE_KEY:uint          = 32;
        public static const ENTER_KEY:uint          = 13;
        public static const SHIFT_KEY:uint          = 16;
        public static const ESC_KEY:uint            = 27;
        public static const ARROW_LEFT_KEY:uint     = 37;
        public static const ARROW_RIGHT_KEY:uint    = 39;
        public static const ARROW_UP_KEY:uint       = 38;
        public static const ARROW_DOWN_KEY:uint     = 40;
        
        private static var _keyControllers:Dictionary = new Dictionary();   // hash of all KeyController objects
        
        private var _clip:DisplayObject;                    // DisplayObject being controlled by keys
        private var _stage:Stage;                           // reference to stage the _clip is on
        private var _keyCodes:Array = new Array();          // list of key codes being listened for
        private var _down:Boolean = false;                  // true if responded to keyDown and waiting for keyUp
        private var _persist:Boolean = false;               // if true then KeyController not closed if _clip removed from stage
        
        public function KeyController(clip:DisplayObject) 
        {
            _clip = clip;
            _clip.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
            _clip.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
            
            // keep reference
            _keyControllers[_clip] = this;
        }
        
        private function addedToStage(evt:Event):void {
            addListeners();
        }
        
        private function removedFromStage(evt:Event):void 
        {
            if (_persist) 
            {
                removeListeners();
            } 
            else 
            {
                close();
            }
        }
        
        public function addListeners():void 
        {
            if (_clip.stage) 
            {
                _stage = _clip.stage;
                _stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownEvent, false, 0, true);
                _stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpEvent, false, 0, true);
            }
        }
        
        public function removeListeners():void 
        {
            if (_stage) 
            {
                _stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownEvent);
                _stage.removeEventListener(KeyboardEvent.KEY_UP, stageKeyUpEvent);
            }
        }
        
        /**
         * Causes the _clip to respond to a key. Multiple keys can be assigned.
         * 
         * @param key The key which will cause response.
         */
        public function addKey(key:String):void 
        {
            addKeyCode((key).charCodeAt(0));
        }
        
        /** @see #addKey() */
        public static function addKey(clip:DisplayObject, key:String):void 
        {
            keyController(clip).addKey(key);
        }
        
        /**
         * Causes the _clip to respond to a key code. Multiple key codes can be assigned.
         * 
         * @param keyCode The key code which will cause response.
         */
        public function addKeyCode(keyCode:int):void 
        {
            addListeners();
            _keyCodes.push(keyCode);
        }
        
        /** @see #addKeyCode() */
        public static function addKeyCode(clip:DisplayObject, 
                                          keyCode:int):void 
        {
            keyController(clip).addKeyCode(keyCode);
        }
        
        /**
         * Stops the _clip from responding to a key.
         * 
         * @param key The key which the _clip will no longer respond to.
         */
        public function removeKey(key:String):void 
        {
            removeKeyCode((key).charCodeAt(0));
        }
        
        /** @see #removeKey() */
        public static function removeKey(clip:DisplayObject, 
                                         key:String):void 
        {
            keyController(clip).removeKey(key);
        }
        
        /**
         * Stops the _clip from responding to a key code.
         * 
         * @param key The key code which the button will no longer respond to.
         */
        public function removeKeyCode(keyCode:int):void 
        {
            var index:int = _keyCodes.indexOf(keyCode);
            if (index > -1) 
            {
                _keyCodes.splice(index, 1);
            }
        }
        
        /** @see #removeKeyCode() */
        public static function removeKeyCode(clip:DisplayObject, 
                                             keyCode:int):void
        {
            keyController(clip).removeKeyCode(keyCode);
        }
        
        
        private function stageKeyDownEvent(evt:KeyboardEvent):void 
        {
            // have the DisplayObject dispatch a mouse down event
            if (! _down && _clip.visible && _keyCodes.indexOf(evt.keyCode) > -1) 
            {
                _clip.dispatchEvent(new MouseEvent(flash.events.MouseEvent.ROLL_OVER));
                _clip.dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_DOWN));
                _down = true;
            }
        }
        
        private function stageKeyUpEvent(evt:KeyboardEvent):void 
        {
            // have the DisplayObject dispatch click and mouse up events
            if (_clip.visible && _keyCodes.indexOf(evt.keyCode) > -1) 
            {
                _clip.dispatchEvent(new MouseEvent(flash.events.MouseEvent.CLICK));
                _clip.dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_UP));
                _clip.dispatchEvent(new MouseEvent(flash.events.MouseEvent.ROLL_OUT));
                _down = false;
            }
        }
        
        public function close():void 
        {
            removeListeners();
            _stage = null;
            _keyCodes[_clip] = null;
            delete _keyCodes[_clip];
        }
        
        public function get persist():Boolean               { return _persist; }
        public function set persist(val:Boolean):void       { _persist = val; }
        
        
        //
        // static helper methods for KeyController
        //
        
        private static function keyController(clip:DisplayObject):KeyController 
        {
            var keyController:KeyController = getKeyController(clip);
            if (! keyController) 
            {
                keyController = new KeyController(clip);
            }
            return keyController;
        }
        
        public static function getKeyController(clip:DisplayObject):KeyController 
        {
            return _keyControllers[clip] as KeyController;
        }
        
        public static function clearKeys(clip:DisplayObject):void 
        {
            var keyController:KeyController = getKeyController(clip);
            if (keyController) 
            {
                keyController.close();
            }
        }
    }
}