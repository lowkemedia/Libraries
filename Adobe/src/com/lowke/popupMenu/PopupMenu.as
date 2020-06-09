//
//  PopupMenu v 1.1 - popupMenu package
//  Russell Lowke, October 10th 2011
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


package com.lowke.popupMenu
{
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.BlinkFX;
    import com.lowke.buttonController.ButtonController;
    import com.lowke.buttonController.IStandardButton;
    
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Transform;
    import flash.media.Sound;
    
    public class PopupMenu extends Sprite
    {
        
        // events dispatched
        public static const MENU_CHANGED:String = "menuChanged";
        
        private var _ani:Animator = Animator.instance;          // animator
        private var _index:uint;                                // index of current active button
        private var _buttonData:Vector.<IStandardButton>;       // data of MovieClipButtons used in popup
        private var _popup:Sprite;                              // popup containing all buttons
        private var _height:Number;                             // height of popup excluding edge padding
        private var _width:Number;                              // width of popup excluding edge padding
        private var _padding:Number;                            // amount of padding between buttons
        private var _background:Sprite;                         // sprite used for background of popup
        private var _open:Boolean;                              // (read only) true if the popup menu is open
        private var _openSound:Sound;                           // sound triggered when menu opens
        private var _closeSound:Sound;                          // sound triggered when menu closes
        private var _highlightValue:Number;                     // current highlight brightness of selectedButton
        private var _highlightBrightness:Number = 35;           // brightness of flashing highlight, should be from 0 to 255
        private var _backgroundColor:uint;                      // color of background swatch
        private var _backgroundDropShadow:Number;               // dropshadow on background swatch
        private var _backgroundAlpha:Number;                    // alpha of background swatch
        
        public static function buildPopup(labels:Vector.<String>, 
                                          skin:Class,
                                          startIndex:uint = 0,
                                          padding:Number = 1,
                                          backgroundColor:uint = 0x666666,
                                          backgroundDropShadow:Number = 2,
                                          backgroundAlpha:Number = 1):PopupMenu
        {
            var buttonData:Vector.<IStandardButton> = new Vector.<IStandardButton>;
            for each(var label:String in labels) 
            {
                var button:ButtonController = new ButtonController(new skin());
                button.text = label;
                buttonData.push(button);
            }
            
            return new PopupMenu(buttonData, startIndex, padding, backgroundColor, backgroundDropShadow, backgroundAlpha);
        }
        
        public function PopupMenu(buttonData:Vector.<IStandardButton> = null,
                                  startIndex:uint = 0,
                                  padding:Number = 1,
                                  backgroundColor:uint = 0x666666,
                                  backgroundDropShadow:Number = 2,
                                  backgroundAlpha:Number = 1)
        {
            _padding = padding;
            _backgroundColor = backgroundColor;
            _backgroundDropShadow = backgroundDropShadow;
            _backgroundAlpha = backgroundAlpha;
            createPopup(buttonData, startIndex);
        }
        
        public function createPopup(buttonData:Vector.<IStandardButton> = null, 
                                    startIndex:uint = 0):void 
        {
            _buttonData = buttonData;
            
            // remove any existing popup
            if (_popup && contains(_popup)) 
            {
                removeChild(_popup);
            }
            
            // create the popup
            _popup = new Sprite();
            _height = 0;
            _width = 0;
            for (var i:uint = 0; i < _buttonData.length; ++i) 
            {
                var button:IStandardButton = _buttonData[i];
                if (_height != 0) 
                {
                    _height += _padding;
                }
                button.y = _height;
                _popup.addChild(button.view);
                
                bindOnEvent(button.view, MouseEvent.CLICK, function():void
                    {
                        clickSelection(i);
                    });

                if (button.width > _width) 
                {
                    _width = button.width;
                }
                _height += button.height;
            }
            
            createBackground(_backgroundColor, _backgroundAlpha, _backgroundAlpha);
            
            // add the popup as closed
            closePopup(startIndex);
            addChild(_popup);
        }
        
        private function createBackground(backgroundColor:uint = 0x666666,
                                          dropShadow:Number = 2,
                                          alpha:Number = 1,
                                          topPadding:Number = 0,
                                          leftPadding:Number = 0,
                                          bottomPadding:Number = 0,
                                          rightPadding:Number = 0):void
        {
            // remove any existing background
            if (_background && _popup.contains(_background)) 
            {
                _popup.removeChild(_background);
            }
            
            // create the background
            var box:Shape = new Shape();
            box.graphics.beginFill(backgroundColor);
            box.graphics.drawRect(-_padding - leftPadding,
                -_padding - topPadding, 
                _width + _padding*2 + leftPadding + rightPadding, 
                _height + _padding*2 + topPadding + bottomPadding);
            box.alpha = alpha;
            _background = new Sprite();
            _background.addChild(box);
            if (dropShadow) 
            {
                _background.filters = [ new DropShadowFilter(dropShadow) ];
            }
            _background.visible = _open;
            _popup.addChildAt(_background, 0);
        }
        
        // called when one of the buttons in the popup menu is selected
        private function clickSelection(nIndex:uint):void {
            if (_open) 
            {
                blinkClosePopup(nIndex);
            } 
            else 
            {
                openPopup();
            }
        }
        
        public function openPopup():void 
        {
            _background.visible = true;
            for each(var button:ButtonController in _buttonData) 
            {
                button.visible = true;
            }
            
            if (_openSound) 
            {
                _openSound.play();
            }
            _open = true;
        }
        
        public function blinkClosePopup(nIndex:int = -1):void 
        {
            if (nIndex > -1 && _index != nIndex) 
            {
                // switch the highlighted index
                selectedButton.selected = false;
                _index = nIndex;
                selectedButton.selected = true;
                highlightValue = _highlightBrightness;
                
                // blink the new index
                _ani.anime(this).addEffect(new BlinkFX("highlightValue", _highlightBrightness, 140, 0, 140, 2)).whenDone(function():void
                {
                    closePopup(nIndex);
                });
            } 
            else 
            {
                closePopup(nIndex);
            }
        }
        
        public function closePopup(nIndex:int = -1):void 
        {
            if (nIndex > -1) 
            {
                index = nIndex;
            }
            
            _background.visible = false;
            for each(var button:IStandardButton in _buttonData) 
            {
                if (button == selectedButton) 
                {
                    button.view.visible = true;
                } 
                else 
                {
                    button.view.visible = false;
                }
            }
            
            if (_closeSound) 
            {
                _closeSound.play();
            }
            _open = false;
        }
        
        public function get index():uint                            { return _index; }
        public function get selectedButton():IStandardButton        { return _buttonData[_index]; }
        public function get buttonData():Vector.<IStandardButton>   { return _buttonData; }
        public function get open():Boolean                          { return _open; }
        public function get openSound():Sound                       { return _openSound; }
        public function get closeSound():Sound                      { return _closeSound; }
        public function get highlightValue():Number                 { return _highlightValue; }
        public function get background():Sprite                     { return _background; }
        public function get padding():Number                        { return _padding; }
        
        public function set highlightValue(val:Number):void 
        {
            _highlightValue = val;
            highlight(selectedButton.view as DisplayObject, _highlightValue);
        }
        
        public function set index(val:uint):void 
        { 
            // unselect any button at old index
            selectedButton.selected = false;
            
            _index = val; 
            _popup.y = - selectedButton.y;
            
            // select any button at new index
            selectedButton.selected = true;
            dispatchEvent(new Event(MENU_CHANGED));
        }
        
        /** Sets the sound played when the menu opens. */
        public function set openSound(val:Sound):void
        { 
            _openSound = val; 
        }
        
        /** Sets the sound played when the menu closes. */
        public function set closeSound(val:Sound):void
        { 
            _closeSound = val; 
        }
        
        /** Sets the click sound played by all buttons in the popup. */
        public function set clickSound(val:Sound):void 
        {
            for each(var button:ButtonController in _buttonData) 
            {
                button.clickSound = val;
            }
        }
        
        /** Sets the rollover sound played by all buttons in the popup. */
        public function set rolloverSound(val:Sound):void 
        {
            for each(var button:ButtonController in _buttonData) 
            {
                button.rolloverSound = val;
            }
        }
        
        /** Sets the rollout sound played by all buttons in the popup. */
        public function set rolloutSound(val:Sound):void 
        {
            for each(var button:ButtonController in _buttonData) 
            {
                button.rolloutSound = val;
            }
        }
        
        
        //
        // static helper methods
        
        //
        // brightness should be a value from 0 to 255
        public static function highlight(dObj:DisplayObject, brightness:Number):void 
        {
            var ct:ColorTransform = new ColorTransform();
            ct.redOffset = brightness;
            ct.greenOffset = brightness;
            ct.blueOffset = brightness;
            var trans:Transform = new Transform(dObj);
            trans.colorTransform = ct;
        }
        
        /**
         * Convenience method that uses a closure to bind a function callback 
         * with arguments to be called whenever a particular event is dispatched
         * from an EventDispatcher object.
         * 
         * Flash has an annoying bug with closures in that values passed into a 
         * closure are passed by reference not value. If you try to use multiple 
         * closures in a method with different references passed to each closure 
         * it won't work properly as only the last reference will be used for 
         * all closures. This static method sidesteps the problem as all 
         * references are copied when passed as parameters into the method.
         * 
         * Note: The listener added is a hard listener and will only dispose
         * when the dispatcher being listened to is cleared.
         * 
         * @param dispatcher EventDispatcher being listened to.
         * @param type Event type being listened for.
         * @param funct Function callback called when event dispatched.
         */
        public static function bindOnEvent(dispatcher:EventDispatcher,
                                           type:String,
                                           funct:Function):void
        {
            var listener:Function = function (event:Event):void 
            {
                funct();
            };
            dispatcher.addEventListener(type, listener);
        }
    }
}