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

// NOTE: Native Events use strong references while Unity Events use weak references.
// With a strong reference the event publisher will keep the subscriber alive,
// and the garbage collector cannot clear it from the memory. Failing to unsubscribe
// from a native event may cause a memory leak. Weak references will be automatically
// cleaned up by the garbage collector when the subscriber is destroyed.

// Unity events let you connect public interfaces in the editor, while Native events
//  let one piece of code subscribe to events from other systems.

// Note: Objects should initialize in Awake() and talk to others in Start().
// The sequence of Awake() being called before Start() is guaranteed every time, but
// the order in which a particular script gets the call is sequential and can only be
// forced consistent by changing the Script Execution Order.
// https://docs.unity3d.com/Manual/ExecutionOrder.html
// https://docs.unity3d.com/Manual/class-MonoManager.html


using UnityEngine;
using UnityEngine.Events;


// see https://docs.unity3d.com/ScriptReference/Events.UnityEvent.html

[System.Serializable]
public class MyIntEvent : UnityEvent<int> { }

// Note: You can't serialize a field with generics!
public class MyUnityEventWrapper<T> : UnityEvent<T> { }

public class UnityEventExample : MonoBehaviour
{
    public UnityEvent onStartEvent;                                 // Note: if public Unity will automatically create a new UnityEvent(); 
    public MyIntEvent onMyIntEvent;
    public MyUnityEventWrapper<int> onMyEvent;                      // Note: generic class won't serialize!

    // Start is called before the first frame update
    private void Awake()
    {
        // Note: if private or not serializable you will need to create a new event
        if (onMyEvent is null) {
            onMyEvent = new MyUnityEventWrapper<int>();
        }

        AddListeners();
    }

    private void AddListeners()
    {
        onStartEvent.AddListener(OnMyCallback);                       // Note: NOT OnStartEvent += MyCallbackA;
        onStartEvent.AddListener(delegate { OnMyCallbackInt(0); });
        // OnStartEvent.AddListener(() => MyCallbackB(0));          // Lambda Expression for delegate { MyCallbackB(0); };

        onMyIntEvent.AddListener(OnMyCallbackInt);
        onMyEvent.AddListener(OnMyCallbackInt);
    }

    // Start is called before the first frame update
    private void Start()
    {
        onStartEvent?.Invoke();
        onMyIntEvent?.Invoke(1);                                    // passing parameter into event
        onMyEvent?.Invoke(2);

        RemoveListeners();

        onStartEvent?.Invoke();
        onMyIntEvent?.Invoke(1);
        onMyEvent?.Invoke(2);
    }

    private void RemoveListeners()
    {
        onStartEvent.RemoveListener(OnMyCallback);                    // Note: NOT OnStartEvent -= MyCallbackA;
        // OnStartEvent.RemoveListener(MyCallbackInt);              // Note: issues removing anonymous function
        onMyIntEvent.RemoveListener(OnMyCallbackInt);
        onMyEvent.RemoveListener(OnMyCallbackInt);

        // remove all listeners
        // OnStartEvent.RemoveAllListeners();
        // OnMyIntEvent.RemoveAllListeners();
        // onMyEvent.RemoveAllListeners();

        Logger.Print(">>> Remove Listeners");
    }

    private void OnMyCallback()
    {
        Logger.Print(">>> Got MyCallback()");
    }

    private void OnMyCallbackInt(int value)
    {
        Logger.Print(">>> Got MyCallbackInt(" + value + ")");
    }
}

