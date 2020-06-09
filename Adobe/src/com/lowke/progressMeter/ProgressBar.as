//
//  ProgressBar v 1.03 - progressMeter package
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
    import flash.display.Sprite;
    import flash.text.TextField;
    
    /**
     * ProgressBar v 1.03<br>
     * <p>Russell Lowke, January 28th 2011</p>
     * 
     * Used for displaying progress bar meters where the length of the bar 
     * grows to become full according to progress
     */
    public class ProgressBar extends ProgressMeter 
    {   
        private var _progressBar:Sprite;                // sprite used to display progress bar
        private var _maxWidth:Number;                   // width of progress bar at 100%
        
        public function ProgressBar(textField:TextField,
                                    progressBar:Sprite,
                                    maxValue:Number = 1) 
        {
            _progressBar = progressBar;
            _maxWidth = _progressBar.width;
            
            super(textField);
            
            _maxValue = maxValue;
        }
        
        protected override function update():void 
        {   
            super.update();
            
            // update progress bar
            var width:Number = this.dPercent*_maxWidth;
            _progressBar.width = width;
        }
        
        
        // accessors and mutators
        public function get maxWidth():Number                   { return _maxWidth; }
        public function set maxWidth(value:Number):void         { _maxWidth = value; }
        
    }
}