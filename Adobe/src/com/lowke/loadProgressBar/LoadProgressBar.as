//
//  LoadProgressBar v 1.0.3 - loadProgressBar package
//  Russell Lowke, November 18th 2011
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

package com.lowke.loadProgressBar
{
    import com.lowke.Delayer;
    import com.lowke.assetLoader.AssetLoader;
    import com.lowke.assetLoader.event.BatchCompleteEvent;
    import com.lowke.assetLoader.event.LoaderProgressEvent;
    import com.lowke.progressMeter.ProgressBar;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    
    public class LoadProgressBar extends Sprite 
    {
        private var _assetLoader:AssetLoader;       // reference to AssetLoader singleton
        private var _progressBarClip:MovieClip;     // progress bar display
        private var _progressBar:ProgressBar;       // ProgressBar controller
        private var _showProgressDelay:int;         // time to wait before showing progress bar
        private var _delay:Delayer;                 // delay object used for delaying showing progressbar
        private var _percentDone:Number = 0;        // percent done currently shown on progress bar
        
        public function LoadProgressBar(showProgressDelay:int = 500)
        {
            _showProgressDelay = showProgressDelay;

            _assetLoader = AssetLoader.instance;            
            filters = [ new DropShadowFilter() ];
            
            // the LoadProgressBarClip() is Runtime Shared Library (RSL) MovieClip found
            //  in lib/LoadProgressBar.swc which was created from fla/LoadProgressBar.fla
            // make sure that the LoadProgressBar.swc is linked into your library path
            //  to get access to the LoadProgressBarClip() asset.
            _progressBarClip = new LoadProgressBarClip();
            
            // for more information see, 
            //   http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf674ba-7fff.html
            //   http://help.adobe.com/en_US/flash/cs/using/WSd60f23110762d6b883b18f10cb1fe1af6-7dc9a.html
            
            
            // start listening to the AssetLoadder for PROGRESS and BATCH_COMPLETE events
            _assetLoader.addEventListener(LoaderProgressEvent.PROGRESS, showProgressEvent);
            _assetLoader.addEventListener(BatchCompleteEvent.BATCH_COMPLETE, hideProgressEvent);
            
            _progressBar = new ProgressBar(null, _progressBarClip["progressBar"]);
        }
        
        private function showProgressEvent(event:LoaderProgressEvent):void 
        {
            showProgressBar(event.percentDone);
        }
        
        private function hideProgressEvent(event:Event):void 
        {
            hideProgressBar();
        }
        
        public function showProgressBar(percentDone:Number):void 
        {   
            // cap percentDone
            if (percentDone > 1) 
            {
                percentDone = 1;
            } 
            else if (percentDone < 0) 
            {
                percentDone = 0;
            }
            
            // show progress window
            if (! _delay && ! contains(_progressBarClip)) 
            {
                if (_showProgressDelay)
                {
                    _delay = Delayer.delay(_showProgressDelay, displayProgress);
                }
                else
                {
                    displayProgress();
                }
            }
            
            // prevent progress bar from ever going backwards,
            //  which looks weird, but can happen if a bunch
            //  of new load calls get triggered while doing a load.
            if (_percentDone < percentDone) 
            {
                _percentDone = percentDone;
            }
            
            _progressBar.percent = _percentDone;
        }
        
        protected function displayProgress():void
        {   
            removeDelay();
            
            // show progress window
            if (! contains(_progressBarClip)) 
            {
                addChild(_progressBarClip);
            }
        }
        
        public function hideProgressBar():void 
        {
            removeDelay();

            // always show as 100% for 1/10th of a second before removing.
            _progressBar.dValue = 1;
            Delayer.delay(100, removeProgressBar);
        }

        private function removeProgressBar():void
        {
            _percentDone = 0;
            if (contains(_progressBarClip))
            {
                removeChild(_progressBarClip);
            }
        }
        
        private function removeDelay():void
        {
            if (_delay) 
            {
                _delay.close();
                _delay = null;
            }
        }
    }
}