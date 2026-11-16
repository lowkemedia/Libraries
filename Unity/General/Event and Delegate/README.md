# Callbacks and event examples

[CallbackTypes.cs](CallbackTypes.cs) contains two shared delegate declarations in
the `CallbackTypes` namespace:

| Delegate | Signature | Typical use |
| --- | --- | --- |
| `Callback` | `void ()` | Completion, delayed work and acknowledgment. |
| `OnPointerEvent` | `void (PointerEventData)` | Pointer forwarding and click blockers. |

Include this file with utilities that import CallbackTypes. It depends on Unity's
EventSystems types (uGUI), even if your own code uses only Callback.

## Examples

| File | Demonstrates |
| --- | --- |
| [DelegateExample.cs](DelegateExample.cs) | Combining and invoking ordinary delegates. |
| [DelegateEventExample.cs](DelegateEventExample.cs) | C# events, subscription and publisher-owned invocation. |
| [UnityEventExample.cs](UnityEventExample.cs) | Serialized Inspector events and a runtime generic event. |
| [UnityEventExtendExample.cs](UnityEventExtendExample.cs) | Subscribing from another component and removing a listener after use. |

The examples use Logger for traces and are optional; the callback declarations
are all that other utilities need from this folder. Inspector event fields should
be initialized/assigned before invoking example code. Runtime-created components
may need their UnityEvents explicitly constructed.

Both C# events and UnityEvents retain listener targets. Unsubscribe when a
subscriber's lifetime ends, particularly when the publisher lives longer.
Keep the delegate instance if you intend to remove an anonymous listener later;
removing another method does not remove that anonymous callback. Some examples
leave an anonymous listener registered to illustrate this distinction.

Public camelCase UnityEvent fields store Inspector wiring. Runtime properties
such as `OnMyEvent` are not serialized. Use a concrete serializable UnityEvent
subclass for the Inspector patterns demonstrated here. Code listeners and
persistent Inspector listeners have different removal behavior; clearing runtime
listeners does not erase authored Inspector wiring. Choose events for the needed
ownership/editor workflow, and measure performance in your own workload rather
than relying on a universal speed ratio.
