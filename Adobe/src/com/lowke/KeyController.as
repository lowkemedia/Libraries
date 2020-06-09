//
//  KeyController v 1.01
//  Russell Lowke, February 11th 2011
//
//  Copyright (c) 2010-2011 Lowke Media
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

package com.lowke
{
    import com.lowke.logger.Logger;
    
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    
    public class KeyController
    {
        
        // error IDs
        public static const WARNING_CANT_REMOVE_KEYCODE:String = "KEY00";
        
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
        
        private var _view:DisplayObject;                    // DisplayObject being controlled by keys
        private var _stage:Stage;                           // reference to stage the _view is on
        private var _keyCodes:Array = new Array();          // list of key codes being listened for
        private var _down:Boolean = false;                  // true if responded to keyDown and waiting for keyUp
        private var _persist:Boolean = false;               // if true then KeyController not closed if _view removed from stage
        
        public function KeyController(view:DisplayObject) 
        {
            _view = view;
            _view.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
            _view.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
            
            // keep reference
            _keyControllers[_view] = this;
        }
        
        private function addedToStage(evt:Event):void 
        {
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
            if (_view.stage) 
            {
                _stage = _view.stage;
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
         * Causes the _view to respond to a key. Multiple keys can be assigned.
         * 
         * @param key The key which will cause response.
         */
        public function addKey(key:String):void 
        {
            addKeyCode((key).charCodeAt(0));
        }
        /** @see #addKey() */
        public static function addKey(view:DisplayObject, key:String):void 
        {
            keyController(view).addKey(key);
        }
        
        /**
         * Causes the _view to respond to a key code. Multiple key codes can be assigned.
         * 
         * @param keyCode The key code which will cause response.
         */
        public function addKeyCode(keyCode:int):void 
        {
            addListeners();
            _keyCodes.push(keyCode);
        }
        
        /** @see #addKeyCode() */
        public static function addKeyCode(view:DisplayObject, 
                                          keyCode:int):void 
        {
            keyController(view).addKeyCode(keyCode);
        }
        
        /**
         * Stops the _view from responding to a key.
         * 
         * @param key The key which the _view will no longer respond to.
         */
        public function removeKey(key:String, 
                                  giveWarning:Boolean = true):void 
        {
            removeKeyCode((key).charCodeAt(0), giveWarning);
        }
        
        /** @see #removeKey() */
        public static function removeKey(view:DisplayObject, 
                                         key:String, 
                                         giveWarning:Boolean = true):void 
        {
            keyController(view).removeKey(key, giveWarning);
        }
        
        /**
         * Stops the _view from responding to a key code.
         * 
         * @param key The key code which the button will no longer respond to.
         */
        public function removeKeyCode(keyCode:int, 
                                      giveWarning:Boolean = true):void 
        {
            var index:int = _keyCodes.indexOf(keyCode);
            if (index > -1) 
            {
                _keyCodes.splice(index, 1);
            } 
            else if (giveWarning) 
            {
                Logger.warning("Can't remove " + keyCode + " on " + _view, WARNING_CANT_REMOVE_KEYCODE);
            }
        }
        
        /** @see #removeKeyCode() */
        public static function removeKeyCode(view:DisplayObject, 
                                             keyCode:int, 
                                             giveWarning:Boolean = true):void
        {
            keyController(view).removeKeyCode(keyCode, giveWarning);
        }
        
        
        private function stageKeyDownEvent(evt:KeyboardEvent):void 
        {
            // have the DisplayObject dispatch a mouse down event
            if (! _down && _view.visible && _keyCodes.indexOf(evt.keyCode) > -1) 
            {
                _view.dispatchEvent(new MouseEvent(flash.events.MouseEvent.ROLL_OVER));
                _view.dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_DOWN));
                _down = true;
            }
        }
        
        private function stageKeyUpEvent(evt:KeyboardEvent):void 
        {
            // have the DisplayObject dispatch click and mouse up events
            if (_view.visible && _keyCodes.indexOf(evt.keyCode) > -1) 
            {
                _view.dispatchEvent(new MouseEvent(flash.events.MouseEvent.CLICK));
                _view.dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_UP));
                _view.dispatchEvent(new MouseEvent(flash.events.MouseEvent.ROLL_OUT));
                _down = false;
            }
        }
        
        public function close():void 
        {
            removeListeners();
            _stage = null;
            _keyCodes[_view] = null;
            delete _keyCodes[_view];
        }
        
        public function get persist():Boolean               { return _persist; }
        public function set persist(val:Boolean):void       { _persist = val; }
        
        
        //
        // static helper methods for KeyController
        //
        
        private static function keyController(view:DisplayObject):KeyController 
        {
            var keyController:KeyController = getKeyController(view);
            if (! keyController) 
            {
                keyController = new KeyController(view);
            }
            return keyController;
        }
        
        public static function getKeyController(view:DisplayObject):KeyController 
        {
            return _keyControllers[view] as KeyController;
        }
        
        public static function clearKeys(view:DisplayObject):void 
        {
            var keyController:KeyController = getKeyController(view);
            if (keyController) 
            {
                keyController.close();
            }
        }
    }
}