using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DelegateExample : MonoBehaviour
{
    public delegate void Callback();
    private Callback _callback;

    private void Awake()
    {
        AddCallback();
    }

    private void AddCallback()
    {
        _callback += MyCallback;
        _callback += delegate { MyCallbackInt(0); };
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
        _callback -= MyCallback;
        // _callback -= MyCallbackInt;                  // Note: issues removing anonymous function

        // remove all callbacks
        _callback = null;

        Logger.Print(">> Remove Callbacks");
    }

    /* Update is called once per frame
    private void Update()               // must be private
    {

    }
    */

    private void MyCallback()
    {
        Logger.Print(">> Got MyCallback()");
    }

    private void MyCallbackInt(int value)
    {
        Logger.Print(">> Got MyCallbackInt(" + value + ")");
    }

    /* Destroy is called when instance is destroyed
    public void Destroy()               // must be public
    {
    }
    */
}
