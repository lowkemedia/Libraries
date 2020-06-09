//
//  LoadSoundFx v 1.0 - soundManager package
//  Russell Lowke, September 20th 2009
// 
//  Copyright (c) 2008-2009 Lowke Media
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

package com.lowke.soundManager.soundFx
{   
    import com.lowke.assetLoader.loader.ILoad;
    import com.lowke.assetLoader.loader.LoadSound;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    
    public class LoadSoundFx extends LoadSound implements ILoad 
    {   
        //
        // constructor
        public function LoadSoundFx(url:String) 
        {
            super(url);
        }
        
        override public function createLoader():void 
        {
            _loader = new SoundFx();
            _loader.addEventListener(Event.COMPLETE, fileLoaded);
            _loader.addEventListener(ProgressEvent.PROGRESS, _assetLoader.dispatchProgress);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            (_loader as SoundFx).load(_request);
        }
    }
}