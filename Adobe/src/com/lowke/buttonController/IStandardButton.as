//
//  IStandardButton v 1.0 - buttonController package
//  Russell Lowke, November 24th 2009
//
//  Copyright (c) 2009 Lowke Media
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

package com.lowke.buttonController
{
    import flash.media.Sound;
    
    public interface IStandardButton
    {
        // Button variables
        function clickButton(pressDuration:uint = 0):void;
        function addKey(key:String):void;
        function addKeyCode(keyCode:int):void;
        function removeKey(key:String):void;
        function removeKeyCode(keyCode:int):void;
        function clearKeys():void;
        function set selected(value:Boolean):void;
        function set disabledAlpha(value:Number):void;
        function set clickSound(value:Sound):void;
        function set rolloverSound(value:Sound):void;
        function set rolloutSound(value:Sound):void;
        function set mute(value:Boolean):void;
        function set misc(value:*):void;
        function get selected():Boolean;
        function get disabledAlpha():Number;
        function get rolled():Boolean;
        function get down():Boolean;
        function get clickSound():Sound;
        function get rolloverSound():Sound;
        function get rolloutSound():Sound;
        function get mute():Boolean;
        function get misc():*;
        function get view():*;
        
        // DisplayObject variables
        function set enabled(value:Boolean):void;
        function set x(value:Number):void;
        function set y(value:Number):void;
        function get enabled():Boolean;
        function get x():Number;
        function get y():Number;
        function get width():Number;
        function get height():Number;
        function addEventListener(type:String,
                                  listener:Function,
                                  useCapture:Boolean = false,
                                  priority:int = 0,
                                  useWeakReference:Boolean = false):void;
        function removeEventListener(type:String,
                                     listener:Function,
                                     useCapture:Boolean = false):void;
    }
}