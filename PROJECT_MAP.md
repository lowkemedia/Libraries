# Project map

Orientation based on the source at commit `82d256c` (16 October 2026). This is a guide to existing connections, not a proposed architecture or an exhaustive dependency manifest.

## Unity/General

| Utility | Responsibility and important dependencies/setup |
| --- | --- |
| [Alert](Unity/General/Alert/README%20System%20Alerts.md) / [Logger](Unity/General/Logger/Logger.cs) | Runtime system prompts and diagnostics. They reference each other at compile time, even with `Logger.ShowAlert` off. Include `Alert.cs`, `Logger.cs`, `Click.cs`, `Beep.cs` and `CallbackTypes.cs`; Unity dependencies include IMGUI, uGUI/EventSystems, legacy input and audio. |
| [Sound](Unity/General/Sound/README.md) | Click and Beep are independently copyable synthesized sounds with only Unity/System dependencies. SoundHelper uses configured AudioSources, `CallbackTypes` and Logger (and therefore its dependency set). |
| [Animator](Unity/General/Animator/) | `Animator` owns `Anime` objects and composable `AnimatorEffect`/tween effects. Uses `AnimatorTypes`, `CallbackTypes`, Logger, `GlobalState` and utility helpers; some effects use uGUI. Attach the component to a scene. `Start()` changes application frame-rate and Unity timing settings on handheld devices. This global `Animator` class is distinct from `UnityEngine.Animator`. |
| [Coroutine](Unity/General/Coroutine/) | `Delayer` queues work for a later update or scaled-time delay; `Fader` fades uGUI Text; `Mover` moves transforms. Each requires its own attached component. Uses Logger, with `CallbackTypes` for Delayer/Mover. Do not assume work survives scene changes. |
| [Button](Unity/General/Button/) | Pointer-driven `ClickButton` and variants/styles. Uses uGUI/EventSystems, SoundHelper and Delayer; text variants/factory also use TextMeshPro and localization/styling helpers. Consumers supply UI objects and styles. |
| [DialogManager](Unity/General/DialogManager/) | Scene-configured `DialogManager`, `DialogBase` and `Dialog` with buttons, TextMeshPro, localization/styles, ClickBlocker and SoundHelper. Separate from the self-installed system Alert. |
| [Localizer](Unity/General/Localizer/) / [JsonReader](Unity/General/Json/JsonReader.cs) | Resource JSON loading through Unity `JsonUtility`; language keys, substitutions and text styles. Uses Logger, callback and utility helpers. Text styling uses TextMeshPro; `SetOfFonts` loads a consumer-provided `Resources/Localizer Fonts` asset. JSON, fonts and styles are not bundled. `LocalizerExport` writes files; inspect its output conventions before use. |
| [PopupMenu](Unity/General/PopupMenu/) | Popup, drop-down and hamburger variants assembled from buttons, TextMeshPro, ClickBlocker and utility helpers; localized variants use Localizer. Needs consumer UI/assets. |
| [PageSwiper](Unity/General/PageSwiper/) | Drag/page navigation, page dots and numbers. Uses Mover, Utils/UtilsRect and callbacks; uGUI and TextMeshPro for relevant display components. |
| [PointerEventCopier](Unity/General/PointerEventCopier/), [SwipeDetector](Unity/General/SwipeDetector/), [ClickBlocker](Unity/General/ClickBlocker/) | Event forwarding, swipe detection and pointer interception using uGUI/EventSystems. Application input polling is a separate concern. |
| [Utils](Unity/General/Utils/), [GlobalState](Unity/General/GlobalState.cs), [ImageComposite](Unity/General/ImageComposite/) | Array/string/number helpers, Unity object/geometry/color helpers, drag/device state and image composition. Dependencies differ by file: `UtilsRect`, for example, imports TextMeshPro. |
| [Video](Unity/General/Video/) | Video playback and progress controls using Unity video APIs, configured UI/RenderTexture references, ClickButton and callbacks. |

Most C# classes live in the global namespace. Check name collisions and the full referenced helper set when copying a subset; folder boundaries are not assembly boundaries. Logger is used widely, so its Alert dependency affects many otherwise small subsets.

## Adobe and C++

The ActionScript collection under `Adobe/src/com/lowke` includes `Animator`/effects, `ActionQueue`, `AssetLoader`, `AssetManager`, `SoundManager`, UI helpers and `util`. Keep imported event, loader and value-object classes with the selected utility. Source comments provide examples and historical runtime annotations (for example, the Adobe Animator says ActionScript 3.0 / Flash 10); these do not establish a tested minimum for the entire tree. FLA/SWC examples and bundled FZip/easing code retain their own provenance. Some imports refer to Flex or older package paths; a complete ActionScript build has not been verified here.

The C++ tree contains independent helpers, an OpenGL/GLUT animator and substantial teaching material rather than one application. The Mersenne Twister files depend on `ig*` headers not supplied here, and their permission status is unresolved; see [licensing](README.md#licensing-and-attribution).

## Latest source update

Commit `82d256c`, “updating unity General folder”, follows Git LFS configuration updates in June/September 2026 and the previous source changes in December 2022. It:

- Adds Alert and its initial application-oriented documentation, plus synthesized Click and Beep.
- Adds opt-in automatic Logger alerts, per-call `allowAlert`, stack-trace output and severity-specific Unity logging.
- Initializes Delayer's next-update queue at declaration and disables duplicate components.
- Makes `Dialog.Enlarge` pass through its `extraHeight` argument instead of always using 60, and removes a duplicate playback start from SoundHelper's callback coroutine.
- Adds null-safe `UtilsArray.Length`.

These are findings from the committed diff, not runtime test results.

## Boundaries for future work

- Keep utilities focused. Change abstractions or dependencies only for a demonstrated need, considering consumers beyond Ages of Chess.
- Preserve public APIs, callback order/lifetime and serialized field names unless a change is intentional and reviewed. Use `_camelCase` for private C# fields and Logger helpers for ordinary diagnostics. Catch exceptions only where there is concrete recovery behaviour.
- Keep application recovery, persistence and navigation decisions in the consumer. Alert reports choices; it does not own those policies. Keep synthesized audio independent of configured SoundHelper audio.
- Manual synchronization normally comes from Ages of Chess's `Assets/Code/General`. Compare both sides first, retain library-only documentation and unrelated changes, and do not assume either side is permanently authoritative. No automatic synchronization is configured.
- Review, commit and push manually. Unity launch/upgrades, package installation and source changes require their own task scope.

## Uncertainties

Minimum toolchain versions and a target-platform verification matrix are not established. No tracked automated tests or runnable Unity fixture were found; delegate examples are demonstrations. Scene/resource setup for older UI utilities needs consumer validation. Root licence coverage for files without headers and the restrictive C++ notices need maintainer clarification. No Unity compilation, Editor/device tests or application-to-library equality check is claimed by this documentation pass.
