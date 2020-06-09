//
//  MakeUrlRequest v 1.0 - assetLoader package
//  Russell Lowke, December 18th 2011
//
//  Copyright (c) 2008-2011 Lowke Media
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


package com.lowke.assetLoader.loader
{
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class LoadUrlJsonRequest extends LoadJson implements ILoad 
    {
        //
        // constructor
        public function LoadUrlJsonRequest(url:String, 
                                       variables:URLVariables = null,
                                       method:String = null) 
        {
            super(url);
            
            if (! method)
            {
                method = URLRequestMethod.POST;
            }
            
            _request.data = variables;
            _request.method = method;
        }
	}
}