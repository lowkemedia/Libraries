//
//  LoaderProgressEvent v 1.0 - assetLoader package
//  Russell Lowke, January 13th 2009
// 
//  Copyright (c) 2009 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-assetloader/ for code repository
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

package com.lowke.assetLoader.event
{   
    import flash.events.Event;
    
    /**
     * @author Russell Lowke
     */
    public class LoaderProgressEvent extends Event
    {   
        // event names
        public static const PROGRESS:String = "assetLoaderProgress";
        
        public var _percentDone:Number;
        
        public function LoaderProgressEvent(type:String, 
                                            percentDone:Number = 0) 
        {
            super(type);
            
            _percentDone = percentDone;
        }
        
        public override function clone():Event 
        {
            return new LoaderProgressEvent(type, _percentDone);
        }
        
        public override function toString():String 
        {
            return formatToString("ProgressEvent", "type", "percentDone");
        }
        
        // accessors and mutators
        public function get percentDone():Number            { return _percentDone; }
        public function set percentDone(val:Number):void    { _percentDone = val; }
    }
}