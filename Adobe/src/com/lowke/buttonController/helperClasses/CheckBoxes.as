//
//  CheckBoxes v 1.01 - buttonController package
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
    
    public class CheckBoxes 
    {    
        private var _btns:Array;            // array of buttons being treated like checkboxes
        
        public function CheckBoxes(btns:Array = null) 
        {
            _btns = new Array();
            if (btns) 
            {
                for each (var btn:IStandardButton in btns) 
                {
                    addCheckbox(btn);
                }
            }
        }
        
        public function addCheckbox(btn:IStandardButton):void 
        {
            addCheckboxAtIndex(btn, _btns.length);
        }
        
        public function addCheckboxAtIndex(btn:IStandardButton, index:uint):void 
        {
            btn.addEventListener(MouseEvent.CLICK, btnClicked, false, 0, false);
            _btns[index] = btn;
        }
        
        private function btnClicked(evt:MouseEvent):void 
        {
            var btn:IStandardButton = evt.currentTarget as IStandardButton;
            clickBtn(btn);
        }
        
        public function clickBtn(btn:IStandardButton):void 
        {
            if (! btn) 
            {
                return;
            }
            btn.selected = ! btn.selected;
        }
        
        public function dispose():void 
        {
            // remove event listeners
            for each (var btn:IStandardButton in _btns) 
            {
                btn.removeEventListener(MouseEvent.CLICK, btnClicked);
            }
            _btns = null;
        }
        
        // return a list of selected buttons
        public function get selected():Array 
        {
            var selected:Array = new Array();
            for each (var btn:IStandardButton in _btns) 
            {
                if (btn.selected) 
                {
                    selected.push(btn);
                }
            }
            return selected;
        }
        
        public function get btns():Array 
        { 
            return _btns;
        }
    }
}