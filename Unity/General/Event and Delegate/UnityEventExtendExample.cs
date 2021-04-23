//
//  UnityEventExample - Event and Delegate package
//  Russell Lowke, June 23rd 2020
//
//  Copyright (c) 2020 Lowke Media
//  see https://github.com/lowkemedia/Libraries for more information
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

using UnityEngine;

[RequireComponent(typeof(UnityEventExample))]
public class UnityEventExtendExample : MonoBehaviour
{
    private UnityEventExample _unityEventExample;
    public UnityEventExample Example {
        get {
            if (!_unityEventExample) { _unityEventExample = GetComponent<UnityEventExample>(); }
            return _unityEventExample;
        }
    }

    private void Awake()
    {
        Example.onStartEvent.AddListener(OnMyCallback);
    }

    private void OnMyCallback()
    {
        Logger.Print(">>> Got Extended MyCallback()");
        Example.onStartEvent.RemoveListener(OnMyCallback);
    }
}
