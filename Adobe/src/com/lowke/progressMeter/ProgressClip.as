//
//  ProgressClip v 1.03 - progressMeter package
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
    import flash.display.MovieClip;
    import flash.text.TextField;
    
    /**
     * ProgressClip v 1.03<br>
     * <p>Russell Lowke, January 28th 2011</p>
     * 
     * Used for progressing through various frames of a MovieClip 
     * as a metered progress value changes.
     */
    public class ProgressClip extends ProgressMeter 
    {   
        private var _progressClip:MovieClip;                // sprite used to display progress bar
        
        public function ProgressClip(textField:TextField,
                                     progressClip:MovieClip,
                                     maxValue:Number = 1) 
        {
            _progressClip = progressClip;
            
            super(textField);
            
            _maxValue = maxValue;
        }
        
        protected override function update():void 
        {   
            super.update();
            
            // update progress clip here
            var frame:Number = Math.round(this.dPercent*(_progressClip.totalFrames - 1)) + 1;
            _progressClip.gotoAndStop(frame);
        }
        
    }
}