# Logger

Logger is a small Unity logging utility shaped by practical debugging: finding
out what happened on a device, tracing UI interactions, and identifying a warning
when attaching a debugger is impractical. Its static helpers keep calls simple:

```csharp
Logger.Detail("Loaded 24 entries");
Logger.Print(">> opened settings");
```

## Why the utilities depend on it

A shared Logger gives the utilities consistent severity, filtering, searchable
diagnostic IDs and optional once-only messages. With an alert presenter connected,
the same diagnostics can be shown on the device itself. A user can report a
message and its ID even without access to a console or debugger.

This is useful alongside tests and breakpoints, particularly for interaction,
timing and device-specific problems that need observation while the app runs.
It also supports straightforward print-based investigation without requiring a
debugger's view of all the surrounding state.

Copy [Logger.cs](Logger.cs) with any utility that calls it. Logger uses Unity and
standard C# libraries; it requires no other General utility, prefab, scene
component or initialization call. Logger is a static class, not a component
to attach to a GameObject. **Logger has no dependency on Alert.** Utilities that
call Logger do require it at compile time, even when logging is turned off.

## Levels: choose what the message is for

| Helper | Intended use | Unity output | Automatic alert eligible? |
| --- | --- | --- | --- |
| `Severe` | A serious failure needing attention. | `Debug.LogError` | Yes |
| `Warning` | An unexpected condition or limitation. | `Debug.LogWarning` | Yes |
| `Info` | A meaningful event worth reporting to a person. | `Debug.Log` | Yes |
| `Detail` | Useful lasting diagnostics, such as loading progress or selected values. | `Debug.Log` | No |
| `Print` | Informal, usually temporary execution tracing. | `Debug.Log` | No |
| `Debug` | Verbose development diagnostics, normally hidden. | `Debug.Log` | No |

Set the threshold with `Logger.Level` and the `Logger.LogLevel` enum:

```csharp
Logger.Level = Logger.LogLevel.WARNING; // Severe and Warning only
Logger.Level = Logger.LogLevel.DETAIL;  // Severe, Warning, Info and Detail
Logger.Level = Logger.LogLevel.PRINT;   // Default: everything except Debug
Logger.Level = Logger.LogLevel.DEBUG;   // All helpers
Logger.Level = Logger.LogLevel.NONE;    // No Logger output or automatic alerts
```

The order is **Severe → Warning → Info → Detail → Print → Debug**. A threshold
includes its own level and everything to its left. Unity's Console filters are
separate: Detail and Debug still use Unity's ordinary Log channel.
Changing the threshold reports `LOG00` through Detail, subject to the **new**
threshold. Assigning the same level does not report a change.

These are runtime settings, not development-build switches. Choose the desired
settings in your application. In the Editor, Severe can trigger **Error Pause**;
acknowledging an alert does not resume paused Play Mode.

## Print: old-school tracing

Print deliberately stays simple:

```csharp
Logger.Print(">> pointer down");
Logger.Print(">>>> entered drag handler");
Logger.Print(">>>>>> applied position");
```

The arrows make a path through the code easy to spot. Repeated messages are
useful evidence, so every call that passes the threshold prints. Logger adds no
severity prefix to Print and accepts **no ID or once-only flag**:

```csharp
Logger.Print("Reached this branch", stackTrace: true);
```

Remove these traces when the investigation is finished. If a message earns a
permanent place, choose Detail for useful ongoing diagnostics, Debug for verbose
traces, or Info/Warning/Severe when the message warrants that severity.
Use Debug when a development trace needs once-only suppression.

## Detail: useful enough to keep

Detail fills the gap between temporary Print traces and Info messages that may
be shown to a user. It normally needs no ID and never requests an automatic alert:

```csharp
Logger.Detail("Selected font: " + fontName);
Logger.Detail("Optional preview disabled", showOnlyOnce: true);
```

Like Severe, Warning, Info and Debug, its signature is:

```csharp
Detail(string message, string id = null,
       bool showOnlyOnce = false, bool stackTrace = false)
```

Use the public helpers for ordinary logging. `Log` is private. The internal
`LogNoAlert` method is reserved for explicit Alert logging, where it prevents
duplicate automatic alerts; it is not an application-level suppression option.

## Once-only messages

`showOnlyOnce: true` prevents repeated reports of the **same exact message text**.
It is useful for warnings raised during frequent updates. It does not mean once
per object, per frame, per ID or per call site.

```csharp
Logger.Debug("Waiting for preview data", showOnlyOnce: true);
```

The details matter:

- The cache is shared across helpers. Different IDs or severities with identical
  message text share the same once-only entry.
- IDs, severity prefixes, test labels and `stackTrace: true` are added to the
  output after this check; they do not change the cached message. If you append
  a trace to the message yourself before calling Logger, it becomes part of the
  cache key instead.
- Changing text, such as a counter or object name in the message, creates a
  different entry. Such messages can still repeat extensively.
- The message is remembered **before** level filtering. In the example above,
  the default PRINT level hides Debug but still remembers the message. Enabling
  DEBUG later will not make the same once-only message appear.
- Enabling `ShowAlert` later does not replay remembered messages. A warning
  already reported once to the console will remain suppressed.
- There is no public cache-reset method. The cache lasts with the static state;
  it does not reset on a scene change. Editor sessions without domain reload can
  retain it between Play sessions.

Calls without `showOnlyOnce` still print normally, even if their text was
previously remembered. The cache is an ordinary dictionary without locking; do
not rely on concurrent once-only logging from multiple threads.

## IDs: get from a reported message to its source

Keep named ID constants together in the owning utility. A small helper can keep
its block in its own class; a larger utility may use a shared ID class.

```csharp
public const string SEVERE_LOAD_FAILED_ID = "EXM00";
public const string WARNING_MISSING_PREVIEW_ID = "EXM01";
public const string INFO_LOAD_COMPLETE_ID = "EXM02";

// Inside the owning utility:
Logger.Warning("Preview is unavailable", WARNING_MISSING_PREVIEW_ID,
    showOnlyOnce: true);
```

The output includes `WARNING #EXM01: Preview is unavailable`. Search the source
for **EXM01** to find the constant, then use **Find References** on
`WARNING_MISSING_PREVIEW_ID` to find its callers. The ID remains useful even when
the message contains variable data or is reported from a screenshot.

Assign full string literals, not a separate prefix expression, so searching the
reported ID works. Order the block Severe, Warning, Info, optional Detail, then
exceptional Debug, with lower numbers for higher severities. Use a distinct
prefix for each utility. Pass the constant at call sites rather than repeating
the literal ID.

Info, Warning and Severe should have IDs. Detail and Debug normally do not;
add one only when a lasting diagnostic benefits from a named reference. Print
never has an ID. IDs identify diagnostics; they do not control filtering or
once-only suppression. See the [General ID convention and inventory](../README.md#named-diagnostic-ids).

## Alerts when a debugger is out of reach

`Logger.ShowAlert` (singular) defaults to false. With an alert presenter installed,
turning it on requests on-screen alerts for Info, Warning and Severe messages
that pass the threshold and once-only checks. Console logging continues too.

An application can expose this through a hidden diagnostic menu or an
“easter egg” gesture, allowing a user to reproduce a problem and report its
message and ID:

```csharp
// Called by your application's diagnostic control.
Logger.Level = Logger.LogLevel.INFO;
Logger.ShowAlert = true;

// Disable automatic alerts after the investigation.
Logger.ShowAlert = false;
```

The hidden control and any saved preference belong to your application; Logger
does not supply them. Ordinary logging calls honour the global switch. Detail,
Print and Debug stay console-only, so routine diagnostic chatter need not become
a series of dialogs.

Logger emits `AlertRequested(level, formattedMessage)`; it does not draw UI.
Include [SystemUI and its LoggerAlertBridge](../SystemUI/README.md#logger-integration)
for the supplied system alerts. Unity installs that bridge before scene startup;
no scene attachment is needed. Without a subscriber, setting `ShowAlert` has no
visible UI effect. Automatic alerts include the severity and ID in the formatted
message, making them useful for remote diagnosis.

You may supply your own presenter instead. Events run on the logging caller's
thread; a presenter must arrange any necessary main-thread dispatch and must
not log the request again. The supplied bridge queues it and avoids duplicate
logging. Explicit `Alert.Info` and similar calls have their own presentation
rules; `ShowAlert` controls Logger's automatic requests.

## Stack traces

`stackTrace: true` appends `System.Environment.StackTrace` to the message. There
is no need to throw and catch an exception just to obtain a trace. Unity already
provides stack traces according to its own settings; the explicit option is
useful when the call path needs to travel with the message, including an alert.
It captures the logging call's current stack, not an earlier exception's origin.

## TestExpected: label a diagnostic scenario

`Logger.TestExpected(name)` announces a scenario through Print, then appends
`[TEST EXPECTED: name]` to subsequent Logger messages, including logs from called
utilities. Here is a complete manual example, using the default PRINT threshold:

```csharp
Logger.TestExpected("Preview loading");
try {
    Logger.Detail("Starting preview");
    // Call the code being investigated here; its Logger messages get the label too.
    Logger.Print(">> preview callback reached");
    Logger.Detail("Preview complete");
}
finally {
    Logger.ClearTestExpected(); // Clear even if the investigated code throws.
}
Logger.Detail("Outside the scenario"); // No test label.
```

The message bodies in the console are:

```text
TESTING-> Preview loading
DETAIL Starting preview
 [TEST EXPECTED: Preview loading]
>> preview callback reached
 [TEST EXPECTED: Preview loading]
DETAIL Preview complete
 [TEST EXPECTED: Preview loading]
DETAIL Outside the scenario
```

The announcement itself has no test label. It obeys the Print threshold, but
setting the label works even when that announcement is filtered out. Subsequent
logs retain their normal severity, ID and message. The label appears on the next
line, indented by one non-breaking space (`\u00A0`), before an explicitly
requested stack trace. Automatic alerts include it.

**Labels do not nest.** There is one shared label, not a stack:

```csharp
Logger.TestExpected("Outer");
Logger.TestExpected("Inner");  // Replaces Outer.
Logger.Detail("Current work"); // Label is Inner.
Logger.ClearTestExpected();    // Clears it; does not restore Outer.
Logger.Detail("More work");    // No label.
```

Passing null or an empty string to `TestExpected` also clears the label without
an announcement. Prefer `ClearTestExpected()` when that is the intent.

Let the outer scenario or test runner own setting and clearing the label; helper
methods should simply log. If a runner already labels each test, do not set a
second label inside the test. Finish related background work before clearing it,
and avoid concurrent labelled scenarios: the label is shared across threads.

Despite the name, this is context, **not an assertion that an error is expected**.
It does not suppress errors, change filtering, reset once-only messages or replace
a test framework's log assertions. Direct `UnityEngine.Debug` calls do not receive
the label. See [test context](../README.md#unit-test-log-context) for more guidance.
