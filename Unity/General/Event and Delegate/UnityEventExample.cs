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

// NOTE: Both C# events and UnityEvents hold references to their listener targets.
// A long-lived publisher can keep a subscriber from being garbage collected.
// Remove listeners when they are no longer needed; UnityEvents do not use weak references.

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
public class MyIntEvent : UnityEvent<int> {}

// Generic wrapper used by the runtime-only OnMyEvent property below.
public class MyUnityEventWrapper<T> : UnityEvent<T> {}

public class UnityEventExample : MonoBehaviour
{
    public UnityEvent onStartEvent;                                 // Inspector listeners are stored in this serialized field.
    public MyIntEvent onMyIntEvent;
    public MyUnityEventWrapper<int> OnMyEvent { get; set; }                      // Runtime property; not serialized by Unity.

    // Initialize the runtime event and register listeners before Start.
    private void Awake()
    {
        // Note: if private or not serializable you will need to create a new event
        if (OnMyEvent is null) {
            OnMyEvent = new MyUnityEventWrapper<int>();
        }

        AddListeners();
    }

    private void AddListeners()
    {
        onStartEvent.AddListener(OnMyCallback);                       // Note: NOT onStartEvent += MyCallbackA;
        onStartEvent.AddListener(delegate { OnMyCallbackInt(0); });
        // onStartEvent.AddListener(() => MyCallbackB(0));          // Lambda Expression for delegate { MyCallbackB(0); };

        onMyIntEvent.AddListener(OnMyCallbackInt);
        OnMyEvent.AddListener(OnMyCallbackInt);
    }

    // Start is called before the first frame update
    private void Start()
    {
        onStartEvent?.Invoke();
        onMyIntEvent?.Invoke(1);                                    // passing parameter into event
        OnMyEvent?.Invoke(2);

        RemoveListeners();

        onStartEvent?.Invoke();
        onMyIntEvent?.Invoke(1);
        OnMyEvent?.Invoke(2);
    }

    private void RemoveListeners()
    {
        onStartEvent.RemoveListener(OnMyCallback);                    // Note: NOT onStartEvent -= MyCallbackA;
        // onStartEvent.RemoveListener(MyCallbackInt);              // Note: issues removing anonymous function
        onMyIntEvent.RemoveListener(OnMyCallbackInt);
        OnMyEvent.RemoveListener(OnMyCallbackInt);

        // remove all listeners
        // onStartEvent.RemoveAllListeners();
        // onMyIntEvent.RemoveAllListeners();
        // OnMyEvent.RemoveAllListeners();

        Logger.Print(">>> Remove Listeners");
    }

    private void OnMyCallback() {
        Logger.Print(">>> Got MyCallback()");
    }

    private void OnMyCallbackInt(int value) {
        Logger.Print(">>> Got MyCallbackInt(" + value + ")");
    }
}

