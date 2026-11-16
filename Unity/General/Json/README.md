# JsonReader

Loads a JSON `TextAsset` from Unity Resources and deserializes it through
`JsonUtility`. Include [Logger](../Logger/README.md). No scene component is needed;
call from Unity's main thread.

## Resource and model

Save `Assets/Resources/Config/Preview.json`:

```json
{ "title": "Preview", "repeatCount": 3 }
```

Use a serializable data class with public fields matching the JSON names:

```csharp
[System.Serializable]
public class PreviewConfig
{
    public string title;
    public int repeatCount;
}
```

Inside your initialization method:

```csharp
PreviewConfig config = JsonReader.ReadJson<PreviewConfig>("Config/Preview");
if (config != null) {
    Logger.Detail(config.title);
}
```

The path is relative to a Resources folder: omit `Assets/Resources/` and the
file extension. This helper does not read arbitrary disk paths, URLs or streaming
assets, and does not save JSON. Use the corresponding Unity/.NET loading API when
those are needed.

## Failure and serialization rules

A missing asset logs warning `JSN01` and returns `default(T)`. A deserialization
exception logs severe `JSN00` and also returns `default(T)`; Logger may show an
automatic alert if configured. For a reference-type model, default is null.
Missing fields or otherwise accepted JSON can still produce a model with default
values: validate required application data after loading.

`JsonUtility` uses Unity's field-based serialization. Ordinary C# properties are
not JSON fields. Use a wrapper object for arrays, as Localizer does with its
`keys` array; this is not a general dictionary or polymorphic JSON serializer.
See the [Localizer format](../Localization/Localizer/README.md#setup-and-resource-files)
for a larger working model.
