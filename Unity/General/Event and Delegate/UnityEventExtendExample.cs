using UnityEngine;

[RequireComponent(typeof(UnityEventExample))]
public class UnityEventExtendExample : MonoBehaviour
{
    private UnityEventExample Example { get { return GetComponent<UnityEventExample>(); } }

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
