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
