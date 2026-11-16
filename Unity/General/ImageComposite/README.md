# ImageComposite

Builds a Canvas graphic from a root Image plus decorative child Images. Useful
for layered icons, tiles, badges and highlights that should act as one visual.
It does not bake layers into a texture or create a Sprite asset.

Include `ImageComposite.cs`, [UtilsRect and Utils](../Utils/README.md), their
companion dependencies, and Unity UI. Supply a Canvas parent and your own sprites.

With `GameObject parent` and `Sprite baseSprite, overlaySprite` already assigned:

```csharp
ImageComposite badge = ImageComposite.Make(parent, baseSprite, "Badge");
badge.RectTransform.sizeDelta = new UnityEngine.Vector2(64, 64);
badge.RectTransform.localPosition = UnityEngine.Vector3.zero;
badge.RectTransform.localScale = UnityEngine.Vector3.one;
badge.RaycastTarget = false;
badge.AddImage(overlaySprite, "Overlay", UnityEngine.Color.white);
```

`Make(parent, sprite, name, color = default)` creates the object, attaches this
component, adds the root Image and parents it. Alternatively, attach the component
to a new object and call `Initialize(sprite, color)` once before accessing its
properties. Initialize adds an Image; it is not an idempotent refresh method.

- `Sprite` reads/writes the root sprite.
- `RectTransform` exposes the root Image's transform for explicit layout.
- `RaycastTarget` and `RaycastPadding` affect the root Image only.
- `AddImage(sprite, name, color = default)` adds a child Image, ordered after
  earlier children, with raycasting disabled. It returns void.

Root and child attachment uses `UtilsRect.AttachChild`: initial sizeDelta is
**1 × 1**, not the sprite's native size or a stretched copy of the parent.
Set anchors, size and transforms for the layout you need. For custom child sizing,
retrieve the named child and configure its RectTransform after `AddImage`.
No automatic aspect-ratio fitting, layer removal API or layout synchronization
is supplied.

The optional color uses `default(Color)` as “leave the Image's default color.”
Passing `Color.clear` therefore does not make it transparent through this
argument. Set the Image color afterward when explicit transparency is required.
Destroy the generated root GameObject when finished; its children follow its
normal Unity lifetime.
