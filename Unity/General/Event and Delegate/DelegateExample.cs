//
//  DelegateExample - Event and Delegate package
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
using CallbackTypes;

public class DelegateExample : MonoBehaviour
{
    private Callback _callback;

    private void Awake()
    {
        AddCallback();
    }

    private void AddCallback()
    {
        _callback += OnMyCallback;
        _callback += delegate { OnMyCallbackInt(0); };
        //_callback += () => MyCallbackB(0);            // Lambda Expression for delegate { MyCallbackB(0); };
    }

    // Start is called before the first frame update
    void Start()
    {
        _callback?.Invoke();

        RemoveCallback();

        _callback?.Invoke();
    }

    private void RemoveCallback()
    {
        _callback -= OnMyCallback;
        // _callback -= MyCallbackInt;                  // Note: issues removing anonymous function

        // remove all callbacks
        _callback = null;

        Logger.Print(">> Remove Callbacks");
    }

    /* Update is called once per frame
    private void Update()
    {

    }
    */

    private void OnMyCallback()
    {
        Logger.Print(">> Got MyCallback()");
    }

    private void OnMyCallbackInt(int value)
    {
        Logger.Print(">> Got MyCallbackInt(" + value + ")");
    }

    /* Destroy is called when instance is destroyed
    public void Destroy()               // must be public
    {
    }
    */
}
