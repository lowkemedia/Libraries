//
//  ObjectEvent v 1.0
//  Russell Lowke, August 13th 2010
//
//  Copyright (c) 2008-2010 Lowke Media
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

package com.lowke.util.eventUtil
{
    import com.lowke.Dump;

    import flash.events.Event;
    
    //
    // piggyback dynamic Object (data) onto an event
    public class ObjectEvent extends Event 
    {
        // event name
        public static const OBJECT_EVENT:String = "object_event";
        
        public var _id:String;
        public var _data:Object;
        
        public function ObjectEvent(id:String, data:Object) 
        {
            super(id);
            
            _id   = id;
            _data = data;
        }
        
        public override function clone():Event 
        {
            return new ObjectEvent(_id, _data);
        }
        
        public override function toString():String 
        {
            return Dump.toString(this);
        }

        
        //
        // accessors and mutators
        
        public function get id():String             { return _id; }
        public function get data():Object           { return _data; }
        
        public function set data(val:Object):void   { _data = val; }
    }
}