//
//  RadioButtons v 1.01 - buttonController package
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

package com.lowke.buttonController.helperClasses
{    
    import com.lowke.buttonController.IStandardButton;
    
    import flash.events.MouseEvent;
    
    public class RadioButtons 
    {    
        private var _btns:Array;                    // array of buttons being treated like radio buttons
        private var _selected:IStandardButton;      // currently selected button
        private var _allowNoSelection:Boolean;      // if true, then user can deselect radiobutton
        
        public function RadioButtons(btns:Array = null, allowNoSelection:Boolean = false) 
        {
            _allowNoSelection = allowNoSelection;
            _btns = new Array();
            if (btns) 
            {
                for each (var btn:IStandardButton in btns) 
                {
                    addRadioButton(btn);
                }
            }
        }
        
        public function addRadioButton(btn:IStandardButton):void 
        {
            addRadioButtonAtIndex(btn, _btns.length);
        }
        
        public function addRadioButtonAtIndex(btn:IStandardButton, index:uint):void 
        {
            btn.view.addEventListener(MouseEvent.CLICK, btnClicked, false, 0, false);
            _btns[index] = btn;
            if (btn.selected) 
            {
                makeSelected(btn);
            } 
            else if (! _allowNoSelection && ! _selected) 
            {
                makeSelected(_btns[0]);
            }
        }
        
        private function btnClicked(evt:MouseEvent):void 
        {
            var btn:IStandardButton = evt.currentTarget["parent"] as IStandardButton;
            clickBtn(btn);
        }
        
        public function clickBtn(btn:IStandardButton):void 
        {
            if (! btn) 
            {
                return;
            }
            
            if (btn == _selected) 
            {
                // user clicked on selected button
                if (_allowNoSelection) 
                {
                    btn.selected = false;
                    _selected = null;
                }
            } 
            else 
            {
                // user clicked on other button
                makeSelected(btn);
            }
        }
        
        public function makeSelected(btn:IStandardButton):void 
        {
            if (_selected) 
            {
                if (! _allowNoSelection) 
                {
                    _selected.mute = false;
                }
                _selected.selected = false;
            }
            btn.selected = true;
            if (! _allowNoSelection) 
            {
                btn.mute = true;
            }
            _selected = btn;
        }
        
        public function dispose():void 
        {    
            // remove event listeners
            for each (var btn:IStandardButton in _btns) 
            {
                btn.removeEventListener(MouseEvent.CLICK, btnClicked);
            }
            _btns = null;
            _selected = null;
        }
        
        public function get btns():Array                    { return _btns; }
        public function get allowNoSelection():Boolean      { return _allowNoSelection; }
        public function get selected():IStandardButton      { return _selected; }
    }
}