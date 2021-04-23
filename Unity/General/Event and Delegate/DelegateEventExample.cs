//
//  DelegateEventExample - Event and Delegate package
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

// NOTE: Delegate Events use strong references while Unity Events use weak references.
// With a strong reference the event publisher will keep the subscriber alive,
// and the garbage collector cannot clear it from the memory. Failing to unsubscribe
// from a Delegate event may cause a memory leak. Weak references will be automatically
// cleaned up by the garbage collector when the subscriber is destroyed.

// Delegate events are about 38.3 times faster then UnityEvent, though performance
//  will vary on different platforms

// Delegate events are really just standard C# delegate functions with a few extra 
//  features and restrictions. In particular, they can only be invoked from the class
//  that declared the event. Other classes can only add or remove a listener to the
//  Delegate event, so delegate events are protected from sabotage by other classes.

// Native events let one piece of code subscribe to events from other systems, while
//  Unity events let you connect public interfaces in the editor

using UnityEngine;


// see https://itchyowl.com/events-in-unity/
// see https://docs.microsoft.com/en-us/dotnet/standard/events/
// see https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/events/

public class DelegateEventExample : MonoBehaviour
{
    public delegate void CallbackEvent();
    public delegate void MyIntEvent(int value);

    // Note: Delegate events are not serializable with [System.Serializable]
    public event CallbackEvent OnStartEvent;
    public event MyIntEvent OnMyIntEvent;

    /*
    public event Callback OnStartEvent
    {
        add     { Logger.Print(">> OnStartEvent added"); }
        remove  { Logger.Print(">> OnStartEvent removed"); }

        // Note: you can lock Delegate events to be Thread-safe see https://csharpindepth.com/Articles/Events
    }
    */

    // example TODO:  CustomEvent(this, EventArgs.Empty); ... MyEvent += (sender, args) => { };
    // ... event Action<int> CustomEvent;  

    // Start is called before the first frame update
    private void Awake()
    {
        AddListeners();
    }

    private void AddListeners()
	{
        OnStartEvent += OnMyCallback;                         // Note: NOT OnStart.AddListener(MyCallback);
        OnStartEvent += delegate { OnMyCallbackInt(0); };
        // OnStartEvent += () => MyCallbackB(0);            // Lambda Expression for delegate { MyCallbackB(0); };

        OnMyIntEvent += OnMyCallbackInt;
    }

    // Start is called before the first frame update
    private void Start()
    {
        OnStartEvent?.Invoke();
        OnMyIntEvent?.Invoke(1);

        RemoveListeners();

        OnStartEvent?.Invoke();
        OnMyIntEvent?.Invoke(1);
    }

    private void RemoveListeners()
    {
        OnStartEvent -= OnMyCallback;                         // Note: NOT OnStart.RemoveListener(MyCallback);
        // OnStart -= MyCallbackInt;                        // Note: issues removing anonymous function
        OnMyIntEvent -= OnMyCallbackInt;

        // remove all listeners
        OnStartEvent = null;
        OnMyIntEvent = null;

        Logger.Print(">> Remove Listeners");
    }

    private void OnMyCallback()
	{
        Logger.Print(">> Got MyCallback()");
	}

    private void OnMyCallbackInt(int value)
    {
        Logger.Print(">> Got MyCallbackInt(" + value + ")");
    }
}

